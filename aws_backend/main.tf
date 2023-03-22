provider "aws" {
  region = "eu-west-3"
}

data "archive_file" "lambda_backend_function" {
  type        = "zip"
  source_file  = "lambda_function.py"
  output_path = "lambda_backend_function.zip"
}


data "aws_iam_role" "academy_role"{
    name = "academy2023-lambda-role"

}


resource "aws_lambda_function" "my_lambda_function" {
  function_name = "my_lambda_function"
  filename      = "lambda_backend_function.zip"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.9"
source_code_hash = filebase64sha256("lambda_backend_function.zip")
  role = data.aws_iam_role.academy_role.arn

      tags = {
    projet = "academy2023"
    etudiant="MehdiBehira"
  }
}



# API Gateway
resource "aws_api_gateway_rest_api" "my_api" {
  name = "my_api"
        tags = {
    projet = "academy2023"
    etudiant="MehdiBehira"
  }
}

# API Gateway Resource
resource "aws_api_gateway_resource" "proxy_api" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "{proxy+}"
}

# API Gateway Method
resource "aws_api_gateway_method" "proxy_api" {
  //for_each      = toset(["OPTIONS", "PUT", "DELETE", "GET", "POST", "PATCH", "PUT"])
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.proxy_api.id
  http_method = "ANY"
  authorization = "NONE"

}

resource "aws_api_gateway_method" "proxy_root" {
  //for_each      = toset(["OPTIONS", "PUT", "DELETE", "GET", "POST", "PATCH", "PUT"])
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_rest_api.my_api.root_resource_id
  http_method = "ANY"
  authorization = "NONE"

}

# API Gateway Integration
resource "aws_api_gateway_integration" "my_api_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_method.proxy_api.resource_id
  http_method = aws_api_gateway_method.proxy_api.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.my_lambda_function.invoke_arn
}


resource "aws_api_gateway_integration" "my_api_integration_root" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.my_lambda_function.invoke_arn
}


resource "aws_api_gateway_deployment" "my_api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  depends_on  = [aws_api_gateway_integration.my_api_integration, aws_api_gateway_integration.my_api_integration_root]
  stage_name  = "test"

}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*"
}

output "api_gateway_url" {
    value = aws_api_gateway_deployment.my_api_gateway_deployment.invoke_url
}