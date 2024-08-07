#!/bin/bash
# combustion: network
# script generated with https://opensuse.github.io/fuel-ignition/

# Redirect output to the console
exec > >(exec tee -a /dev/tty0) 2>&1

mkdir -p "/home/suse-user/.kube/" && touch /home/suse-user/.kube/config
cat /etc/rancher/k3s/k3s.yaml > /home/suse-user/.kube/config
echo "export KUBECONFIG=/home/suse-user/.kube/config" >> .bashrc
echo "export PATH=$PATH:/opt/bin" >> .bashrc
echo "alias k=kubectl" >> .bashrc
echo "hello combustion"
# Leave a marker
echo "Configured with combustion" > /etc/issue.d/combustion