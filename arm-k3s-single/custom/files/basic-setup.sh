#!/bin/bash
# Pre-requisites. Cluster already running
export KUBECTL="/var/lib/rancher/k3s/bin/kubectl"
export KUBECONFIG="/etc/rancher/k3s/k3s.yaml"

die(){
  echo ${1} 1>&2
  exit ${2}
}

