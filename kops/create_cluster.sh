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

echo "Installing nginx-ingress controller charts"
sleep 10
kubectl create ns kube-ingress
helm repo update
helm install nginx-ingress stable/nginx-ingress --namespace kube-ingress

echo "Charts installed."


echo "Creating service account for Jenkins..."
kubectl -n default create serviceaccount jenkins-capstone
kubectl -n default create rolebinding jenkins-capstone-binding --clusterrole=cluster-admin --serviceaccount=default:jenkins-capstone

account_token_name="$(kubectl -n default get serviceaccount jenkins-capstone -o go-template --template='{{range .secrets}}{{.name}}{{"\n"}}{{end}}')"
access_token="$(kubectl -n default get secrets $account_token_name -o go-template --template '{{index .data "token"}}' | base64 -d)"

echo "A service account has been generated for you. Use the following secret text to create/update the txt secret in Jenkins:

$access_token

"

api_lb_name="$(aws elb describe-load-balancers | jq -r '.LoadBalancerDescriptions[].LoadBalancerName' | grep -e "^api-$CLUSTER_NAME")"
api_lb_dnsName="$(aws elb describe-load-balancers --load-balancer-names $api_lb_name | jq -r '.LoadBalancerDescriptions[].DNSName')"

ingress_dnsName="$(kubectl get service -n kube-ingress nginx-ingress-controller -o go-template --template '{{(index .status.loadBalancer.ingress 0).hostname}}{{"\n"}}')"

echo "Find below the DNS Names to access the cluster: 

Kubernetes API url = https://$api_lb_dnsName
Ingress controller URL = http://$ingress_dnsName

"
echo "Done."
