variable "user_name" {
  type        = string
  description = "User name"
}

variable "tags" {
  type = map(any)
}

variable "cli_access" {
  description = "Allow access AWS Cli if the value is true"
  type        = bool
}

variable "console_access" {
  description = "Allow access Web AWS console if the value is true"
  type        = bool
}

variable "public_key" {
  description = "Allow access Web AWS console if the value is true"
  type        = string
  default     = null
}

variable "policies" {
  description = "List of ARN of policies to set on the user"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/IAMUserChangePassword", "arn:aws:iam::046393842099:policy/user-specific-secrets-manager-policy"]
}

variable "attach_user_to_group" {
  description = "Attach user to the user group"
  type        = bool
}

variable "group_name" {
  description = "IAM user group name"
  type        = string
}

variable "user_type" {
  description = "IAM user type"
  type        = string
}

