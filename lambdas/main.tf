variable "private_bucket" {}
variable "lambda_json_key" {}
variable "lambda_json_hash" {}
variable "project_prefix" {}

resource "aws_iam_role" "lambda" {
  name = "${var.project_prefix}-iam-role"

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

resource "aws_iam_role_policy_attachment" "basic_execution_policy" {
  role = "${aws_iam_role.lambda.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# https://www.terraform.io/docs/providers/aws/r/lambda_function.html
resource "aws_lambda_function" "example_json_lambda" {
  s3_bucket = "${var.private_bucket}"
  s3_key = "${var.lambda_json_key}"
  function_name = "exampleLambdaJson"
  role = "${aws_iam_role.lambda.arn}"
  handler = "index.handler"
  publish = true # don't need this if updating code outside of terrafrom

  source_code_hash = "${var.lambda_json_hash}"

  runtime = "nodejs10.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

# lambda logging
resource "aws_cloudwatch_log_group" "test_lambda" {
  name = "/aws/lambda/${aws_lambda_function.example_json_lambda.function_name}"
  retention_in_days = 3
}

# OUTPUTS

output "lambda_json_invoke_arn" {
  value = "${aws_lambda_function.example_json_lambda.invoke_arn}"
}
output "lambda_json_function_name" {
  value = "${aws_lambda_function.example_json_lambda.function_name}"
}

output "lambda_json_qualified_arn" {
  value = "${aws_lambda_function.example_json_lambda.qualified_arn}"
}
