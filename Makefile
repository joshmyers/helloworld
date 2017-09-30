.DEFAULT_GOAL := help

GITCOMMIT            := $(shell git rev-parse --short HEAD)
GITUNTRACKEDCHANGES  := $(shell git status --porcelain --untracked-files=no)
OS                   := $(shell uname -s | tr A-Z a-z)
PKG                  := hello-world
VERSION              := 0.0.1

ifneq ($(GITUNTRACKEDCHANGES),)
GITCOMMIT            := $(GITCOMMIT)-dirty
endif

CTIMEVAR             :=-X $(PKG)/version.GitCommit=$(GITCOMMIT) -X $(PKG)/version.HelloWorldVersion=$(VERSION)
GO_LDFLAGS           :=-ldflags "-w $(CTIMEVAR)"
GO_LDFLAGS_STATIC    :=-ldflags "-w $(CTIMEVAR) -extldflags -static"
GOOSES               := darwin linux
GOARCHS              := amd64
GOFMT_CMD            := $$(gofmt -w `find . -name '*.go' | grep -v vendor`)
TEST_DIRS            := $(shell find . -type f -name '*_test.go' -maxdepth 8 -exec dirname {} \; | grep -v vendor | sort -u)

MINIKUBE_DRIVER      ?= virtualbox
MINIKUBE_VERSION     ?= 0.22.1
MINUKUBE_URL         := https://github.com/kubernetes/minikube/releases/download/v$(MINIKUBE_VERSION)/minikube-$(OS)-amd64
MINIKUBE_INSTALL_CMD := $$(curl --progress-bar -Lo minikube ${MINUKUBE_URL} && chmod +x minikube && sudo mv minikube /usr/local/bin/ )

KUBECTL_VERSION      ?= 1.7.5
KUBECTL_URL          := https://storage.googleapis.com/kubernetes-release/release/v$(KUBECTL_VERSION)/bin/$(OS)/amd64/kubectl
KUBECTL_INSTALL_CMD  := $$(curl --progress-bar -Lo kubectl ${KUBECTL_URL} && chmod +x kubectl && sudo mv kubectl /usr/local/bin/)

define test
cd $(1) && go test -v
endef

define cross_build
mkdir -p ./bin;
GOOS=$(1) GOARCH=$(2) CGO_ENABLED=0 go build -o bin/$(PKG)_$(1)_$(2) -a -tags "static_build $(PKG)" -installsuffix $(PKG) ${GO_LDFLAGS_STATIC};
endef

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: minikube_install
minikube_install: ## Install minikube
	@echo "==> Checking Minikube installed - installing if not..."
	@$(if $(shell which minikube),,$(MINIKUBE_INSTALL_CMD))
	@echo "==> Minikube $$(minikube version) installed..."

.PHONY: kubectl_install
kubectl_install: ## Install kubectl
	@echo "==> Checking Kubectl installed - installing if not..."
	@$(if $(shell which kubectl),,$(KUBECTL_INSTALL_CMD))
	@echo "==> Kubectl $$(kubectl version) installed..."

.PHONY: preflight_checks
preflight_checks: minikube_install kubectl_install

.PHONY: minikube_start
minikube_start: preflight_checks ## Start minikube
	@echo '==> Starting Minikube with the "$(MINIKUBE_DRIVER)" driver'
	@minikube start --vm-driver=$(MINIKUBE_DRIVER)

.PHONY: minikube_stop
minikube_stop: ## Stop minikube
	@echo "==> Stopping Minikube..."
	@minikube stop

.PHONY: minikube_dashboard
minikube_dashboard: ## Open Minikube dashboard
	@minikube dashboard

.PHONY: go_fmt
go_fmt: ## Run gofmt over all *.go files
	@echo "==> Running source files through gofmt..."
	@$(GOFMT_CMD)

.PHONY: test
test: ## Run tests
	@echo "==> Running tests..."
	@$(foreach TEST_DIR,$(TEST_DIRS),$(call test,$(TEST_DIR)))

.PHONY: build_app
build_app: ## Build Go binary for all GOARCH
	@echo "==> Building $(PKG) for all GOARCH/GOOS..."
	@$(foreach GOARCH,$(GOARCHS),$(foreach GOOS,$(GOOSES),$(call cross_build,$(GOOS),$(GOARCH))))

.PHONY: build_container
build_container: ## Build Docker container
	@eval $$(minikube docker-env) ; \
	echo "==> Building container..." ; \
	docker build -t "$(PKG):$(GITCOMMIT)" .

.PHONY: build
build: test build_app build_container ## Run tests, build application, build container

.PHONY: run_app
run_app: ## Run app in Minikube
	@echo "==> Running app $(PKG):$(GITCOMMIT)"
	@kubectl run $(PKG) --image=$(PKG):$(GITCOMMIT) --port=8080 --replicas=2
	@kubectl expose deployment $(PKG) --type=LoadBalancer
	@echo "==> Service exposed at $$(minikube service --url $(PKG))"

export
