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
