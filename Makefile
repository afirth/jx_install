# @afirth 2019-05

# USER CONFIG
# MUST EXPORT or set
git-token ?= $(JX_GIT_TOKEN)
domain ?= $(JX_DOMAIN)

# SERVICE CONFIG
service_name := cc
service_level := wombat

git_username := $(shell git config user.name)
project_id := $(shell gcloud config get-value project)
zone := $(shell gcloud config get-value compute/zone)

# Generated config
cluster_name := $(service_name)-$(service_level)-$(zone)

# Make config
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
SHELL = /bin/bash
.SUFFIXES:

.PHONY: validate
validate:
	@echo $(git-token) | grep -q '.'
	@echo $(domain) | grep -q '.'

.PHONY: delete
delete:
	gcloud container clusters delete $(cluster_name) --async

#TODO enable long-term-storage
#TODO fix ingress prompting
.PHONY: create
create: validate
	jx create cluster gke \
		--batch-mode \
		--cluster-name=$(cluster_name) \
		--disk-size=20GB \
		--enable-autoupgrade=true \
		--enhanced-apis=true \
		--enhanced-scopes=true \
		--log-level=debug \
		--machine-type='n1-standard-2' \
		--max-num-nodes=5 \
		--min-num-nodes=2 \
		--preemptible=true \
		--project-id=$(project_id) \
		--skip-login=true \
		--skip-installation=true \
		--skip-ingress=true \
		--skip-cluster-role=true \
		--skip-setup-tiller=true \
		--verbose \
		--zone=$(zone) \

#BUG no-tiller jx/4082
#BUG namespace jx isn't created
.PHONY: init
init: validate
	JX_NO_TILLER=true \
	jx init \
		--batch-mode \
		--install-dependencies \
		--provider=gke \
		--no-tiller=true \
		--log-level=debug \
		--domain=$(domain) \
		--verbose
	kubectl create namespace jx

.PHONY: install
install: validate
	JX_NO_TILLER=true \
	jx install \
		--batch-mode \
		--buildpack='kubernetes-workloads' \
		--docker-registry-org=$(project_id) \
		--docker-registry="gcr.io" \
		--domain=$(domain) \
		--environment-git-owner=$(git_username) \
		--git-api-token=$(git-token) \
		--git-private=true \
		--git-username=$(git_username) \
		--install-dependencies \
		--log-level=debug \
		--long-term-storage=false \
		--no-tiller \
		--provider=gke \
		--prow \
		--tekton \
		--timeout='60' \
		--verbose
	
.PHONY: ingress
ingress: validate
	JX_NO_TILLER=true \
	jx upgrade ingress --cluster

unused:
		--gitops \
		--vault \
