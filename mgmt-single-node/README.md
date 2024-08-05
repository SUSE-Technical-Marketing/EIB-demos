
# Management Cluster in a single-node setup


## Intro
The main idea of this repo is helping you to build an ISO image that allows you to deploy a management cluster for SUSE ATIP or SUSE Edge in a simple manner. However, you can use this resources to deploy a Rancher management cluster running on SLE Micro just adapting the configuration. We will use Edge Image Builder or EIB to do so.

## Structure

What you can see is the structure to build with EIB the ISO image needed to deploy the single node RKE2 with Rancher on top with all the bits and pieces to use CAPI and Metal3 to deploy and manage downstream clusters. Also we create a systemd service to make sure that if the node reboots the management layer will be up and running as soon as possible.

```
.
├── custom
│   ├── files
│   │   ├── basic-setup.sh
│   │   ├── metal3.sh
│   │   ├── mgmt-stack-setup.service
│   │   └── rancher.sh
│   └── scripts
│       ├── 99-alias.sh
│       ├── 99-mgmt-setup.sh
│       └── 99-register.sh
├── kubernetes
│   ├── config
│   │   └── server.yaml
│   ├── helm
│   │   └── values
│   │       ├── certmanager.yaml
│   │       ├── metal3.yaml
│   │       ├── neuvector.yaml
│   │       └── rancher.yaml
│   └── manifests
│       └── neuvector-namespace.yaml
├── mgmt-cluster-singlenode.yaml
└── network
    └── mgmt-cluster-network.yaml

9 directories, 15 files

```

This is an example of using Edge Image Builder (EIB) to generate a management cluster iso image for SUSE ATIP. The management cluster will contain the following components:
- SUSE Linux Enterprise Micro 5.5 Kernel (SLE Micro)
- RKE2
- CNI plugins (e.g. Multus, Cilium)
- Rancher Prime
- Neuvector
- Longhorn
- Static IPs or DHCP network configuration
- Metal3 and the CAPI provider

This article is oriented for ATIP. However, you can modify which components you want to install. You can install just RKE2 with Cilium and Rancher Prime if you are building a lab or a test environment.

Before creating the ISO with EIB, is necessary to modify the following values in the `mgmt-cluster-singlenode.yaml` file:

- `${ROOT_PASSWORD}` - The root password for the management cluster. This could be generated using `openssl passwd -6 PASSWORD` and replacing PASSWORD with the desired password, and then replacing the value in the `mgmt-cluster-singlenode.yaml` file. The final rancher password will be configured based on the file `custom/files/basic-setup.sh`.

- `${USER_PASSWORD}` - The suse-user password for the management cluster. This could be generated using `openssl passwd -6 PASSWORD` and replacing PASSWORD with the desired password, and then replacing the value in the `mgmt-cluster-singlenode.yaml` file. SLE Micro 6.0 doesn't allow ssh login as root user, always is best having a user that is not root for rutinary OS maintenance.

- `${SCC_REGISTRATION_CODE}` - The registration code for the SUSE Customer Center for the SLE Micro product. This could be obtained from the SUSE Customer Center and replacing the value in the `mgmt-cluster-singlenode.yaml` file.

- `${KUBERNETES_VERSION}` - The version of kubernetes to be used in the management cluster (e.g. `v1.28.8+rke2r1`).

You need to modify the following values in the `network/mgmt-cluster-network.yaml` file :

- `${MGMT_GATEWAY}` - This is the gateway IP of your management cluster network.
- `${MGMT_DNS}` - This is the DNS IP of your management cluster network.
- `${MGMT_CLUSTER_IP}` - This is the static IP of your management cluster single node.
- `${MGMT_MAC}` - This is the MAC address of your management cluster node.

You need to modify the `${MGMT_CLUSTER_IP}` with the Node IP in the following files:

- `kubernetes/helm/values/metal3.yaml`

- `kubernetes/helm/values/rancher.yaml`

You need to modify the following values in the `custom/scripts/99-register.sh` file:

- `${SCC_REGISTRATION_CODE}` - The registration code for the SUSE Customer Center for the SL Micro product. This could be obtained from the SUSE Customer Center and replacing the value in the `99-register.sh` file.

- `${SCC_ACCOUNT_EMAIL}` - The email address for the SUSE Customer Center account. This could be obtained from the SUSE Customer Center and replacing the value in the `99-register.sh` file.

You need to modify the following folder:

- `base-images` - To include inside the `SLE-Micro.x86_64-5.5.0-Default-SelfInstall-GM2.install.iso` and  `SL-Micro.x86_64-6.0-Default-SelfInstall-GM.install.iso` images downloaded from the SUSE Customer Center.

## Optional modifications

### Add certificates to use HTTPS server to provide images using TLS

This is an optional step to add certificates to the management cluster to provide images using HTTPS Server (Helm Chart metal3 Version >= 0.7.1)

1. Modify the `kubernetes/helm/values/metal3.yaml` file to set to true the following value in the global section:

```yaml
global:
  additionalTrustedCAs: true
```

2. If you are deploying a mgmt-cluster from scratch using EIB, then add the secret to the manifests folder `kubernetes/manifests/metal3-cacert-secret.yaml` to automate the creation of the secret in the management cluster:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: metal3-system
---
apiVersion: v1
kind: Secret
metadata:
  name: tls-ca-additional
  namespace: metal3-system
type: Opaque
data:
  ca-additional.crt: {{ additional_ca_cert | b64encode }}
```

3. If you want to add the secret manually, then you can use the following command to create the secret:

```bash
kubectl -n meta3-system create secret generic tls-ca-additional --from-file=ca-additional.crt=./ca-additional.crt
```

where the ca-additional.crt is the certificate file that you want to use to provide images using HTTPS.

## Building the Management Cluster Image using EIB

1. Clone this repo and navigate to the `telco-examples/mgmt-cluster/single-node/eib` directory.

2. Modify the files described above.

3. The following command has to be executed from the parent directory where you have the `eib` directory cloned from this example (`mgmt-cluster`).

```
$ cd mgmt-cluster/single-node
$ sudo podman run --rm --privileged -it -v $PWD:/eib \
registry.suse.com/edge/edge-image-builder:1.0.2 \
build --definition-file mgmt-cluster-singlenode.yaml
```

## Deploy the Management Cluster

Once you have the iso image built using EIB into the `eib` folder, you can use it to be deployed on a VM or a baremetal server.
