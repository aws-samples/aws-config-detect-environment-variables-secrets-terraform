data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_config_config_rule" "lambda_has_no_secrets" {
  count            = var.enabled ? 1 : 0
  name             = var.config_rule_name
  description      = "Ensures that Lambda function don't have secret keys in their environment variables"
  input_parameters = "{\"ExecutionRoleName\": \"${var.config_rule_name}\"}"
  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = module.lambda_function.lambda_function_arn
    source_detail {
      event_source = "aws.config"
      message_type = "ConfigurationItemChangeNotification"
    }
  }

  depends_on = [
    module.lambda_function
  ]
}