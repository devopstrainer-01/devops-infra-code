# Looks up whether var.key_name already exists in AWS (via the AWS CLI, through
# scripts/check_keypair.ps1) so Terraform can decide whether to create it or
# leave it alone. Requires the AWS CLI to be installed and configured.
data "external" "key_pair_check" {
  count = var.manage_key_pair ? 1 : 0

  program = [
    "powershell", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass",
    "-File", "${path.module}/scripts/check_keypair.ps1"
  ]

  query = {
    key_name = var.key_name
    region   = var.aws_region
  }
}

locals {
  private_key_path = "${path.module}/${var.key_name}.pem"

  # Once Terraform has generated the private key file for this key_name, the live
  # AWS check below will always report "exists" (because Terraform itself created
  # it) - so that file's presence is what makes the create decision sticky across
  # applies. Without this, a later plan would see "exists = true" and try to
  # destroy the very key pair Terraform created (and lose the private key).
  private_key_already_written = fileexists(local.private_key_path)

  key_pair_exists = var.manage_key_pair && tobool(data.external.key_pair_check[0].result.exists)
  create_key_pair = var.manage_key_pair && (local.private_key_already_written || !local.key_pair_exists)
}

# Warns (does not fail the apply) when the key pair is already present in AWS,
# since Terraform will reuse it as-is instead of creating or overwriting it.
check "key_pair_already_exists" {
  assert {
    condition     = !local.key_pair_exists
    error_message = "Key pair '${var.key_name}' already exists in AWS region ${var.aws_region}. Terraform will reuse it as-is and will NOT create a new one or overwrite it - make sure you already hold the matching private key."
  }
}

resource "tls_private_key" "generated" {
  count = local.create_key_pair ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_key_pair" "generated" {
  count = local.create_key_pair ? 1 : 0

  key_name   = var.key_name
  public_key = tls_private_key.generated[0].public_key_openssh

  tags = merge(var.tags, {
    Name = var.key_name
  })

  lifecycle {
    prevent_destroy = true
  }
}

# Private key is only ever available at creation time - AWS never returns it
# for a pre-existing key pair, so this file is only written when we generated it.
resource "local_sensitive_file" "private_key" {
  count = local.create_key_pair ? 1 : 0

  filename        = local.private_key_path
  content         = tls_private_key.generated[0].private_key_pem
  file_permission = "0600"

  lifecycle {
    prevent_destroy = true
  }
}
