from flask import Flask
import sys
import s3fs
import xarray as xr
import numpy as np

app = Flask(__name__)

@app.route("/")
def hello():

    return "Gateway up and running!\n"

@app.route("/submit_job/<job_id>")
def submit_job(job_id):
    fs = s3fs.S3FileSystem(use_ssl=True, client_kwargs=dict(endpoint_url="https://tacc.jetstream-cloud.org:8080/swift/v1", region_name="RegionOne"))
    d = s3fs.S3Map("gateway_results/{}".format(job_id), s3=fs, create=True)
    ds = xr.DataArray(np.random.randn(100, 100))
    ds.to_zarr(store=d, mode='w')
    return "Submitted job {}\n".format(job_id)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=False)
