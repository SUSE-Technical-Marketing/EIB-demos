#!/bin/bash
sudo podman run --rm --privileged -it -v $PWD:/eib registry.suse.com/edge/edge-image-builder:1.0.2 build --definition-file mgmt-cluster-singlenode.yaml

