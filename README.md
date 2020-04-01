# udacity-cloud-devops-capstone
A repository that will contain the Udacity Cloud DevOps capstone project

## The Application

For this project I want to operationalise a simple API developed in Python.
The API interface will be browsable with swagger.

### Application requirements
- the application should be deployed for high availability
- it should use the minimum amount of resources to handle user requests
- application should scale horizontally base on CPU utilization and throughput

## Project tasks

- I want the application api to be browsable with swagger 
- configure linting and unit test execution with a CI pipeline in Jenkins
- create an Ansible or cloudformation script to setup a Jenkins instance in EC2 automatically
- configure an account with minimum privileges in AWS with programmatic access to run deployments with Jenkins
- setup github webhooks for pipeline deployment and configure the pipeline in Jenkins
- create a CI/CD pipeline to pick new commits done against a specific branch, test and deploy the new code
- application microservice should be containerized. Dockerfile should pass a linting phase
- After the container build, the pipeline should push the image in a container registry
- container should pass a security scan (? how is to be verified ?)
- code will be deployed in a kubernetes cluster
- new container should be tagged with the git hash so K8s can pick up new image version
- at pipeline completion a new deployment should deploy in a blue/green fashion
- after deployment and before switching load balancer, the new instance should pass smoke testing (automated) 

## TODOs
- [x] Create Ansible playbook to install Jenkins into an ubuntu Linux machine
- [x] Create cloudformation script to initialise all Amazon resources to deploy our Kubernetes cluster and Jenkins


# Requirements Installation

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

### Install additional Jenkins plugins

An Ansible playbook is provided to install additional plugins to the Jenkins instance after the first administrative user is install. For this you will need: 
- the Jenkins instance IP address
- the Jenkins admin username
- the Jenkins admin password

From command line run the Ansible playbook

```
cd ansible/
ansible-playbook --key-file=~/.ssh/pipeline.pem -u ubuntu \
    -i "<jenkins_ip>," \
    -e jenkins_user=<username> -e jenkins_password=<secret> \
    jenkins/install_plugins.yml
```

### Configure pipeline for the project

From Jenkins BlueOcean follow these steps to configure a new multi-branch pipeline with web-hooks

//TODO: describe how I did it
