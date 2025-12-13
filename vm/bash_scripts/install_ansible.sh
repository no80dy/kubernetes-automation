#!/usr/bin/env bash

set -e
set -u

echo "=== Updating system packages ==="
sudo apt update
sudo apt upgrade -y

echo "=== Installing dependencies ==="
sudo apt install -y software-properties-common gnupg2 curl lsb-release

echo "=== Installing Ansible ==="
sudo apt update
sudo apt install -y ansible

echo "=== Verifying Ansible installation ==="
ansible --version

echo "=== Ansible installed successfully ==="