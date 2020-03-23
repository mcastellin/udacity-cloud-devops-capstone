# Running the Ansible playbook
To run the ansible playbook:

```
ansible-playbook -i inventory jenkins.yaml
```

## Prerequisites

- Hosts file configuration: include the IP address for `capstone_jenkins_ec2` host
- Ssh identity: make sure the `.pem` file is added with the `ssh-add` or specified as parameter for ansible
