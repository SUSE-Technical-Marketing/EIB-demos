# Intructions

Clone EIB repo and inside the repo copy the eib folder you'll find inside this one.

What you can find in here? 
```
.
├── custom
│   ├── 80-k3s-post-install.sh
│   ├── files
│   │   ├── k9s
│   │   └── k9s_Linux_amd64.tar.gz
│   └── scripts
│       └── 70-tools.sh
├── eib-k3s-helm.yaml
├── kubernetes
│   ├── config
│   │   └── server.yaml
│   └── helm
│       └── values
│           └── ollama_values.yaml
├── network
│   └── eibnode.suse.lan.yaml
└── rpms
    └── gpg-keys
        └── rancher-public.key

10 directories, 9 files

```

In the ../custom/scripts/ you find a basic configuration script for the files containes in the files folder, and outside you have a script that configures access to k3s adfter the installation. These are combustion scripts, and for combustion there are priorities to run scripts, the higher the number the lower the priority. These scripts starting with 70 and 80 will run the last ones. 

** NOTE: Notice that the custom content to install and configure the k9s cli is not prersent in the repo because of the size, other than that the repo works as it is. **

The file eib-k3s-helm.yaml is the definition file file for EIB, in this file you provide the OS configuration, the basic k8s configuation and source to build the ISO image.

In the ../kubernetes/ folder you find two subfodlers, config and helm. In the config file you find a file named server.yaml, in this file you can provide all the parameters for k3s or RKE2. In side ../kubernetes/hel/values/ you'll find a file for each helm chart you want to install, on each you have to provide the values to properly install each hel chart. In this case the values to install ollama on top of k3s.

Inside network you have to provide the nextwork configuration. There'll be a configuration file for each node, and the names of the configuration files have to match the hostnames defined in the definition file. With EIB you can deploy single node and multi-node kubernetes.

Last but not least the rpms folder, you have to provide gpg-keys and rpm packages you want to install. 

From inside the EIB folder run the next command:

```
podman run --privileged --rm -it -v $PWD:/eib registry.suse.com/edge/edge-image-builder:1.0.1 build --definition-file ./eib-k3s-helm.yaml

```

the process will create the ISO image.


Important links:

- https://suse-edge.github.io/components-eib.html

- https://github.com/suse-edge/edge-image-builder
