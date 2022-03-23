output "ConfigRuleName" {
  value = var.config_rule_name == "" ? aws_config_config_rule.lambda_has_no_secrets[0].name : var.config_rule_name
}