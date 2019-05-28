#!/usr/bin/env bash

# this starts a local tiller service with secret storage driver, then runs helm commands against it
# setting $TILLER_NAMESPACE is strongly recommended
# usage: ./helm.sh <valid helm args>
# afirth 2019
# inspired by https://rimusz.net/tillerless-helm
set -eu -o pipefail

# default to use if TILLER_NAMESPACE is not set
# kube-system (the default) is not a great idea
# but you can export TILLER_NAMESPACE=kube-system if you like
default_namespace=tiller

#the default
tport=44134

# create tiller-namespace if it doesn't exist (helm --init would usually do this with server-side tiller'
set +u
if [ -z "$TILLER_NAMESPACE" ]; then
  echo "\$TILLER_NAMESPACE is empty. USING $default_namespace."
  export TILLER_NAMESPACE=$default_namespace
else
  kubectl get namespace $TILLER_NAMESPACE || \
    (echo "Creating tiller namespace $TILLER_NAMESPACE" && \
    kubectl create namespace $TILLER_NAMESPACE)
fi
set -u

#inherits TILLER_NAMESPACE
tiller --storage=secret --listen localhost:44134 &

#wait for tiller to start
while ! echo exit | nc localhost $tport; do sleep 1; done

export HELM_HOST=localhost:$tport

helm "$@"

exitCode=$?
pkill tiller || echo "unable to kill tiller"
exit $exitCode
