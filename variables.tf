
variable "config_rule_name" {
  type        = string
  description = "Config rule name"
  default     = "lambda_has_no_secrets"
}

variable "enabled" {
  description = "Enable the module in the current region"
  default = true
}