variable "public_bucket_name" {}
variable "private_bucket_name" {}
variable "lambda_edge_bucket_name" {}

provider "aws" {
  alias = "lambda_edge"
}

resource "aws_s3_bucket" "public_bucket" {
  bucket = "${var.public_bucket_name}"
  acl    = "public-read"
}

resource "aws_s3_bucket" "private_bucket" {
  bucket = "${var.private_bucket_name}"
  acl    = "private"

}

resource "aws_s3_bucket" "lambda_edge_bucket" {
  # use separate provider as buckets need to be in same domain ?? (is this true?)
  provider = aws.lambda_edge
  bucket   = "${var.lambda_edge_bucket_name}"
  acl      = "private"
}

# module exports

output "public_bucket_domain_name" {
  value = "${aws_s3_bucket.public_bucket.bucket_regional_domain_name}"
}
output "public_bucket" {
  value = "${aws_s3_bucket.public_bucket.bucket}"
}
output "private_bucket_domain_name" {
  value = "${aws_s3_bucket.private_bucket.bucket_regional_domain_name}"
}
output "private_bucket" {
  value = "${aws_s3_bucket.private_bucket.bucket}"
}
output "lambda_edge_bucket_domain_name" {
  value = "${aws_s3_bucket.lambda_edge_bucket.bucket_regional_domain_name}"
}
output "lambda_edge_bucket" {
  value = "${aws_s3_bucket.lambda_edge_bucket.bucket}"
}
