ALL_ARCH.linux = amd64 arm arm64

ALL_ARCH.windows = amd64
ALL_OSVERSIONS.windows := 1809 2004 20H2 ltsc2022
ALL_OS_ARCH.windows = $(foreach arch, $(ALL_ARCH.windows), $(foreach osversion, ${ALL_OSVERSIONS.windows}, ${osversion}-${arch}))

# The current context of image building
# The architecture of the image
ARCH ?= amd64
# OS Version for the Windows images: 1809, 2004, 20H2, ltsc2022
WINDOWS_OSVERSION ?= 1809
# The output type for `docker buildx build` could either be docker (local), or registry.
OUTPUT_TYPE ?= docker

BASE.windows := mcr.microsoft.com/windows/nanoserver

TAG ?= $(shell git rev-parse HEAD)

REGISTRY ?= local
SERVER_IMAGE_NAME ?= simple-server
SERVER_FULL_IMAGE ?= $(REGISTRY)/$(SERVER_IMAGE_NAME)

DOCKER_CMD ?= docker
DOCKER_BUILDX ?= docker buildx

## --------------------------------------
##@ Binaries
## --------------------------------------

.PHONY: all
all: bin/server.exe bin/server ## Build binaries for the project.

bin:
	mkdir -p bin

bin/server.exe: ## Build server binary for Windows.
	CGO_ENABLED=0 GOOS=windows GOARCH=${ARCH} go build -a -o bin/simple-server-${ARCH}.exe ./main.go

bin/server: ## Build server binary for Linux.
	CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} go build -a -o bin/simple-server-${ARCH} ./main.go

## --------------------------------------
##@ Images
## --------------------------------------

.PHONY: buildx-setup
buildx-setup:
	${DOCKER_CMD} buildx inspect img-builder > /dev/null || docker buildx create --name img-builder --use

.PHONY: build-server-linux
build-server-linux: buildx-setup ## Build node-manager image for Linux.
	${DOCKER_BUILDX} build \
		--pull \
		--output=type=$(OUTPUT_TYPE) \
		--platform linux/$(ARCH) \
		--build-arg ARCH=$(ARCH) \
		--file Dockerfile \
		--tag ${SERVER_FULL_IMAGE}:${TAG}-linux-$(ARCH) .

.PHONY: build-server-windows
build-server-windows: buildx-setup bin/server.exe ## Build node-manager image for Windows.
	$(DOCKER_BUILDX) build --pull \
		--output=type=$(OUTPUT_TYPE) \
		--platform windows/$(ARCH) \
		--tag ${SERVER_FULL_IMAGE}:${TAG}-windows-$(WINDOWS_OSVERSION)-$(ARCH) \
		--build-arg OSVERSION=$(WINDOWS_OSVERSION) \
		--build-arg ARCH=$(ARCH) \
		--file windows.Dockerfile .