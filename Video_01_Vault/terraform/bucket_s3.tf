resource "aws_s3_bucket" "s3-bucket" {
  bucket_prefix = "vault-"
  acl = "private"
  # Versioning Configuration
  versioning {
    enabled = true
  }

  # Encryption Configuracion for S3 Bucket
  /*server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "XXXXXXXX"
        sse_algorithm     = "aws:kms"
      }
    }
  }*/

  # TAGs of Resources
  tags = {
    Name = "backend-vault",
    Environment = "staging"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-bucket-acl" {
  bucket = aws_s3_bucket.s3-bucket.id

  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
  depends_on = [aws_s3_bucket.s3-bucket]
}