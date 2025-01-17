variable "aws_region" {
  type        = string
  description = "The AWS region"
  default     = "us-east-1"
}

variable "bucket_prefix" {
  type        = string
  description = "We need globally unique bucket names"
  default     = "tl-"
}

variable "tags" {
  type        = map(any)
  description = "Tags for security groups"
  default = {
    environment = "prod"
    terraform   = "true"
  }
}

variable "versioning" {
  type        = bool
  description = "Do we need versioning"
  default     = false
}

variable "acl" {
  type        = string
  description = "Set default to private"
  default     = "private"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
  default     = "tl-eks-cluster"
}

