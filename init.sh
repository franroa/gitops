#!/bin/bash

k3d cluster delete fran
k3d cluster create fran


# Working without helm releases
fluxctl install \
  --namespace flux \
  --git-url "git@github.com:franroa/gitops.git" \
  --git-user franroa \
  --git-email "franroa@users.noreply.github.com" | kubectl apply -f -


# TODO -> Sign commits with GPG


kubectl create ns flux

kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/1.2.0/deploy/crds.yaml

helm repo add fluxcd https://charts.fluxcd.io

helm install helm-operator fluxcd/helm-operator \
    -n flux \
    --set helm.versions=v3 \
    --set git.ssh.secretName=flux-git-deploy

# TODO -> helm repo vs git repo