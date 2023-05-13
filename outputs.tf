
output "user_name" {
  description = "The user's name."
  value       = aws_iam_user.test_user.name
}

output "user_arn" {
  description = "The ARN assigned by AWS for this user."
  value       = aws_iam_user.test_user.arn
}

output "user_access_key" {
  description = "The unique ID assigned by AWS."
  value       = aws_iam_user.test_user.unique_id
}

