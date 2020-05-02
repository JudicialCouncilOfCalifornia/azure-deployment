-include env_make

SOLR_VER ?= 8.5.1
PORTS ?= -p 8983:8983
CMD ?= solr-precreate jcc-prod,jcc-stage,jcc-dev search_api_solr_8.x-3.9

REPO = jccwebservicesregistry.azurecr.io/source/solr-alpine-azure
NAME = solr-alpine-azure-$(SOLR_VER)

ifeq ($(TAG),)
    TAG := $(SOLR_VER)
endif

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) ./

test:
	IMAGE=$(REPO):$(TAG) ./test.sh

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push
