# Data sources

# Cloid-Init Configuration
# ----------------------------------------------------------
data "template_file" "cloud-init-config" {
  template = file("./config/cloud-init.yaml")
  vars = {
    access_key = var.access_key
    secret_key = var.secret_key
    s3_bucket = aws_s3_bucket.s3-bucket.id
    private_ip_addr = var.private_ip_addr
    ssh_pub_key = var.ssh_pub_key
  }
}

data "aws_ami" "pkr-vault-img" {
  filter {
    name   = "tag:Name"
    values = ["pkr-vault-img-v0.1"]
  }
  owners = ["184682721670"] // The Automation Rules
}

data "aws_vpc" "vpc-id-default" {
  filter {
    name   = "tag:Name"
    values = ["tar-vpc-default"]
  }
}

data "aws_subnet" "tar-eu-central-1a" {
  filter {
    name   = "tag:Name"
    values = ["tar-eu-central-1a"]
  }
}

/*data "aws_security_group" "vault" {
  name = "sg_eu-central-1_vault_001"
}*/