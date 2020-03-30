#!/bin/bash 

# Set evironment variables to operate kops
. ./set_env.sh

kops create -f ${KOPS_CLUSTER_NAME}.yaml
echo "Using default ssh public key for ssh access to the cluster ~/.ssh/id_rsa.pub"
kops create secret --name ${KOPS_CLUSTER_NAME} sshpublickey admin -i ~/.ssh/id_rsa.pub
kops update cluster --yes

echo "Waiting for cluster to be operational..." 

sleep_interval=20
until kops validate cluster ; do
    echo "\nRetrying validation in ${sleep_interval}s"
    sleep $sleep_interval
done

echo "\nCluster ready!"
