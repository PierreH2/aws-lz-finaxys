data "aws_organizations_organization" "current" {}

data "aws_organizations_organizational_units" "root_children" {
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

locals {
  root_id = data.aws_organizations_organization.current.roots[0].id
  existing_ou_by_name = {
    for ou in data.aws_organizations_organizational_units.root_children.children :
    ou.name => ou.id
  }
  target_ou_id     = lookup(local.existing_ou_by_name, var.target_ou_name, null)
  create_target_ou = var.create_target_ou_if_missing && local.target_ou_id == null
}

resource "aws_organizations_organizational_unit" "target_ou" {
  count     = local.create_target_ou ? 1 : 0
  name      = var.target_ou_name
  parent_id = local.root_id
}

resource "aws_organizations_account" "lz_account" {
  name              = var.account_name
  email             = var.account_email
  role_name         = var.account_role_name
  parent_id         = coalesce(local.target_ou_id, try(aws_organizations_organizational_unit.target_ou[0].id, null), local.root_id)
  close_on_deletion = false
}
