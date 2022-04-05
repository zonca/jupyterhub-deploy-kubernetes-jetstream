from flask import Flask
import sys
import s3fs
import numpy as np
import subprocess
import os
import zarr
import dask.array as da
import dask
from dask_gateway import Gateway

def create_app(test_config=None):
    app = Flask(__name__)


    gateway = Gateway(
        address="http://traefik-dask-gateway.jhub/services/dask-gateway/",
        public_address="https://sg.zonca.dev/services/dask-gateway/",
        auth="jupyterhub",
    )
    options = gateway.cluster_options()
    options["image"] = "zonca/dask-gateway-zarr:latest"
    cluster = gateway.new_cluster(options)
    cluster.scale(3)

    @app.route("/")
    def hello():

        return "Gateway up and running!\n"


    @app.route("/submit_job/<job_id>")
    def submit_job(job_id):
        import s3fs

        client = cluster.get_client()
        fs = s3fs.S3FileSystem(
            use_ssl=True,
            client_kwargs=dict(
                endpoint_url="https://js2.jetstream-cloud.org:8001/",
                region_name="RegionOne",
            ),
        )
        store = s3fs.S3Map(root=f"gateway-results/{job_id}", s3=fs)  # , check=False)
        z = zarr.empty(
            shape=(1000, 1000), chunks=(100, 100), dtype="f4", store=store, compression=None
        )
        x = da.random.random(size=z.shape, chunks=z.chunks).astype(z.dtype)
        x.store(z, lock=False)

        return "Submitted job {}\n".format(job_id)
    return app


if __name__ == "__main__":
    app = create_app()
    app.run(host="0.0.0.0", port=8000, debug=False)
