# Native Terraform Test for AWS Network Module
# Uses mock_provider to test VPC, subnet, and NAT gateway logic.

mock_provider "aws" {}

run "verify_single_nat_gateway_in_dev" {
  command = plan

  variables {
    vpc_cidr             = "10.0.0.0/16"
    azs                  = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
    data_subnet_cidrs    = ["10.0.21.0/24", "10.0.22.0/24"]
    enable_nat_gateway   = true
    single_nat_gateway   = true
    tags = {
      Project     = "terragrunt-baseline"
      Environment = "dev"
    }
  }

  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR must match configured block."
  }

  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Must provision exactly 2 public subnets."
  }

  assert {
    condition     = length(aws_subnet.private) == 2
    error_message = "Must provision exactly 2 private subnets."
  }

  assert {
    condition     = length(aws_subnet.data) == 2
    error_message = "Must provision exactly 2 data subnets."
  }

  assert {
    condition     = length(aws_nat_gateway.nat) == 1
    error_message = "Must provision exactly 1 NAT Gateway when single_nat_gateway is true."
  }
}

run "verify_multi_az_nat_in_production" {
  command = plan

  variables {
    vpc_cidr             = "10.20.0.0/16"
    azs                  = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
    private_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24"]
    data_subnet_cidrs    = ["10.20.21.0/24", "10.20.22.0/24"]
    enable_nat_gateway   = true
    single_nat_gateway   = false
  }

  assert {
    condition     = length(aws_nat_gateway.nat) == 2
    error_message = "Must provision 2 NAT Gateways when single_nat_gateway is false for HA."
  }
}
