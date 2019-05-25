# @afirth 2019-05

# USER CONFIG
git_username = afirth

# SERVICE CONFIG
#TODO
tld = alfirth.com
service_name = zeebecloud
service_level = rabbit
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

delete:
	gcloud container clusters delete $(cluster_name) --async

#TODO enable long-term-storage
#TODO fix ingress prompting
.PHONY: create
create:
	jx create cluster gke \
		--disk-size=20GB \
		--no-tiller --tekton --prow \
		--cluster-name=$(cluster_name) \
		--docker-registry-org=$(service_name) \
		--domain=$(domain)\
		--enable-autoupgrade=true \
		--enhanced-apis=true \
		--enhanced-scopes=true \
		--environment-git-owner=camunda-internal \
		--external-dns=true \
		--git-private=true \
		--long-term-storage=false \
		--machine-type='n1-standard-2' \
		--max-num-nodes=5 \
		--min-num-nodes=2 \
		--preemptible=true \
		--skip-login=true \
		--timeout='60' \
		--zone=$(zone) \
		--verbose

# unused:

		# --git-username=$(git_username) \
		# --project-id=$(project_id) \
      # --scope=[] \ The OAuth scopes to be added to the cluster
      # --ingress-class='' \ Used to set the ingress.class annotation in exposecontroller created ingress
      # --long-term-storage=false \ Enable the Long Term Storage option to save logs and other assets into a GCS bucket (supported only for GKE)
      # --lts-bucket='' \ The bucket to use for Long Term Storage. If the bucket doesn't exist, an attempt will be made to create it, otherwise random naming will be used
      # --urltemplate='' \ For ingress; exposers can set the urltemplate to expose
