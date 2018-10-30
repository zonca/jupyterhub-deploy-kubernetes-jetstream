from flask import Flask
import sys
import s3fs
import xarray as xr
import numpy as np
import subprocess
import os

app = Flask(__name__)

@app.route("/")
def hello():

    return "Gateway up and running!\n"

@app.route("/submit_job/<job_id>")
def submit_job(job_id):
    #fs = s3fs.S3FileSystem(use_ssl=True, client_kwargs=dict(endpoint_url="https://tacc.jetstream-cloud.org:8080", region_name="RegionOne"))
    #d = s3fs.S3Map("gateway_results/{}".format(job_id), s3=fs, create=False)
    ds = xr.Dataset({'foo': np.zeros(10), 'bar': ('x', [1, 2]), 'baz': np.pi})
    out = "{}.nc".format(job_id)
    ds.to_netcdf(out, mode='w')
    subprocess.run("openstack object create dummy_gateway {}".format(out).split())
    os.remove(out)

    return "Submitted job {}\n".format(job_id)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=False)
