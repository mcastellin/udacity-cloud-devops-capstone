#!/bin/bash -e

usage_string="
Deploys a cloudformation stack. Usage: ./deploy_stack.sh stack_name template_file.yaml [options]

stack_name:         the name of the stack that will be deployed in AWS
template_file:      the path to the template body file with cloudformation configuration
options:            additional parameters for the cloudformation create/update command

"
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
# params: stackName templateFile 
function deploy_stack() {
    operation=$(stack_op $1)

    stack_name=$1
    template=$2
    shift 2

    aws cloudformation $operation-stack --stack-name $stack_name \
        --template-body file://$template \
        "$@" \
        | jq

    echo "Waiting for stack $stack_name to deploy..."
    aws cloudformation wait stack-$operation-complete --stack-name $stack_name
}

if [ -z "$1" ]; then
    echo "stackname invalid"
    echo "$usage_string"
    exit 1
fi

if [ ! -f "$2" ]; then
    echo "$2 is not a regular file. Cannot use as a stack template."
    echo "$usage_string"
    exit 1
fi

echo "Deploying stack $1..." 
deploy_stack $@

echo "Done."

