# Rancher Health Check for v1.6

This script was created to help with troubleshooting issues with Rancher servers running v1.6.x

# Getting Started

As root run the following command on all Rancher servers.

docker run --privileged --rm -it -v /var/run/docker.sock:/var/run/docker.sock cube8021/rancher-health-check-v1.6

## Supported Operating Systems
+ CentOS 7.6.1810
+ Ubuntu 16.04.5 LTS
+ Ubuntu 18.04.1 LTS
