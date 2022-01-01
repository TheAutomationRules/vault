#!/bin/bash
set -e
sleep 120

# Vault initialization script
export VAULT_ADDR="http://127.0.0.1:8200"
curl --request POST --data '{"secret_shares": 5, "secret_threshold": 3}' http://127.0.0.1:8200/v1/sys/init | tee secret_shares.json

export VAULT_TOKEN=$(cut -d ":" -f 4 secret_shares.json | cut -d "}" -f 1 | cut -d '"' -f 2) && echo $VAULT_TOKEN

# AUTO-UNSEAL SCRIPT
# This script generate a script called unseal_script.sh
# with curl execution to unseal with 3 keys to unseal Vault.

echo '#!/bin/bash' >> unseal_vault.sh

echo 'set -e' >> unseal_vault.sh

echo "curl --request POST --data '{\"key\": \"$(cut -d ":" -f 3 secret_shares.json | cut -d "]" -f 1 |  cut -d "[" -f 2 | cut -d "," -f 1 | cut -d '"' -f 2)\"}' http://127.0.0.1:8200/v1/sys/unseal | jq" >> unseal_vault.sh

echo "curl --request POST --data '{\"key\": \"$(cut -d ":" -f 3 secret_shares.json | cut -d "]" -f 1 |  cut -d "[" -f 2 | cut -d "," -f 2 | cut -d '"' -f 2)\"}' http://127.0.0.1:8200/v1/sys/unseal | jq" >> unseal_vault.sh

echo "curl --request POST --data '{\"key\": \"$(cut -d ":" -f 3 secret_shares.json | cut -d "]" -f 1 |  cut -d "[" -f 2 | cut -d "," -f 3 | cut -d '"' -f 2)\"}' http://127.0.0.1:8200/v1/sys/unseal | jq" >> unseal_vault.sh

chmod +x unseal_vault.sh

echo "Vault initialization READY!"