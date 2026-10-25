# Email Routing: role addresses of the organization forward to the maintainer.
# The domain itself sends no mail (DMARC p=reject, null DKIM).

data "sops_file" "dns" {
  source_file = "${path.module}/dns.sops.yaml"
}

data "cloudflare_zone" "this" {
  zone_id = var.zone_id
}

locals {
  secrets   = yamldecode(data.sops_file.dns.raw)
  mailboxes = toset(["conduct", "legal", "security"])
}

# Enabling Email Routing makes Cloudflare create and lock the MX and SPF records of the apex.
resource "cloudflare_email_routing_settings" "this" {
  zone_id = var.zone_id
}

# Cloudflare sends a confirmation link to this address. Rules are rejected until it is opened.
resource "cloudflare_email_routing_address" "destination" {
  account_id = data.cloudflare_zone.this.account.id
  email      = local.secrets.email_destination
}

resource "cloudflare_email_routing_rule" "mailbox" {
  for_each = local.mailboxes

  zone_id = var.zone_id
  name    = "${each.key}@${var.zone}"
  enabled = true

  matchers = [{
    field = "to"
    type  = "literal"
    value = "${each.key}@${var.zone}"
  }]
  actions = [{
    type  = "forward"
    value = [cloudflare_email_routing_address.destination.email]
  }]

  depends_on = [cloudflare_email_routing_settings.this]
}
