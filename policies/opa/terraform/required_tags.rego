package terraform.aws.tags

required_tags := {"Environment", "Team", "CostCenter"}

deny[msg] {
  resource := input.resource_changes[_]
  resource.mode == "managed"
  resource.provider_name == "registry.terraform.io/hashicorp/aws"
  tags := {tag | resource.change.after.tags[tag]}
  missing := required_tags - tags
  count(missing) > 0
  msg := sprintf("AWS resource %s missing required tags: %v", [resource.address, missing])
}
