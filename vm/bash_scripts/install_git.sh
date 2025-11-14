#!/usr/bin/env bash

set -e
set -u

echo "=== Updating system packages ==="
sudo apt update
sudo apt upgrade -y

echo "=== Installing Git ==="
sudo apt install -y git

echo "=== Verifying Git installation ==="
git --version

echo "=== Git installed successfully ==="