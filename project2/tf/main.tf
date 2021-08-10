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

# create role for EKS
resource "aws_iam_role" "kuber_service_role" {
	name = "kuberole"
	assume_role_policy = data.aws_iam_policy_document.k8_assume_role_policy.json
	managed_policy_arns = [
		"arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
		"arn:aws:iam::aws:policy/AmazonS3FullAccess"
		]
}

## assign s3 to role
#resource "aws_iam_role_policy_attachment" "kuberole-eks" {
#  role       = aws_iam_role.kuber_service_role.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
#}

# assign EKSCluster policy to role
#resource "aws_iam_role_policy_attachment" "kuberole-eks" {
#  role       = aws_iam_role.kuber_service_role.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#}

# resource "aws_iam_role_policy_attachment" "attach" {
#	role = aws_iam_role.kuberole
#	policy_arn = aws_iam_policy.AmazonEKSClusterPolicy
#}
