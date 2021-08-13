provider "aws" {
	region = var.aws_region
}

# create the bucket
resource "aws_s3_bucket" "incidents_bucket" {
  bucket = "tl-incidents"
  acl = var.acl
	force_destroy = true	

	versioning {
	  enabled = var.versioning
	}

	tags = var.tags
}

# upload test data to the bucket
resource "aws_s3_bucket_object" "testdata" {
	bucket = aws_s3_bucket.incidents_bucket.id
	key = "example.json"
	acl = var.acl
	source = "example.json"
}

# assign EKS to role
data "aws_iam_policy_document" "k8_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

locals {
  cluster_name = "tl-eks-cluster"
}

# create role for EKS
resource "aws_iam_role" "kuber_service_role" {
	name = "kuberole"
	assume_role_policy = data.aws_iam_policy_document.k8_assume_role_policy.json
	managed_policy_arns = [
		"arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
		"arn:aws:iam::aws:policy/AmazonS3FullAccess"
		]
}

# create the VPC for EKS
module "vpc" {
	source = "terraform-aws-modules/vpc/aws"

	name = "kube-vpc"
	cidr = "10.0.0.0/16"

	azs = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
	private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
	public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
	enable_nat_gateway = true
	single_nat_gateway = true
	enable_dns_hostnames = true

	tags = {
	  "kubernetes.io/cluster/${local.cluster_name}" = "shared"
	}

	public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# security groups
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"

    cidr_blocks = [
      "10.0.0.0/16",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/16",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}
