Jetstream2 Usage Monitoring
===========================

See <https://github.com/Unidata/science-gateway/blob/master/openstack/bin/usage-monitoring/usage_monitoring.py>

This script allows to:

* Generate an Openstack token
* Use this token to query the JS2 Accounting API
* Parse the output to get your current amount of used SUs
* Save to a csv file
* Create a plot
* An "analysis" of the data (a very simple linear model) is then done to determine the usage rate and make any predictions about future SU usage.
