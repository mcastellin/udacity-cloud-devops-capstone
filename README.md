# Udacity Cloud DevOps Nanodegree Capstone Project
In this project combines all the skills learned in the Udacity's Cloud DevOps nanodegree program to build
an automated CI-CD pipeline that deploys a Python application into a Kubernetes cluster hosted in AWS.

Every code change pushed into this repository is validated by a Jenkins pipeline. 
The `master` branch is considered the desired state of the deployed application and as soon as all validation steps
are a pass, the application is deployed into the Kubernetes cluster in a Blue-Green fashion.
Below are the stages the application has to pass that lead to a successful deployment:

- Static code validation (linting): python, html and Dockerfiles
- Build and unit testing run
- Docker container build
- Integration testing

When all the checks above complete successfully for the `master` branch, the container is promoted to **release candidate**
and a deployment is attempted:

- Push container to Docker registry
- Create a *blue* or *green* deployment in Kubernetes
- Smoke testing to validate and warm up the new deployment
- Promote successful release and publish


## TODOs
- [ ] Add readyness probe in frontend with the /health url
- [ ] Update instructions to create cluster to include creation of ingress nginx
- [ ] add smoke test script to validate deployment before switching service
- [ ] enable prometheus monitoring, should collect metrics of api pods
- [ ] configure autoscaling group based on prometheus monitoring for throughput
- [ ] for security configure an account with programmatic access to manage AWS resources 
- [ ] security scan for the container? 
- [ ] run container as non root user
- [ ] read this page https://kubernetes.io/docs/concepts/security/overview/
- [ ] prometheus alerting can send webhooks too. can we use it to scale something? 
- [ ] write smoke tests


## The Application

For this project I want to operationalise a simple API developed in Python.
The API interface will be browsable with swagger.

### High Availability

The application is designed for high availability. Kubernetes cluster has three nodes hosted in EC2 instances
covering different AZs (Availability Zones) in the AWS VPC.

TODO: 
- [ ] update cluster to run with three nodes when all is ready
- [ ] figure out how I can provide the VPC and subnets to Kops to host in my own network infrastructure

### Scalability

By running the application with the Kubernetes orchestrator we can take advantage of its autoscaling capabilities. 
The application is configured to autoscale so that every node maintain optimal level of load and request throughput.

When the load increses the application is horizontally scaled in the cluster by deploying more containers and
scaled down to one running container in the same fashion when the load decreses.

TODO: 
- [ ] simulate application load with Locust 
- [ ] configure HorizontalAutoscaler in K8s

### Monitoring & Alerting

TODO: 
- [ ] deploy the k8s cluster with prometheus operator
- [ ] deploy a dashboard with Grafana or something
- [ ] create a list of alerts to configure in Prometheus 


### Security

TODO:
- [ ] describe how secrets are used to configure the application without storing info in the repository
- [ ] describe how we configured CI to run with a Kubernetes service account and limited access to limited resources and namespaces 
- [ ] maybe move the permissions of the service account from default namespace to something else


# Project Requirements and Preparation

- Install Jenkins instance with Cloudformation
- Install additional Jenkins plugins with ansible

## Prepare Jenkins server instance

You can deploy a Jenkins CI server on AWS with the cloudformation deployment script provided

```
cd cloudformation/
./deploy_stack.sh jenkins jenkins-w-vpc.yaml jenkins-params.json
```

Once the script is successful you can check in AWS Cloudformation console the Outpus section of the stack. There you can find some useful links to:
- SSH into your Jenkins instance
- Retrieve the initial admin password
- Jenkins CI console URL

### Install additional required packages and plugins

An Ansible playbook is provided to install additional plugins and packages to the Jenkins instance after the first administrative user is installed. For this you will need: 
- the Jenkins instance IP address
- the Jenkins admin username
- the Jenkins admin password

From command line, run the Ansible playbook `install_plugins.yml`

```
cd ansible/
ansible-playbook --key-file=~/.ssh/pipeline.pem -u ubuntu \
    -i "<jenkins_ip>," \
    -e jenkins_user=<username> -e jenkins_password=<secret> \
    jenkins/install_plugins.yml
```

### Configure pipeline for the project

From Jenkins BlueOcean follow these steps to configure a new multi-branch pipeline with web-hooks

- from BlueOcean Jenkins page, click the **Create Pipeline** button
- select Github and create the access token as instructed
- select your repository and confirm

#### Adding webhook to push events from GitHub

- navigate the *Settings* menu for your GitHub repository
- under *Webhooks* select *Add webhook*
- specify your Jenkins server URL like for instance `http://54.189.23.46:8080/github-webhook/`
- specify a content-type and secret (optional)
- select the *Just the push event* and create the webhook


## Setup the Kubernetes cluster

In order to run the pipeline we need a working Kubernetes cluster. In the `kops/` directory a create and update scripts are provided. 
To install a new cluster simply run
```
cd kops/
aws s3api create-bucket \
    --bucket mcastellin-capstone.k8s.local-state-store \
    --region us-west-2 \
    --create-bucket-configuration LocationConstraint=us-west-2

./create_cluster.sh
```

Here is explained what heppens:
- first we create a new bucket in aws for kops to store our cluster state. This is required by kops.
- the `create_cluster.sh` will create a new Kubernetes cluster in EC2 using the configuration stored in `kops/mcastellin-capstone.k8s.local.yaml` file
- the script will output some useful values you need to use to setup your Jenkins instance and access your cluster
