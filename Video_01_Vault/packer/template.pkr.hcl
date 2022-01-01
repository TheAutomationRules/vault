// AMI Builder (EBS Backend)
// https://www.packer.io/docs/builders/amazon/ebs
source "amazon-ebs" "packerami" {
  region        = "eu-central-1"
  ami_name      = "pkr-vault-img-v0.1_{{timestamp}}"
  source_ami    = "ami-0d527b8c289b4af7f" // Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
  instance_type = "t2.micro"
  subnet_id     = "subnet-08b6a7b8f4c1ea12e" // AWS temporal Subnet-ID
  ssh_username  = "ubuntu"
  tags          = {
    OS_Version    = "Ubuntu Server 20.04 LTS (HVM), SSD Volume Type"
    Release       = "Latest"
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Name          = "pkr-vault-img-v0.1"
  }
}

build {
  sources = ["source.amazon-ebs.packerami"]

  provisioner "file" {
    source      = "vault_config.hcl"
    destination = "/home/ubuntu/vault_config.hcl"
  }

  provisioner "shell" {
    script = "./bootstrap.sh"
  }
}