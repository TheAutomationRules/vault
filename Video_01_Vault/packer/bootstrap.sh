#!/bin/bash

set -e

# Manual Installation Vault
sudo apt-get update && sudo apt-get install -y unzip jq
curl -L https://releases.hashicorp.com/vault/1.8.4/vault_1.8.4_linux_amd64.zip -o vault.zip
unzip vault.zip
sudo chown ubuntu:ubuntu vault
sudo mv vault /usr/local/bin/
rm -rf vault.zip