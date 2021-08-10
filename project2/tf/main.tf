# create the bucket
provider "aws" {
	region = var.aws_region
}

resource "aws_s3_bucket" "a" {
  bucket = "tl-incidents2"
	acl = var.acl

	versioning {
	  enabled = var.versioning
	}

	tags = var.tags
}

# upload test data to the bucket
resource "aws_s3_bucket_object" "testdata" {
	bucket = aws_s3_bucket.a.id
	key = "example.json"
	acl = var.acl
	source = "example.json"
}

data "aws_iam_policy_document" "k8_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kuber_service_role" {
	name = "kuberole"
	assume_role_policy = data.aws_iam_policy_document.k8_assume_role_policy.json
}

# resource "aws_iam_role_policy_attachment" "attach" {
#	role = aws_iam_role.kuberole
#	policy_arn = aws_iam_policy.AmazonEKSClusterPolicy
#}
