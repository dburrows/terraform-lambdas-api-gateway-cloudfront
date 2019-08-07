variable "lambda_edge_bucket" {}
variable "lambda_edge_html_key" {}
variable "lambda_html_hash" {}
variable "project_prefix" {}

provider "aws" {
  alias = "lambda_edge"
}

// ROLES AND POLICIES

resource "aws_iam_role" "lambda_edge" {
  name = "${var.project_prefix}-iam-role-lambda-edge"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [ "lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Create a policy for full access to the status page dynamo db table
resource "aws_iam_policy" "policy_lambda_edge" {
  name = "${var.project_prefix}-LambdaEdgePolicy"
  policy = <<EOF
{
   "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "lambda:GetFunction",
                "lambda:GetFunctionConfiguration"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# attach policy to role - see non-edge lambda config for how to do this with existing role
resource "aws_iam_role_policy_attachment" "basic_execution_policy" {
  role       = "${aws_iam_role.lambda_edge.id}"
  policy_arn = "${aws_iam_policy.policy_lambda_edge.arn}"
}

// LAMBDA

# https://www.terraform.io/docs/providers/aws/r/lambda_function.html
resource "aws_lambda_function" "lambda_edge_html" {
  provider      = aws.lambda_edge
  s3_bucket     = "${var.lambda_edge_bucket}"
  s3_key        = "${var.lambda_edge_html_key}"
  function_name = "${var.project_prefix}-lambda-edge-html"
  role          = "${aws_iam_role.lambda_edge.arn}"
  handler       = "index.handler"
  publish       = true # WARNING: don't use this in production as Terraform sometimes doesn't get dependencies correct, just use terraform to create the initial infra then update using AWS CLI

  source_code_hash = "${var.lambda_html_hash}"

  runtime = "nodejs10.x"

  // environment vars are not allowed in edge lambdas
}

# lambda logging
resource "aws_cloudwatch_log_group" "test_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_edge_html.function_name}"
  retention_in_days = 3
}

# OUTPUTS

# output "lambda_html_invoke_arn" {
#   value = "${aws_lambda_function.lambda_edge_html.invoke_arn}"
# }
# output "lambda_html_function_name" {
#   value = "${aws_lambda_function.lambda_edge_html.function_name}"
# }

output "edge_lambda_html_qualified_arn" {
  value = "${aws_lambda_function.lambda_edge_html.qualified_arn}"
}
