# Native Terraform Test for AWS State Backend Module
# Uses mock_provider for 100% offline, credential-free plan assertions.

mock_provider "aws" {}

run "verify_state_bucket_defaults" {
  command = plan

  variables {
    bucket_name = "terragrunt-state-111111111111-us-east-1"
    tags = {
      Project     = "terragrunt-baseline"
      Environment = "dev"
    }
  }

  assert {
    condition     = aws_s3_bucket.state.bucket == "terragrunt-state-111111111111-us-east-1"
    error_message = "Bucket name does not match the configured input."
  }

  assert {
    condition     = aws_s3_bucket_versioning.state.versioning_configuration[0].status == "Enabled"
    error_message = "S3 bucket versioning must be Enabled."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.state.block_public_acls == true
    error_message = "Public ACLs must be blocked."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.state.block_public_policy == true
    error_message = "Public policy must be blocked."
  }

  assert {
    condition     = length(aws_dynamodb_table.locks) == 0
    error_message = "DynamoDB lock table should not be provisioned by default."
  }
}

run "verify_dynamodb_table_when_enabled" {
  command = plan

  variables {
    bucket_name                = "terragrunt-state-111111111111-us-east-1"
    create_dynamodb_lock_table = true
    dynamodb_table_name        = "terragrunt-locks"
  }

  assert {
    condition     = length(aws_dynamodb_table.locks) == 1
    error_message = "DynamoDB table should be provisioned when create_dynamodb_lock_table is true."
  }

  assert {
    condition     = aws_dynamodb_table.locks[0].hash_key == "LockID"
    error_message = "DynamoDB lock table hash key must be LockID."
  }
}
