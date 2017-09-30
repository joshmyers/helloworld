.DEFAULT_GOAL := help

GITCOMMIT            := $(shell git rev-parse --short HEAD)
GITUNTRACKEDCHANGES  := $(shell git status --porcelain --untracked-files=no)
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

define test
cd $(1) && go test -v
endef

define cross_build
mkdir -p ./bin;
GOOS=$(1) GOARCH=$(2) CGO_ENABLED=0 go build -o bin/$(PKG)_$(1)_$(2) -a -tags "static_build $(PKG)" -installsuffix $(PKG) ${GO_LDFLAGS_STATIC};
endef

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

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

export
