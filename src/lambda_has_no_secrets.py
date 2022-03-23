from rdklib import Evaluator, Evaluation, ConfigRule, ComplianceType
from detect_secrets import SecretsCollection
from detect_secrets.settings import default_settings
import json

APPLICABLE_RESOURCES = ['AWS::Lambda::Function']


class lambda_has_no_secret_keys(ConfigRule):
  def evaluate_change(self, event, client_factory, configuration_item,
                      valid_rule_parameters):

    lamda_client = client_factory.build_client('lambda')
    resource_type = configuration_item.get('resourceType')

    if resource_type == 'AWS::Lambda::Function':
      resource_id = configuration_item.get('resourceId')

      envVariables = get_env_variables(lamda_client, resource_id)

      filename = "/tmp/variables.txt"
      with open(filename, 'w+') as outfile:
        json.dump(envVariables, outfile)

      secrets = scan_file_for_secrets(filename)
      if secrets:
        return [Evaluation(ComplianceType.NON_COMPLIANT, resource_id,
                           APPLICABLE_RESOURCES[0],
                           json.dumps(secrets.json()[filename][0]["type"], indent=2))]
      return [Evaluation(ComplianceType.COMPLIANT)]
    return [Evaluation(ComplianceType.NOT_APPLICABLE)]

  def evaluate_parameters(self, rule_parameters):
    valid_rule_parameters = rule_parameters
    return valid_rule_parameters


def get_env_variables(lambda_client, resource_id):
  lambda_config = lambda_client.get_function_configuration(
    FunctionName=resource_id)
  if lambda_config is not None:
    return lambda_config.get('Environment').get('Variables')
  return {}


def scan_file_for_secrets(filename):
  secrets = SecretsCollection()
  with default_settings():
    secrets.scan_file(filename)
  return secrets


################################
# DO NOT MODIFY ANYTHING BELOW #
################################
def lambda_handler(event, context):
  my_rule = lambda_has_no_secret_keys()
  evaluator = Evaluator(my_rule, APPLICABLE_RESOURCES)
  return evaluator.handle(event, context)
