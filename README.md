# udacity-cloud-devops-capstone
A repository that will contain the Udacity Cloud DevOps capstone project

## The Application

For this project I want to operationalise a simple integration flow. 
- an api receives data from users and drops the data into an AWS SQS
- another backend app has the job to dequeue the requests from SQS, process them and put the results into a MongoDB database
- the frontend app can read some stats from MongoDB and display them in a webpage to web users

The application is composed of two microservices:
- A frontend microservice to receive requests and display the statistics page
- A batch microservice to pull the requests from SQS and process them and update statistics into the database

Other services will be utilized too
- Amazon SQS
- Amazon hosted MongoDB database

### Application requirements
- the application should be deployed for high availability
- it should use the minimum amount of resources to handle the amount of requests
- web application should handle the load by scaling horizontally
- backend application should be able to scale down to 1 running instance and scale up

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
- I want the application api to be browsable with swagger 

## TODOs
- [x] Create Ansible playbook to install Jenkins into an ubuntu Linux machine
- [ ] Create cloudformation script to initialise all Amazon resources to deploy our Kubernetes cluster and Jenkins
