#!/bin/bash
set -e

# AUTO-UNSEAL SCRIPT
# This script generate a script called unseal_script.sh
# with curl execution to unseal with 3 keys to unseal Vault.

echo '#!/bin/bash' >> unseal_vault.sh

echo 'set -e' >> unseal_vault.sh

echo "curl --request POST --data '{\"key\": \"$(cut -d ":" -f 3 secret_shares.json | cut -d "]" -f 1 |  cut -d "[" -f 2 | cut -d "," -f 1 | cut -d '"' -f 2)\"}' http://127.0.0.1:8200/v1/sys/unseal | jq" >> unseal_vault.sh

echo "curl --request POST --data '{\"key\": \"$(cut -d ":" -f 3 secret_shares.json | cut -d "]" -f 1 |  cut -d "[" -f 2 | cut -d "," -f 2 | cut -d '"' -f 2)\"}' http://127.0.0.1:8200/v1/sys/unseal | jq" >> unseal_vault.sh

echo "curl --request POST --data '{\"key\": \"$(cut -d ":" -f 3 secret_shares.json | cut -d "]" -f 1 |  cut -d "[" -f 2 | cut -d "," -f 3 | cut -d '"' -f 2)\"}' http://127.0.0.1:8200/v1/sys/unseal | jq" >> unseal_vault.sh

chmod +x unseal_vault.sh