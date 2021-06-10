APT_PROXY ?=
DOCKER ?= docker

all: build

build: Dockerfile
	$(DOCKER) build --build-arg APT_PROXY="$(APT_PROXY)" -t ypcs/cli .
