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
		--verbose
		--zone=$(zone) \
		--preemptible=true \
		--min-num-nodes=2 \
		--max-num-nodes=5 \
		--machine-type='n1-standard-2' \
		--log-level=debug \
		--project-id=$(project_id) \
		--skip-login=true \
		--enable-autoupgrade=true \
		--enhanced-scopes=true \
		--enhanced-apis=true \
		--cluster-name=$(cluster_name) \
		--disk-size=20GB \

init:
	jx init \
		--batch-mode \
		--provider=gke \
		--log-level=debug \
		--domain=$(domain) \
		--verbose

		--git-api-token=$(GIT_TOKEN) \
		\
		--log-level=debug \
		--verbose
		--buildpack='jenkins-x-kubernetes' \
		--gitops \
		--prow \
		--tekton \
		--docker-registry="gcr.io" \
		--docker-registry-org=$(project_id) \
		
		--ng \
		--git-private=true \
		--git-username=$(git_username) \
		--environment-git-owner=afirth \
		--long-term-storage=false \
		--timeout='60' \

.PHONY: install
install:
	jx install \
		--provider=gke \
		--git-api-token=$(GIT_TOKEN) \
		--tekton \
		--docker-registry-org=$(service_name) \
		--domain=$(domain)\
		--external-dns=true \
		--git-private=true \
		--git-username=$(git_username) \
		--log-level=debug \
		--long-term-storage=false \
		--timeout='60' \
		--verbose

#TODO need org/orgadmin?

# unused:

      # --scope=[] \ The OAuth scopes to be added to the cluster
		# --no-tiller --tekton --prow \
      # --ingress-class='' \ Used to set the ingress.class annotation in exposecontroller created ingress
      # --long-term-storage=false \ Enable the Long Term Storage option to save logs and other assets into a GCS bucket (supported only for GKE)
      # --lts-bucket='' \ The bucket to use for Long Term Storage. If the bucket doesn't exist, an attempt will be made to create it, otherwise random naming will be used
      # --urltemplate='' \ For ingress; exposers can set the urltemplate to expose
