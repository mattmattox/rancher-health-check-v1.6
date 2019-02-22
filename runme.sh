#!/bin/bash
docker run --privileged --rm -it -v /var/run/docker.sock:/var/run/docker.sock cube8021/rancher-health-check-v1.6
