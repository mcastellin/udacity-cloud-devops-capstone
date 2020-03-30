#!/bin/bash 

# Set evironment variables to operate kops
. ./set_env.sh

kops replace -f ${KOPS_CLUSTER_NAME}.yaml
kops update cluster --yes
kops rolling-update cluster --yes
