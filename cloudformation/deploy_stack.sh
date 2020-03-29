#!/bin/bash

valid_stack_statuses="UPDATE_COMPLETE CREATE_COMPLETE ROLLBACK_COMPLETE UPDATE_ROLLBACK_COMPLETE"
function stack_op() {
    result=$(aws cloudformation list-stacks --stack-status-filter $valid_stack_statuses | jq -r ".StackSummaries[].StackName" | grep -e "^$1\$")

    if [ -z "$result" ]; then
       echo 'create'
    else
       echo 'update'
    fi
}

# Deploys a stack to AWS
# params: stackName templateFile paramsFile
function deploy_stack() {
    operation=$(stack_op $1)

    aws cloudformation $operation-stack --stack-name $1\
        --template-body file://$2 \
        --parameters file://$3 \
        | jq

    echo "Waiting for stack $1 to deploy..."
    aws cloudformation wait stack-$operation-complete --stack-name $1
}

stackname="$1"
template_file="$1.yaml"
parameters_file="$1-params.json"

if [ -z "$1" ]; then
    echo "stackname invalid"
    exit 1
fi

echo "Deploying stack $stackname ..." 
deploy_stack $stackname \
    cloudformation/$template_file \
    cloudformation/$parameters_file

echo "Done."

