#!/bin/bash

k3d cluster delete fran
k3d cluster create fran

helm repo add fluxcd https://charts.fluxcd.io

kubectl create ns flux

# Working without helm releases
fluxctl install \
  --namespace flux \
  --git-url "git@github.com:franroa/gitops.git" \
  --git-user franroa \
  --git-email "franroa@users.noreply.github.com" | kubectl apply -f -

# TODO -> Sign commits with GPG

kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/1.2.0/deploy/crds.yaml

helm repo add fluxcd https://charts.fluxcd.io

helm install helm-operator fluxcd/helm-operator \
    -n flux \
    --set helm.versions=v3 \
    --set git.ssh.secretName=flux-git-deploy

# TODO -> helm repo vs git repo

# Flagger does not support traefik
helm -n kube-system uninstall traefik
# Instead traefik, we will install ingress-ngnix

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Enable metrics for prometheus
helm install ingress-nginx ingress-nginx/ingress-nginx \
    -n kube-system \
    --set controller.metrics.enabled=true \
    --set-string controller.podAnnotations."prometheus\.io/scrape"=true \
    --set-string controller.podAnnotations."prometheus\.io/port"=10254

#kubectl -n kube-system get all -l "app.kubernetes.io/name=ingress-nginx"

helm repo add flagger https://flagger.app

helm install flagger flagger/flagger \
    -n kube-system \
    --set prometheus.install=true --set meshProvider=nginx

fluxctl identity --k8s-fwd-ns flux



#curl -s 172.22.0.2.nip.io | grep Version
#cat <<EOF >> helm/nginxhello-hr.yaml
#  values:
#    image:
#      tag: 1.19.1
#    ingress:
#      host: 172.22.0.2.nip.io
#EOF

#while true; do curl -s -o /dev/null http://172.22.0.2.nip.io; done &