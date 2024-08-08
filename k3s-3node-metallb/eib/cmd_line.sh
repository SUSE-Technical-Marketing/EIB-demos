#!/bin/bash
podman run --privileged --rm -it -v $PWD:/eib registry.suse.com/edge/edge-image-builder:1.0.2 build --definition-file ./eib-k3s-3node.yaml
