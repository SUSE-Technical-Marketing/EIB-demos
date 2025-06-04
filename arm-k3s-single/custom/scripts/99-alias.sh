#!/bin/bash
echo "alias k=kubectl" >> /etc/profile.local
echo "alias kubectl=/var/lib/rancher/k3s/bin/kubectl" >> /etc/profile.local
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> /etc/profile.local
