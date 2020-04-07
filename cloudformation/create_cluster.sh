#!/bin/bash -e

stackName=capstone-eks
clusterName=capstone

./deploy_stack.sh $stackName eks-cluster.yaml --capabilities CAPABILITY_NAMED_IAM
sleep 10

echo "Backing up kubect config and replacing with new cluster configuration"
mv ~/.kube/config ~/.kube/_config
aws eks update-kubeconfig --name $clusterName

echo "Installing nginx-ingress controller charts"
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

api_lb_dnsName="$(aws eks describe-cluster --name $clusterName| jq -r '.cluster.endpoint')"
ingress_dnsName="$(kubectl get service -n kube-ingress nginx-ingress-controller -o go-template --template '{{(index .status.loadBalancer.ingress 0).hostname}}{{"\n"}}')"

echo "Find below the DNS Names to access the cluster: 

Kubernetes API url = $api_lb_dnsName
Ingress controller URL = http://$ingress_dnsName

"
echo "Done."
