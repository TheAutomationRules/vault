# Security group to allow all traffic
resource "aws_security_group" "vault_sg_allowall" {
  name        = "sg_eu-central-1_vault_001"
  description = "HashiCorpt Vault - SecurityGroup"
  vpc_id      = data.aws_vpc.vpc-id-default.id

  # INGRESS RULES
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Provides HTTP access from client web browsers to the local user interface and connections from Cloud Data Sense"
  }

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Provides HTTPS access from client web browsers to the local user interface"
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Provide SSH"
  }

  ingress {
    from_port   = "-1"
    to_port     = "-1"
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Provides ping"
  }

  ingress {
    from_port   = "2049"
    to_port     = "2049"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NFS"
  }

  ingress {
    from_port   = "8200"
    to_port     = "8201"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Vault Traffic"
  }

  # EGRESS RULES / ALLOW ALL
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags       = {
    Name      = "sg_eu-central-1_vault_001"
    Terraform = "True"
    Service   = "Vault"
  }
  depends_on = [aws_s3_bucket.s3-bucket, aws_s3_bucket_public_access_block.s3-bucket-acl]
}

resource "tls_private_key" "global_key" {
  algorithm  = "RSA"
  rsa_bits   = 2048
  depends_on = [aws_security_group.vault_sg_allowall]
}

resource "local_file" "ssh_private_key_pem" {
  filename          = "keys/id_rsa"
  sensitive_content = tls_private_key.global_key.private_key_pem
  file_permission   = "0600"
  depends_on        = [aws_security_group.vault_sg_allowall]
}

resource "local_file" "ssh_public_key_openssh" {
  filename   = "pub_keys/id_rsa.pub"
  content    = tls_private_key.global_key.public_key_openssh
  depends_on = [aws_security_group.vault_sg_allowall]
}

# Temporary key pair used for SSH accesss
resource "aws_key_pair" "vault_key_pair" {
  key_name_prefix = "vault-"
  public_key      = tls_private_key.global_key.public_key_openssh
  depends_on      = [aws_security_group.vault_sg_allowall]
}

resource "aws_instance" "vault" {
  ami              = data.aws_ami.pkr-vault-img.id
  subnet_id        = data.aws_subnet.tar-eu-central-1a.id
  security_groups  = [aws_security_group.vault_sg_allowall.id]
  user_data_base64 = base64encode(data.template_file.cloud-init-config.rendered)
  private_ip       = var.private_ip_addr
  instance_type    = "t2.micro"
  key_name         = aws_key_pair.vault_key_pair.key_name

  # Copy id_rsa.pub
  provisioner "file" {
    source      = "pub_keys/id_rsa.pub"
    destination = "/home/ubuntu/id_rsa.pub"
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.global_key.private_key_pem
    }
  }

  # Copy secrets_generator.sh
  provisioner "file" {
    source      = "script/secrets_generator.sh"
    destination = "/home/ubuntu/secrets_generator.sh"
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.global_key.private_key_pem
    }
  }

  # Copy generate_unseal_vault.sh
  provisioner "file" {
    source      = "script/generate_unseal_vault.sh"
    destination = "/home/ubuntu/generate_unseal_vault.sh"
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.global_key.private_key_pem
    }
  }

  # Copy vault_cloud_config.sh
  provisioner "file" {
    source      = "script/vault_cloud_config.sh"
    destination = "/home/ubuntu/vault_cloud_config.sh"
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.global_key.private_key_pem
    }
  }

  # Remote Exec Command Line
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null", "echo 'Completed cloud-init!'",
      "sudo cat /home/ubuntu/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys",
      "sudo systemctl start vault && sudo systemctl enable vault",
      "chmod +x *.sh",
      // Inicializacion Manual de Vault
      #"export VAULT_ADDR='http://127.0.0.1:8200' && vault operator init",
      // Inicializacion automatica de Vault
      "./secrets_generator.sh",
      // Generamos un script para hacer el Auto-Unseal
      "./generate_unseal_vault.sh",
      // Opcional (Hacer Unseal)
      #"./unseal_vault.sh",
      // Opcional (Creacion de Politicas y Secrets)
      #"./vault_cloud_config.sh",
      "echo 'Vault NODE Ready!'",
    ]
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.global_key.private_key_pem
    }
  }

  # Custom Tags for instances
  tags       = {
    Name        = "vault-server"
    Creator     = "Terraform"
    Team        = "IAC"
    Environment = "staging"
  }
  depends_on = [aws_security_group.vault_sg_allowall, aws_key_pair.vault_key_pair]
}