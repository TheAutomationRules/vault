#!/bin/bash
set -e

# Vault initialization script
export VAULT_TOKEN=$(cut -d ":" -f 4 secret_shares.json | cut -d "}" -f 1 | cut -d '"' -f 2) && echo $VAULT_TOKEN

curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data '{"type": "approle"}' http://127.0.0.1:8200/v1/sys/auth/approle

sleep 2

# // POLICY TO CLOUD SECRETS
curl --header "X-Vault-Token: $VAULT_TOKEN" --request PUT --data '{"policy":"# STAGING Policy to Cloud Secrets \n# need these paths to grant permissions:\npath \"secret/data/cloud/*\" {\n  capabilities = [\"create\", \"update\"]\n}\n\npath \"secret/data/cloud/*\" {\n  capabilities = [\"read\"]\n}\n"}' http://127.0.0.1:8200/v1/sys/policies/acl/cloud-policy

sleep 2


# // ASSIGNMENT FROM CLOUD-POLICY TO CLOUD-ROLE ------------------------------------
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data '{"policies": ["cloud-policy"]}' http://127.0.0.1:8200/v1/auth/approle/role/cloud-role

sleep 2

curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST http://127.0.0.1:8200/v1/auth/approle/role/cloud-role/secret-id | jq -r ".data"

sleep 2

curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data '{ "type":"kv-v2" }' http://127.0.0.1:8200/v1/sys/mounts/cloud


# ---------------------------------------------------------------------------#
# ------------------------ INPUT SECRETS ------------------------------------#
# ---------------------------------------------------------------------------#


# // AWS CLOUD SERVICES ------------------------------------------------------

# STAGING ACCESS-KEY
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data '{ "data": {"access_key": "AKIAM7XJL92CU73CM8HY"} }' http://127.0.0.1:8200/v1/cloud/data/aws/staging/access_key | jq -r ".data"

sleep 2

# STAGING SECRET-KEY
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data '{ "data": {"secret_key": "$oQWmrjnA4&73dECz9oyWQTqcI!GK0UlCZ4x$xIp"} }' http://127.0.0.1:8200/v1/cloud/data/aws/staging/secret_key | jq -r ".data"

sleep 2

# STAGING KMS-KEY
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data '{ "data": {"kms_key_id": "arn:aws:kms:eu-central-1:XXXXXXXXX:key/XXXXXXXXXXXXXXX"} }' http://127.0.0.1:8200/v1/cloud/data/aws/staging/kms_key_id | jq -r ".data"

sleep 2