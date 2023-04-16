#!/bin/bash

echo "Update the OS"
yum update -y
yum install vim -y

echo "Install Ansible"
yum install epel-release -y
yum install ansible -y

