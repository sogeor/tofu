data "sops_file" "servers" {
  source_file = "${path.module}/servers.sops.yaml"
}

locals {
  servers = yamldecode(data.sops_file.servers.raw)

  names  = toset(nonsensitive(keys(local.servers)))
  groups = toset(nonsensitive(flatten([for s in values(local.servers) : s.groups])))
}

resource "ansible_group" "this" {
  for_each = local.groups
  name     = each.key
}

resource "ansible_host" "this" {
  for_each = local.names

  name   = each.key
  groups = nonsensitive(local.servers[each.key].groups)

  variables = {
    ansible_host  = local.servers[each.key].public_ipv4
    ansible_port  = tostring(local.servers[each.key].ssh_port)
    node_kind     = local.servers[each.key].kind
    node_location = local.servers[each.key].location
    node_provider = local.servers[each.key].provider
    wg_address    = local.servers[each.key].wg_address
  }

  depends_on = [ansible_group.this]
}
