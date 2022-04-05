FROM continuumio/miniconda3

# Update
RUN conda install --yes -c conda-forge flask ipython && conda clean --yes --all
RUN pip install zarr s3fs dask==2.30.0 distributed==2.30.0 dask_gateway

# Bundle app source
COPY gateway.py /src/gateway.py

# Object store credentials, just for testing
# RUN mkdir -p ~/.aws
# COPY my_aws_config /root/.aws/credentials

EXPOSE  8000
CMD ["python", "/src/gateway.py", "-p 8000"]
