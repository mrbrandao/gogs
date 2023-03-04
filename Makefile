# 
# The default Makefile for this project
#
registry = quay.io
project = ibrandao/gogs
ifdef CI_COMMIT_TAG
	version = $(CI_COMMIT_TAG)
else
	version = latest
endif
container = $(registry)/$(project):$(version)

.PHONY: help
help: ## - print the help and usage
		@printf "Project Usage:\n"
		@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## - build this project
	go get
	go mod tidy
	go build

.PHONY: install
install: ## - install this project in the $GOBIN path
	go install

regcon: ## - create the registry connection
ifdef CI
	@(echo $(REGTOKEN)|podman login -u=$(REGUSER) --password-stdin $(registry) > /dev/null 2>&1) 
endif

.PHONY: container-build
container-build: ## - build the container image
	podman build -f Containerfile -t $(container) .
ifeq (${LATEST}, 1)
	podman tag $(registry)/$(project):$(version) $(registry)/$(project):latest
endif

.PHONY: container-push
container-push: ## - push the container image to registry
	podman push $(registry)/$(project):$(version)
ifeq (${LATEST}, 1)
	podman push $(registry)/$(project):latest
endif
