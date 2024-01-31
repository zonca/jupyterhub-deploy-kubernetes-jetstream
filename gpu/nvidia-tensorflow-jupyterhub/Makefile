IMAGE = zonca/nvidia-tensorflow-jupyterhub

build:
	docker build -t $(IMAGE):${VERSION} .

cleanbuild:
	docker build --no-cache -t $(IMAGE):${VERSION} .

login:
	docker login

push:
	docker push $(IMAGE):${VERSION}

shell:
	docker run -it $(IMAGE):${VERSION} bash

tag:
	git tag -a ${VERSION} -m "Tag ${VERSION} in Github repository"

# ####################################################
# For optionally building with Pytorch instead of TF
# ####################################################

PYTORCH = zonca/pytorch-jupyterhub

pytorch:
	docker build -t $(PYTORCH):${PT_VERSION} --build-arg="ENVIRONMENT_FILE=environment-pytorch.yml" .

cleanpytorch:
	docker build --no-cache -t $(PYTORCH):${PT_VERSION} --build-arg="ENVIRONMENT_FILE=environment-pytorch.yml" .

pushpytorch:
	docker push $(PYTORCH):${PT_VERSION}

shellpytorch:
	docker run -it $(PYTORCH):${PT_VERSION} bash

