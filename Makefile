#!/usr/bin/make -f

BIN_DIR ?= $(GOPATH)/bin
BUILD_DIR ?= $(CURDIR)/build
PROJECT_NAME = $(shell git remote get-url origin | xargs basename -s .git)
COVER_FILE ?= cover.out

###############################################################################
###                               build                                     ###
###############################################################################

build: tidy
	@go build -o $(BUILD_DIR)/ ./...

run: tidy
	@go run .

tidy:
	@go mod tidy

.PHONY: build run tidy

###############################################################################
###                                Testing                                  ###
###############################################################################

test:
	@go test ./... -race -v

###############################################################################
###                                Linting                                  ###
###############################################################################

lint:
	@echo "--> Running linter"
	@go run github.com/golangci/golangci-lint/cmd/golangci-lint run --out-format=tab

lint-fix: format
	@echo "--> Running linter"
	@go run github.com/golangci/golangci-lint/cmd/golangci-lint run --fix --out-format=tab --issues-exit-code=0

lint-markdown:
	@echo "--> Running markdown linter"
	@markdownlint **/*.md

govulncheck:
	@echo "--> Running govulncheck"
	@go run golang.org/x/vuln/cmd/govulncheck -test ./...

.PHONY: lint lint-fix lint-markdown govulncheck

###############################################################################
###                                Formatting                               ###
###############################################################################

format:
	@find . -name '*.go' -type f -not -path "*.git*" -not -path "*/mocks/*" -not -name '*.pb.go' -not -name '*.pulsar.go' -not -name '*.gw.go' | xargs go run mvdan.cc/gofumpt -w .
	@find . -name '*.go' -type f -not -path "*.git*" -not -path "*/mocks/*" -not -name '*.pb.go' -not -name '*.pulsar.go' -not -name '*.gw.go' | xargs go run github.com/client9/misspell/cmd/misspell -w
	@find . -name '*.go' -type f -not -path "*.git*" -not -path "/*mocks/*" -not -name '*.pb.go' -not -name '*.pulsar.go' -not -name '*.gw.go' | xargs go run golang.org/x/tools/cmd/goimports -w -local  github.com/blockpane/pvtop

.PHONY: format
