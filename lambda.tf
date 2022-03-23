module "lambda_function" {
  create        = var.enabled
  source        = "terraform-aws-modules/lambda/aws"
  function_name = var.config_rule_name
  description   = "Used by AWS Config to check for secret keys in lambda functions"
  handler       = "lambda_has_no_secrets.lambda_handler"
  runtime       = "python3.8"
  timeout       = 10
  publish       = true
  source_path   = "${path.module}/src/lambda_has_no_secrets.py"
  allowed_triggers = {
    AllowExecutionFromConfig = {
      principal = "config.amazonaws.com"
    }
  }
  layers = [
    module.rdklib_layer.lambda_layer_arn,
    module.detectsecretslib_layer.lambda_layer_arn
  ]
  attach_policy = true
  policy        = "arn:aws:iam::aws:policy/AWSLambda_ReadOnlyAccess"

  attach_policy_statements = true
  policy_statements = {
    AWSConfig_AssumeRole = {
      effect    = "Allow",
      actions   = ["sts:AssumeRole"],
      resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.config_rule_name}"]
    },
    AWSConfig_PutEvaluations = {
      effect    = "Allow",
      actions   = ["config:PutEvaluations"],
      resources = ["*"]
    }
  }
}

module "rdklib_layer" {
  create                 = var.enabled
  source                 = "terraform-aws-modules/lambda/aws"
  create_layer           = true
  layer_name             = "rdklib-layer"
  description            = "RDK Library Layer"
  compatible_runtimes    = ["python3.8"]
  create_package         = false
  local_existing_package = "${path.module}/src/layers/rdklib-layer.zip"
  create_role            = false
}

module "detectsecretslib_layer" {
  create                 = var.enabled
  source                 = "terraform-aws-modules/lambda/aws"
  create_layer           = true
  layer_name             = "detectsecretslib-layer"
  description            = "Detect Secrets Library Layer"
  compatible_runtimes    = ["python3.8"]
  create_package         = false
  local_existing_package = "${path.module}/src/layers/detect-secrets-layer.zip"
  create_role            = false
}