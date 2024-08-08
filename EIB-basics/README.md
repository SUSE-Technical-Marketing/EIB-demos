# THIS IS A WIP, NOT FINISHED

# Edge Image Builder

## Intro
In this demo, we will show how EIB works, explaining the concepts, the structure, and how to use it. Long story short, EIB allows you to prepare a full stack deployment in an ISO image, enabling the deployment of a fully functional k3s or RKE2 cluster with the ISO without further configuration or internet connectivity. This simplifies the deployment of Kubernetes at the edge or Zero Touch Provisioning workflows like the one used in SUSE ATIP/Edge 3.0 leveraging CAPI and Metal3 to deploy on bare metal machines.

## The demo
Two config files are provided on this demo, these config files combined with EIB will deploy a single node of RKE2 or k3s running on top of SLE micro 5.5.

The first step is clonning the edge image builder on your computer, or if you are you the same settings than this demo you will be using a computer to run EIB and CoreDNS, also to be your desktop environment for the demos you the recommendation would be using openSUSE Tumbleweed. The repo for EIB is https://github.com/suse-edge/edge-image-builder.git, in there you can find the basic steps and all the info necessary to working with EIB, anyway we will describe step by step all. You need to install some packages in openSUSE before clonning the repo or using EIB. 

```
# Pre EIB packages

sudo zypper install -y git

sudo zypper install -y podman

sudo zypper install -y gpgme-devel device-mapper-devel libbtrfs-devel

# Clonning the repo

git clone https://github.com/suse-edge/edge-image-builder.git

```

Now the repo is ready to start working, go inside the folder and create a folder named ```eib```. After move inside the eib folder, and let's create the necessary structure for EIB to work. Create a ```_build``` folder where the builds and combustion will be created, a ```base-images``` folder, a ```kubernetes``` folder, and a```custom``` folder. Each one will host different content and have a different purpose. After the folders are created, and assuming a config file present we will end having an structure like this:

```
❯ tree
.
├── _build            ## logs, scripts and combustion
├── base-images       ## ISO or RAW images to build new isos
├── custom            ## Custom scripts to add to the config
├── eib-slm-k3s.yaml  ## Definition file 
├── eib-slm-rke2.yaml ## Definition file 
└── kubernetes        
    └── config        ## Extra configs for Kuberntes
        └── server.yaml

5 directories, 3 files

```

In the eib folder inside this repo you'll find a copy of the structure and two config files to configure SLE Micro 5.5 + RKE2 or k3s in an iso. If you copy this structure inside the ```edge-image-builder``` folder after clonning it you will be almost ready, just adding the ISO or RAW images you want to use in the ```base-images``` and you'll be set up. In this case you'll need SLE Micro 5.5 images. You can download them from the customer center, but if you want to turn this into an open source demo just download openSUSE Micro Leap from https://get.opensuse.org/leapmicro/5.5/ and modify the config files accordingly.
In the EIB repo you can find more options and different folders, for instance you can create a rpm folder where you can store rpm files that will be automatically installed once the OS is installed. But for now this is enough for our demo.
In the ```_build``` folder you'll find the EIB logs, the combustion files, and other scripts necessary to create your ISO images. All will be created by the EIB itself when you run it. In the ```base-images``` you have to store the OS ISOs or RAW files that you want to use with EIB. In this case we want to showcase SLE Micro and that's the images we've used. Inside ```kubernetes/config```. In the ```custom/scripts``` you can place combustion scripts that will be executed alongside the rest of the combustion scripts, helping the automation process.

Until now we have introduced EIB, its structure and the initial commands to install the software that EIB needs, set up the folders and clone EIB locally. Its time to start using it.
Following the [documentation](https://github.com/suse-edge/edge-image-builder?tab=readme-ov-file) now let's test podman and build the EIB container to start:
```
cd /home/suse-user/edge-image-builder

podman build -t eib:dev .
```
When it finishes the EIB pod will be ready to work.

```
suse-user@eib:~/edge-image-builder> podman image list
REPOSITORY                           TAG         IMAGE ID      CREATED       SIZE
localhost/eib                        dev         d0749f2ec232  6 days ago    991 MB
<none>                               <none>      86c067d36c46  6 days ago    629 MB
registry.suse.com/bci/golang         1.21        02b5275eb98f  12 days ago   520 MB
registry.opensuse.org/opensuse/leap  15.5        ec3c3c09f741  2 months ago  118 MB
docker.io/coredns/coredns            latest      cbb01a7bd410  6 months ago  61.2 MB
```
We have copied 2 SLE Micro images in the ```base-images``` folder before starting the process a kubernetes basic config ```server.yaml``` file and before running EIB to build the new image let's review the eib-slm-k3s.yaml and the server.yaml understand better what we are going to build.

```
suse-user@eib:~/edge-image-builder/eib> cat eib-slm-k3s.yaml 
                                                                          
apiVersion: 1.0
image:
  imageType: iso
  arch: x86_64
  baseImage: SLE-Micro.x86_64-5.5.0-Default-SelfInstall-GM.install.iso  # Name of the base image
  outputImageName: eib-k3s.iso   # Name of the output image
operatingSystem:
  isoConfiguration:
    installDevice: /dev/sda  # Where to install te OS
    unattended: true         # Unattended to avoid clicking around during installation (it is necessary to accept deleting /dev/sda)
  time:
    timezone: Europe/Paris
    ntp:                     # NTP config
      forceWait: true
      pools:
        - 2.suse.pool.ntp.org
  systemd:                   # We can init o stop systemd services from here
    enable:
      - cockpit.service
  keymap: us
  users:
    - username: root  # Create and configure root user, the password has been encrypted using openssl passwd -6 $PASSWD
      encryptedPassword: ${ROOT_PASSWORD}
      createHomeDir: true

    - username: suse-user
      encryptedPassword: ${USER_PASSWORD}
      sshKeys:
        - ${SSH_KEY}
      createHomeDir: true
      secondaryGroups:
        - wheel
  packages:                 # Packages to install and registration to the customer centerhttps://github.com/suse-edge/edge-image-builder/blob/main/docs/testing-guide.md
    sccRegistrationCode: INTERNAL-edjncvwen
kubernetes:                 # Kubernetes installation, just define the RKE2 or K3s version you want to install
  version: v1.27.4+k3s1
```
You can find more information about the config files [here](https://github.com/suse-edge/edge-image-builder/blob/main/docs/building-images.md) and you can find a complex example with most of the variants [here](https://github.com/suse-edge/edge-image-builder/blob/main/pkg/image/testdata/full-valid-example.yaml). 
Let's review now ther server.yaml, it's a simple but effective configuration.
```
suse-user@eib:~/edge-image-builder/eib> cat kubernetes/config/server.yaml 
write-kubeconfig-mode: "0644" # kubeconfig permissions
node-label:                   # node labeling
  - "foo=bar"
  - "something=amazing"
cluster-init: true            # Start the node
```
Before anything, replace the user passwords and SSH keys with your own. To generate the passwords properly you have to use the command ```openssl passwd -6 $PASSWORD``` in this manner EIB will configure your password correctly. You can use an ssh key for the root user if you use SLE Micro 5.5, however starting on SLE Micro 6.0 is not possible. 

Now we can run EIB container to build our own iso with preconfigured kubernetes.

```
podman run --rm -it \
-v $PWD:/eib registry.suse.com/edge/edge-image-builder:1.0.2 build \ 
--definition-file eib-slm-k3s.yaml \   # The path for config file is relative to the config dir
--config-dir /eib \                # The config dir is mounted in the pod in the /eib folder
--build-dir /eib/_build            # The PATH for the build content inside the /eib

Generating image customization components...
Identifier ................... [SUCCESS]
Custom Files ................. [SUCCESS]
Time ......................... [SUCCESS]
Network ...................... [SKIPPED]
Groups ....................... [SKIPPED]
Users ........................ [SUCCESS]
Proxy ........................ [SKIPPED]
Rpm .......................... [SKIPPED]
Systemd ...................... [SUCCESS]
Elemental .................... [SKIPPED]
Suma ......................... [SKIPPED]
Embedded Artifact Registry ... [SKIPPED]
Keymap ....................... [SUCCESS]
Configuring Kubernetes component...
Kubernetes ................... [SUCCESS]
Certificates ................. [SKIPPED]
Building ISO image...
Kernel Params ................ [SKIPPED]

Image build complete!

suse-user@eib:~/edge-image-builder> ll eib/eib-k3s.iso 
-rw-r--r-- 1 suse-user suse-user 1523056640 Mar 11 18:34 eib/eib-k3s.iso


```

The image is ready, now you can use the image in a USB unit or just use it virtualized. In this case we will use KVM which can be easily installed in openSUSE using YAST2-VM, if you need more information you can consult in [here](https://www.howtoforge.com/how-to-install-kvm-libvirt-virtualization-on-opensuse/). There is a small trick when using Virtual Machine Manager to make sure that the SLE Micro based images restart to apply the combustion files and configuration, if you don't follow [this guide](https://github.com/suse-edge/edge-image-builder/blob/main/docs/testing-guide.md) to make sure it works. If after installing the image you see a standard SLE Micro deployment or you don't see all the combustion changes applied before the login screen it didn't work.
nce the VM is live you can show to the demo audience that the VM is live and after the first install has all the configurations you defined in the config file and that k3s is up and running.


