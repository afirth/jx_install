# @afirth 2019-05

# USER CONFIG
git_username = afirth

# SERVICE CONFIG
#TODO
domain = ccdev.alfirth.com
service_name = cc
service_level = rabbit
project_id = camunda-cloud-240911
zone = europe-west1-d

# Generated config
cluster_name = $(service_name)-$(service_level)-$(zone)
#domain = $(cluster_name).$(tld)

# Make config
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
SHELL = /bin/bash
.SUFFIXES:

delete:
	gcloud container clusters delete $(cluster_name) --async

#TODO enable long-term-storage
#TODO fix ingress prompting
.PHONY: create
create:
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
		--verbose \
		--zone=$(zone) \

#BUG no-tiller jx/4082
.PHONY: init
init:
	JX_NO_TILLER=true \
	             jx init \
		--batch-mode \
		--install-dependencies \
		--provider=gke \
		--no-tiller=true \
		--log-level=debug \
		--domain=$(domain) \
		--verbose

.PHONY: install
install:
	jx install \
		--batch-mode \
		--buildpack='kubernetes-workloads' \
		--docker-registry-org=$(project_id) \
		--docker-registry="gcr.io" \
		--domain=$(domain) \
		--environment-git-owner=$(git_username) \
		--git-api-token=$(GIT_TOKEN) \
		--git-private=true \
		--git-username=$(git_username) \
		--gitops \
		--log-level=debug \
		--long-term-storage=false \
		--no-tiller \
		--provider=gke \
		--prow \
		--tekton \
		--timeout='60' \
		--vault \
		--verbose
