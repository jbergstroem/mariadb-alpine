default: build
.PHONY: check-tag

DOCKER_IMAGE?=jbergstroem/mariadb-alpine

# fix this later
DOCKER_TAG?=$(shell git tag -l --points-at HEAD)

ifndef DOCKER_TAG
	$(error Can't find a corresponding git tag)
endif

build:
	@docker build \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) .

push:
	@docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):latest

	@docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	@docker push $(DOCKER_IMAGE):latest
