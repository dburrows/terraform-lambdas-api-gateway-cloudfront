variable region {}
variable account_id {}
variable lambda_json_invoke_arn {}
variable lambda_json_function_name {}
variable lambda_json_qualified_arn {}

# https://www.terraform.io/docs/providers/aws/r/api_gateway_rest_api.html
resource "aws_api_gateway_rest_api" "example" {
  name = "example_api"
}

# equivalent to endpoint
# AWS_BUG: if you set the path part ot 'test' it breaks??
resource "aws_api_gateway_resource" "example" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  parent_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  path_part   = "helloworld"
}

resource "aws_api_gateway_method" "example" {
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  resource_id   = "${aws_api_gateway_resource.example.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "example" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  resource_id = "${aws_api_gateway_resource.example.id}"
  http_method = "${aws_api_gateway_method.example.http_method}"
  # method that the api gateway will use to call the lambda - lambdas can only be invoked by POST
  type                    = "AWS_PROXY"
  uri                     = "${var.lambda_json_invoke_arn}"
  integration_http_method = "POST"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_json_function_name}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.example.id}/*/${aws_api_gateway_method.example.http_method}${aws_api_gateway_resource.example.path}"
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = ["aws_api_gateway_integration.example"]

  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  stage_name  = "api"
}

output "lambda_public_url" {
  value = "${aws_api_gateway_deployment.example.invoke_url}${aws_api_gateway_resource.example.path}"
}
