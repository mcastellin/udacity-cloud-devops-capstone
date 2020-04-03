#!/bin/bash

export AWS_REGION="us-west-2"
export KOPS_ZONES="us-west-2a"
export CLUSTER_NAME="mcastellin-capstone"
export KOPS_CLUSTER_NAME="mcastellin-capstone.k8s.local"
export KOPS_STATE_STORE="s3://${KOPS_CLUSTER_NAME}-state-store"

echo "KOPS_CLUSTER_NAME: $KOPS_CLUSTER_NAME"
echo "KOPS_STATE_STORE: $KOPS_STATE_STORE"

echo "If you haven't created the state store bucket yet, you can run the following:\n" 
echo "  aws s3api create-bucket --bucket ${KOPS_CLUSTER_NAME}-state-store --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION"
