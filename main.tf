provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">=v0.12.20"

  backend "s3" {
    encrypt = true
    acl     = "private"
  }
}


# Local variables
locals {
  gpg_public_key                = ""
  create_user                   = true
  create_iam_user_login_profile = true
  upload_iam_user_ssh_key       = false
  ssh_key_encoding              = "SSH"
  ssh_public_key                = ""
  password_length               = 16
  password_reset_required       = true
  path                          = "/"
  policies = [
    "arn:aws:iam::aws:policy/IAMUserChangePassword"
  ]
}

# Assign user to group
resource "aws_iam_group_membership" "team" {
  count = var.attach_user_to_group ? 1 : 0
  name  = "aws_iam_group_membership"
  users = [aws_iam_user.test_user.name]
  group = var.group_name
}

# IAM User
resource "aws_iam_user" "test_user" {
  name = var.user_name
  tags = var.tags
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# IAM User Access Key
resource "aws_iam_access_key" "test_access_key" {
  count   = var.cli_access ? 1 : 0
  user    = aws_iam_user.test_user.name
  pgp_key = local.gpg_public_key
  depends_on = [
    aws_iam_user.test_user
  ]
}

## IAM user login profile
resource "aws_iam_user_login_profile" "test_login_profile" {
  count                   = var.console_access ? 1 : 0
  user                    = aws_iam_user.test_user.name
  password_length         = local.password_length
  password_reset_required = local.password_reset_required
  depends_on = [
    aws_iam_user.test_user
  ]
  lifecycle {
    ignore_changes = [
      password_reset_required,
    ]
  }
}

## SSH Key
resource "aws_iam_user_ssh_key" "test_user_key" {
  count      = local.create_user && local.upload_iam_user_ssh_key ? 1 : 0
  username   = aws_iam_user.test_user.name
  encoding   = local.ssh_key_encoding
  public_key = local.ssh_public_key
  depends_on = [
    aws_iam_user.test_user
  ]
}

# IAM policies attachment
resource "aws_iam_policy_attachment" "policy_attachment" {
  count = length(local.policies)
  #count = var.user_type == "service" ? 0 : 1
  name = "Policy attachment ${aws_iam_user.test_user.name}"
  users = [
    aws_iam_user.test_user.name
  ]
  policy_arn = element(local.policies, count.index)
  depends_on = [
    aws_iam_user.test_user
  ]
}

## Secrets manager
resource "aws_secretsmanager_secret" "test_user_secret" {
  name = var.user_name
  tags = var.tags
  depends_on = [
    aws_iam_user.test_user
  ]
}

## Secrets manager
resource "aws_secretsmanager_secret_version" "test_user_secret_version" {
  secret_id     = aws_secretsmanager_secret.test_user_secret.id
  secret_string = <<EOF
  {
    "username": "${join("", aws_iam_user.test_user.*.name)}"
    "password": "${join("", aws_iam_user_login_profile.test_login_profile.*.password)}" 
    "Keyid":  "${join("", aws_iam_access_key.test_access_key.*.id)}" 
    "secretaccesskey": "${join("", aws_iam_access_key.test_access_key.*.secret)}"
  }
EOF
  depends_on = [
    aws_iam_user.test_user,
    aws_secretsmanager_secret.test_user_secret
  ]
}