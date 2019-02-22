#!/bin/bash
docker build -t rancher-hc-v16 .
docker run --privileged --rm -it -v /var/run/docker.sock:/var/run/docker.sock rancher-hc-v16

