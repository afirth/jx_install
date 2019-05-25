# @afirth 2019-05

# USER CONFIG
git_username = afirth

# SERVICE CONFIG
#TODO
tld = alfirth.com
service_name = zeebecloud
service_level = sandbox
project_id = camunda-cloud-240911
zone = europe-west1-d

# Generated config
cluster_name = $(service_name)-$(service_level)-$(zone)
domain = $(cluster_name).$(tld)

# Make config
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
SHELL = /bin/bash
.SUFFIXES:

#TODO enable long-term-storage
#TODO fix ingress prompting
.PHONY: create
create:
	jx create cluster gke \
		--disk-size=20GB \
		--gitops --vault --no-tiller --tekton --prow \
		--cluster-name=$(cluster_name) \
		--docker-registry-org=$(service_name) \
		--domain=$(domain)\
		--enable-autoupgrade=true \
		--enhanced-apis=true \
		--enhanced-scopes=true \
		--environment-git-owner=camunda-internal \
		--exposer=ingress \
		--external-dns=true \
		--git-private=true \
		--git-username=$(git_username) \
		--ingress-cluster-role='cluster-admin' \
		--long-term-storage=false \
		--machine-type='n1-standard-2' \
		--max-num-nodes=5 \
		--min-num-nodes=2 \
		--namespace='jx' \
		--preemptible=true \
		--project-id=$(project_id) \
		--skip-login=true \
		--timeout='60' \
		--user-cluster-role='cluster-admin' \
		--zone=$(zone) \
		--verbose

# unused:
      # --scope=[] \ The OAuth scopes to be added to the cluster
      # --ingress-class='' \ Used to set the ingress.class annotation in exposecontroller created ingress
      # --long-term-storage=false \ Enable the Long Term Storage option to save logs and other assets into a GCS bucket (supported only for GKE)
      # --lts-bucket='' \ The bucket to use for Long Term Storage. If the bucket doesn't exist, an attempt will be made to create it, otherwise random naming will be used
      # --urltemplate='' \ For ingress; exposers can set the urltemplate to expose
