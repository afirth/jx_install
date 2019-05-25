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
		--git-api-token=$(GIT_TOKEN) \
		--disk-size=20GB \
		--no-tiller --tekton \
		--cluster-name=$(cluster_name) \
		--docker-registry-org=$(service_name) \
		--domain=$(domain)\
		--enhanced-apis=true \
		--enhanced-scopes=true \
		--enable-autoupgrade=true \
		--external-dns=true \
		--git-private=true \
		--git-username=$(git_username) \
		--long-term-storage=false \
		--log-level=debug \
		--machine-type='n1-standard-2' \
		--max-num-nodes=5 \
		--min-num-nodes=2 \
		--preemptible=true \
		--project-id=$(project_id) \
		--skip-login=true \
		--timeout='60' \
		--zone=$(zone) \
		--verbose

.PHONY: install
install:
	jx install \
		--provider=gke \
		--git-api-token=$(GIT_TOKEN) \
		--no-tiller --tekton \
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
		#--environment-git-owner=camunda-internal \

# unused:

      # --scope=[] \ The OAuth scopes to be added to the cluster
		# --no-tiller --tekton --prow \
      # --ingress-class='' \ Used to set the ingress.class annotation in exposecontroller created ingress
      # --long-term-storage=false \ Enable the Long Term Storage option to save logs and other assets into a GCS bucket (supported only for GKE)
      # --lts-bucket='' \ The bucket to use for Long Term Storage. If the bucket doesn't exist, an attempt will be made to create it, otherwise random naming will be used
      # --urltemplate='' \ For ingress; exposers can set the urltemplate to expose
