# Ansible Playbooks

This directory contains all the available Ansible playbooks for this project

## Installing Jenkins on a new EC2 instance

You can install Jenkins in a brand new EC2 instance by following this process

#### 1. Install system dependencies and Jenkins server

Run the `jenkins.yml` playbook:

```
ansible-playbook -i inventory jenkins.yaml
```

#### 2. Configure the first Jenkins admin user

- Log into the EC2 instance and read the init password from `/var/log/jenkins/jenkins.log` file
- Log into Jenkins `http://<your instance ip>:8080/` and install recommended plugins
- Create a new admin user

#### 3. Install additional plugins with Ansible

Now we come back to ansible and run the `plugins.yml` playbook. This time you need to specify the admin
username and password as a parameter for the playbook

```
ansible-playbook -i inventory -e jenkins_user="<your admin>" -e jenkins_password="<your password>" plugins.yml
```

## Prerequisites

- Hosts file configuration: include the IP address for `capstone_jenkins_ec2` host
- Ssh identity: make sure the `.pem` file is added with the `ssh-add` or specified as parameter for ansible
