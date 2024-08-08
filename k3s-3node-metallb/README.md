# Intructions

Clone EIB repo and inside the repo copy the eib folder you'll find inside this one.

What you can find in here? 
```
.
├── README.md
└── eib
    ├── cmd_line.sh
    ├── custom
    │   └── scripts
    │       └── 80-k3s-post-install.sh
    ├── eib-k3s-3node.yaml
    ├── kubernetes
    │   └── config
    │       └── server.yaml
    ├── network
    │   ├── node1.edge.demo.yaml
    │   ├── node2.edge.demo.yaml
    │   └── node3.edge.demo.yaml
    └── rpms
        └── gpg-keys
            └── rancher-public.key

8 directories, 9 files

```

In the ../custom/scripts/ you find a basic configuration script for the files containes in the files folder, and outside you have a script that configures access to k3s adfter the installation. These are combustion scripts, and for combustion there are priorities to run scripts, the higher the number the lower the priority. These scripts starting with 70 and 80 will run the last ones. 

**NOTE: Notice that the custom content to install and configure the k9s cli is not prersent in the repo because of the size, other than that the repo works as it is.**

The file eib-k3s-helm.yaml is the definition file file for EIB, in this file you provide the OS configuration, the basic k8s configuation and source to build the ISO image.

In the ../kubernetes/ folder you find two subfodlers, config and helm. In the config file you find a file named server.yaml, in this file you can provide all the parameters for k3s or RKE2. In side ../kubernetes/hel/values/ you'll find a file for each helm chart you want to install, on each you have to provide the values to properly install each hel chart. In this case the values to install ollama on top of k3s.

Inside network you have to provide the nextwork configuration. There'll be a configuration file for each node, and the names of the configuration files have to match the hostnames defined in the definition file. With EIB you can deploy single node and multi-node kubernetes.

Last but not least the rpms folder, you have to provide gpg-keys and rpm packages you want to install. 

**NOTE: Before running podman + EIB to build your ISO image take into account that you have to review the definition file and the networking configuration to change the parameters to adapt to your network configuration and to customize the OS to your ssh keys and passwords.**

Parameters and vars to review:

- `${ROOT_PASSWORD}` - The root password for the management cluster. This could be generated using `openssl passwd -6 PASSWORD` and replacing PASSWORD with the desired password, and then replacing the value in the `mgmt-cluster-singlenode.yaml` file, this is the OS password.

- `${USER_PASSWORD}` - The suse-user password for the management cluster. This could be generated using `openssl passwd -6 PASSWORD` and replacing PASSWORD with the desired password, and then replacing the value in the `mgmt-cluster-singlenode.yaml` file. SLE Micro 6.0 doesn't allow ssh login as root user, always is best having a user that is not root for rutinary OS maintenance.

- `${SCC_REGISTRATION_CODE}` - The registration code for the SUSE Customer Center for the SLE Micro product. This could be obtained from the SUSE Customer Center and replacing the value in the `mgmt-cluster-singlenode.yaml` file.

You need to modify the following values in the `network/mgmt-cluster-network.yaml` file :

- `${NODE_GATEWAY}` - This is the gateway IP of your management cluster network.
- `${NODE_DNS}` - This is the DNS IP of your management cluster network.
- `${NODE_IP}` - This is the static IP of your management cluster single node.
- `${NODE_MAC}` - This is the MAC address of your management cluster node.

After replacing these values you can proceeded to build the ISO image.

From inside the EIB folder run the next command:

```
podman run --privileged --rm -it -v $PWD:/eib registry.suse.com/edge/edge-image-builder:1.0.1 build --definition-file ./eib-k3s-helm.yaml

```

the process will create the ISO image.

**NOTE: To use different versions of EIB you need to change the version of the EIB container, in this case we use the versions 1.0.1**


Important links:

- https://suse-edge.github.io/components-eib.html

- https://github.com/suse-edge/edge-image-builder
