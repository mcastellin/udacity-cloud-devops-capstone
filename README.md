# udacity-cloud-devops-capstone
A repository that will contain the Udacity Cloud DevOps capstone project


## Purpose
Implement a pipeline to deploy a microservice in a Kubernetes cluster hosted in an AWS account.

## Project tasks

- create a repo and a simple microservice implementation. This time we want to also use some sort of database
- configure linting and unit test execution with a CI pipeline in circleCI
- create an Ansible or cloudformation script to setup a Jenkins instance in EC2 automatically
- configure an account with minimum privileges in AWS with programmatic access to run deployments with Jenkins
- setup github webhooks for pipeline deployment and configure the pipeline in Jenkins
- create a CI/CD pipeline to pick new commits done against a specific branch, test and deploy the new code
- application microservices should be containerized. Dockerfiles should pass the linting phase
- After the container build, the pipeline should push the image in a container registry
- container should pass a security scan
- code will be deployed in a kubernetes cluster
- new container should be tagged with the git hash
- at pipeline completion a new deployment should deploy in a blue/green fashion
- after deployment and before switching load balancer, the new instance should pass smoke testing (automated) 
-
