from os import system
from os.path import isfile
from time import sleep

import argparse

from datetime import datetime, UTC, timedelta
import json
import csv
import pandas as pd
import requests
from matplotlib import pyplot as plt

from usage_monitoring_config import *

def create_os_token(token_file):
    return_val = system(f'openstack token issue -f json > {token_file}')
    # Sleep to give openstack the time to return the token
    sleep(5)
    if return_val != 0:
        raise

def get_os_token(token_file='/tmp/os-token.json', force_new_token=False):
    if isfile(token_file) and not force_new_token:
        with open(token_file, 'r') as f:
            f_json = json.load(f)
            date_format = '%Y-%m-%dT%H:%M:%S+0000'
            expires_str = f_json['expires']
            expire = datetime.strptime(expires_str, date_format).timestamp()
            now = datetime.now(UTC).timestamp()
            if expire > now:
                return f_json['id']
            else:
                #print("Token expired. Creating new token", file=stderr)
                create_os_token(token_file)
    else:
        create_os_token(token_file)
        return get_os_token(token_file)

def query_accounting_api(token):
    url = 'https://js2.jetstream-cloud.org:9001'
    headers = { 'X-Auth-Token': f'{token}' }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    query = json.loads(response.text)
    return query

def get_js2_resources(query):
    now = datetime.now()
    date_format = '%Y-%m-%d'
    all_resources = [ 
            resource for resource in query 
            if datetime.strptime(resource['start_date'],date_format) < now 
            and datetime.strptime(resource['end_date'],date_format) > now
        ]
    desired_resources = [
            resource for resource in all_resources
            if resource['resource'] in allocation_resources
        ]
    return desired_resources

def write_resource_csv(resources, data_file):
    '''Write the resource info into data_file with the csv format:
    timestamp,resource,service_units_used,service_units_allocated,start_date,end_date

    resources may be a dictionary or a list of dictionaries with the following keys:
        resource, service_units_used, service_units_allocated, start_date, end_date
    '''

    fieldnames = [
            'timestamp', 'resource', 'service_units_used',
            'service_units_allocated', 'start_date', 'end_date'
        ]
    now = datetime.now(UTC).timestamp()

    # Create file and write headers if it doesn't exist
    if not isfile(data_file):
        with open(data_file, 'w') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()

    with open(data_file, 'a') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        for resource in resources:
            writer.writerow({'timestamp': now,
                             'resource': resource['resource'],
                             'service_units_used': resource['service_units_used'],
                             'service_units_allocated': resource['service_units_allocated'],
                             'start_date': resource['start_date'],
                             'end_date': resource['end_date']})
    return 0

def read_resource_csv(data_file):
    '''Read in the resource info from data_file to be used in visualization, plotting, etc.
    File is in the following csv format:
    timestamp,resource,service_units_used,service_units_allocated,start_date,end_date
    '''
    return pd.read_csv(data_file)

def get_data_by_resource(resources, resource_type):
    '''
    resources -- pandas dataframe
    resource_type -- string
    '''
    return resources.loc[resources['resource'] == resource_type]

def get_usage_rates(data,days):
    '''
    data -- A list of dictionaries as returned by get_data_by_resource
    days -- int number of days from which to calculate the rate
    '''
    timestamps = pd.array(data['timestamp'])
    sus_used = pd.array(data['service_units_used'])

    date2 = timestamps[-1]
    delta = timedelta(days=days).total_seconds()

    dt1 = 9999999999999
    idate2 = -1
    date1 = date2 - delta
    idate1 = 0

    # Loop through timestamps to find the index of minimum difference
    for i,ts in enumerate(timestamps):
        # Get the entry that's closest to date1, i.e. "days" number of days before date2
        if abs(date1 - ts) < dt1:
            dt1 = date1 - ts
            idate1 = i

    # Rate at which SUs are used (should be positive, i.e. 1000 SU/s)
    rate_second = (sus_used[idate2] - sus_used[idate1])/(timestamps[idate2] - timestamps[idate1])
    rate_hour = 3600*rate_second
    rate_day = 24*rate_hour
    return { 'rate_second': rate_second,
            'rate_hour': rate_hour,
            'rate_day': rate_day,
            'rate_start_date': datetime.fromtimestamp(date1),
            'rate_end_date': datetime.fromtimestamp(date2)}


def usage_analysis(data,days_prior):
    '''Basic analysis of usage data between now and each value of days_prior
    
    Arguments:
        data -- pandas dataframe: as returned by get_data_by_resource()
        days_prior -- Int: or list of ints of days before "now" on which to perform analysis

    Returns:
        analysis -- array of Dicts with the following keys:
            analysis_start -- datetime
            analysis_end -- datetime
            resource -- string: the resource being analyzed
            daily_usage_rate -- float: rate of SU usage for the given resource
            hourly_usage_rate -- float: rate of SU usage for the given resource
            current_usage -- float: current SUs used
            total_allocated -- float: the total number of SUs allocated
            remaining_sus -- float: SUs remaining
            exhausted_date -- datetime: date when SUs are predicted to be exhausted
                based on current_usage and usage_rage
            end_date_sus -- float: can be + or -; number of SUs remaining (or in
                deficit) should usage_rate be constant until the end_date of the
                resource described by data
            break_even_daily_usage_rate -- float: the usage rate necessary so
                that the exhausted_date is the end_date of the resource
                described by data
            break_even_hourly_usage_rate -- float: the usage rate necessary so
                that the exhausted_date is the end_date of the resource
                described by data
            break_even_daily_delta -- float:
                break_even_daily_usage_rate - daily_usage_rate
            break_even_hourly_delta -- float:
                break_even_hourly_usage_rate - hourly_usage_rate
            break_even_m3_med_equivalents -- float: 
                the break_even_hourly_usage_rate expressed as an amount of
                m3.medium instances (8 SU/hr)
    '''

    if not isinstance(days_prior, (int, list)):
        raise ValueError

    # Make list if single value is passed to function
    if isinstance(days_prior, int):
        days_prior = [ days_prior ]

    analysis = []
    for day in days_prior:

        # Analysis done using a line given by:
        # sus_used - total_allocated = usage_rate*(timestamp - now)
        # Or, for ease of reading:
        # s2 - s1 = r*(t2 - t1)
        #
        # Where sus_used and timestamp are the dependent and independent
        # variables, respectively
        #
        # timestamp is in seconds since the beginning of the Unix epoch

        # Re-used in many calcs
        usage_rates = get_usage_rates(data,day)
        r = usage_rates['rate_second']
        tot_sus = data['service_units_allocated'].iloc[-1]
        cur_sus = data['service_units_used'].iloc[-1]
        cur_ts = data['timestamp'].iloc[-1]

        remaining_sus = tot_sus - cur_sus

        # tot_sus - s1 = remaining_sus = r*(t2 - t1) --> t2 = remaining_sus/r + t1
        exhausted_ts = remaining_sus/r + cur_ts
        exhausted_date = datetime.fromtimestamp(exhausted_ts)

        # s2 - s1 = r*(t2 - t1) --> s2 = r*(t2 - t1) + s1
        date_format = '%Y-%m-%d'
        end_date_ts = datetime.strptime(data['end_date'].iloc[-1],date_format).timestamp()
        end_date_sus_used = r*(end_date_ts - cur_ts) + cur_sus
        end_date_sus = tot_sus - end_date_sus_used

        # s2 - s1 = r*(t2 - t1) --> r = -(s2-s1)/(t2 - t1)
        break_even_second_usage_rate = remaining_sus/(end_date_ts - cur_ts)
        break_even_hourly_usage_rate = 3600*break_even_second_usage_rate
        break_even_daily_usage_rate = 24*break_even_hourly_usage_rate

        break_even_hourly_delta = break_even_hourly_usage_rate - usage_rates['rate_hour']
        break_even_daily_delta = break_even_daily_usage_rate - usage_rates['rate_day']

        analysis.append({
            'analysis_start': usage_rates['rate_start_date'],
            'analysis_end': usage_rates['rate_end_date'],
            'resource': data['resource'].iloc[-1],
            'daily_usage_rate': usage_rates['rate_day'],
            'hourly_usage_rate': usage_rates['rate_hour'],
            'current_usage': cur_sus,
            'total_allocated': tot_sus,
            'remaining_sus': remaining_sus,
            'exhausted_date': exhausted_date,
            'end_date_sus': end_date_sus,
            'break_even_daily_usage_rate': break_even_daily_usage_rate,
            'break_even_hourly_usage_rate': break_even_hourly_usage_rate,
            'break_even_daily_delta': break_even_daily_delta,
            'break_even_hourly_delta': break_even_hourly_delta,
            'break_even_m3_med_equivalents': break_even_hourly_delta/8.0,
        })

    return analysis

def generate_usage_plot(resources, analyses):
    fig, ax = plt.subplots()
    for resource_type in allocation_resources:
        data = get_data_by_resource(resources, resource_type)

        timestamps = pd.array(data['timestamp'])
        dates = [ datetime.fromtimestamp(ts) for ts in timestamps ]

        sus_used = pd.array(data['service_units_used'])
        sus_remaining = data['service_units_allocated'].iloc[-1] - sus_used

        ax.plot(dates, sus_remaining)

    plt.show()
    return 0

def main(data_file):
    parser = argparse.ArgumentParser()
    parser.add_argument('-n', '--force-new-token', help='Force the creation of a new openstack token before query', action='store_true')
    parser.add_argument('-w', '--write', help=f'Query Jetstream2 for new allocation data and write to data file: {data_file}', action='store_true')
    parser.add_argument('-c', '--dump-csv', help=f'Dump the data from {data_file} in csv format', action='store_true')
    parser.add_argument('-j', '--dump-json', help=f'Dump the data from {data_file} in json format', action='store_true')
    parser.add_argument('-p', '--plot', help='Generate an interactive plot of SU usage data', action='store_true')
    parser.add_argument('-a', '--analysis-days', help='Days prior for which to perform an analysis', action='extend', nargs='+', type=int)
    parser.add_argument('-d', '--devel', help='Use test_csv_file for development work', action='store_true')
    args = vars(parser.parse_args())

    if not any([ args[key] for key in args.keys() ]):
        parser.parse_args(['--help'])

    if args['devel']:
        data_file = test_csv_file

    if args['write']:
        token = get_os_token(token_file,force_new_token=args['force_new_token'])
        query = query_accounting_api(token)
        resources = get_js2_resources(query)
        write_resource_csv(resources, data_file)

    if args['dump_csv']:
        system(f'cat {data_file}')

    if args['dump_json']:
        resources = read_resource_csv(data_file)
        print(json.dumps(resources, indent=2))

    if args['analysis_days']:
        # Get resources
        resources = read_resource_csv(data_file)

        analyses = []
        # Loop over resources to get each type of data found in allocation_resources
        for resource_type in allocation_resources:
            data = get_data_by_resource(resources, resource_type)
            # Perform analysis (usage rates, "forecast", )
            analyses.append(usage_analysis(data,args['analysis_days']))

        print(json.dumps(analyses, indent=2, default=str))

    if args['plot']:
        if 'analyses' not in locals():
            analyses = None
        resources = read_resource_csv(data_file)
        generate_usage_plot(resources, analyses)

if __name__ == "__main__":
    main(data_file)
