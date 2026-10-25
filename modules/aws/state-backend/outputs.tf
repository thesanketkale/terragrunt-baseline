output "bucket_id" {
  value       = aws_s3_bucket.state.id
  description = "The name/ID of the remote state S3 bucket."
}

output "bucket_arn" {
  value       = aws_s3_bucket.state.arn
  description = "The ARN of the remote state S3 bucket."
}

output "dynamodb_table_name" {
  value       = var.create_dynamodb_lock_table ? aws_dynamodb_table.locks[0].name : null
  description = "The name of the DynamoDB lock table if enabled."
}
