FROM continuumio/miniconda3

# Update
RUN conda install --yes -c conda-forge flask zarr s3fs xarray ipython && conda clean --yes --all
RUN pip install python-openstackclient

# Bundle app source
COPY gateway.py /src/gateway.py

# Object store credentials
RUN mkdir -p ~/.aws
COPY my_aws_config /root/.aws/config

EXPOSE  8000
CMD ["python", "/src/gateway.py", "-p 8000"]
