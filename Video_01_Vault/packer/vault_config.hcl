storage "s3" {
  region     = "eu-central-1"
  access_key = ""
  secret_key = ""
  bucket     = "backend-hashicorp-vaultxxxxxxxxx"
  kms_key_id = "arn:aws:kms:eu-central-1:xxxxxxxxx"
}

listener "tcp" {
  address     = "127.0.0.1:8200" # ONLY LOCAL HOST
  tls_disable = "true"
}

listener "tcp" {
  address     = "172.22.16.10:8200" # ACCESS FROM ANY IP OF SUBNET
  tls_disable = "true"
}

api_addr = "http://172.22.16.10:8200"
cluster_addr = "https://172.22.16.10:8201"
ui = true
disable_mlock = true