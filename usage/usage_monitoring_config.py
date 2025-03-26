from os.path import expanduser

home = expanduser("~")

# String: Path to file used for the openstack token
token_file = "/path/to/os-token.json"

# List of strings: Used to filter out the Jetstream2 resources that are irrelevant, i.e.
# storage, which doesn't use service units
allocation_resources = [
    "jetstream2.indiana.xsede.org",
    #'jetstream2-gpu.indiana.xsede.org',
    #'jetstream2-lm.indiana.xsede.org',
]

# String: Path to data file which stores persistent data
data_file = f"{home}/usage_monitoring.csv"

# String: Path to a test data file used for development
test_csv_file = "/tmp/usage_monitoring_test.csv"
