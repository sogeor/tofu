data "terraform_remote_state" "servers" {
  backend = "s3"
  config = {
    bucket                      = "master"
    key                         = "tofu/servers.tfstate"
    region                      = "ru-1"
    endpoints                   = { s3 = "https://s3.twcstorage.ru" }
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}

locals {
  comment = "Managed by OpenTofu: sogeor/tofu dns"

  # Addresses stay sensitive so they never appear in plan output or CI logs.
  servers = sensitive(data.terraform_remote_state.servers.outputs.servers)
  names   = toset(nonsensitive(keys(local.servers)))

  # Service name => Ansible group whose hosts it points to.
  services = {
    master = "control_plane" # Kubernetes API endpoint
    status = "status"        # Gatus
  }
  service_records = merge([
    for service, group in local.services : {
      for name in local.names : "${service}-${name}" => { host = name, service = service }
      if contains(nonsensitive(local.servers[name].groups), group)
    }
  ]...)
}

resource "cloudflare_dns_record" "server" {
  for_each = local.names

  zone_id = var.zone_id
  name    = "${each.key}.${var.zone}"
  type    = "A"
  content = local.servers[each.key].ipv4
  ttl     = 1
  proxied = false
  comment = local.comment
}

resource "cloudflare_dns_record" "service" {
  for_each = local.service_records

  zone_id = var.zone_id
  name    = "${each.value.service}.${var.zone}"
  type    = "A"
  content = local.servers[each.value.host].ipv4
  ttl     = 1
  proxied = false
  comment = local.comment
}

# The apex has no site: a proxied placeholder (TEST-NET-1, never reached) lets the
# redirect rule below answer every request at the edge.
resource "cloudflare_dns_record" "apex" {
  zone_id = var.zone_id
  name    = var.zone
  type    = "A"
  content = "192.0.2.1"
  ttl     = 1
  proxied = true
  comment = local.comment
}

resource "cloudflare_ruleset" "redirect" {
  zone_id = var.zone_id
  name    = "redirect"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  rules = [{
    action      = "redirect"
    description = "Apex to the GitHub organization"
    enabled     = true
    expression  = "(http.host eq \"${var.zone}\")"
    action_parameters = {
      from_value = {
        preserve_query_string = false
        status_code           = 301
        target_url = {
          value = "https://github.com/sogeor"
        }
      }
    }
  }]
}

# GitHub Pages: documentation site.
resource "cloudflare_dns_record" "docs" {
  zone_id = var.zone_id
  name    = "docs.${var.zone}"
  type    = "CNAME"
  content = "sogeor.github.io"
  ttl     = 1
  proxied = true
  comment = local.comment
}

# GitHub organization domain verification (Settings → Verified & approved domains).
resource "cloudflare_dns_record" "github_verification" {
  zone_id = var.zone_id
  name    = "_gh-sogeor-o.${var.zone}"
  type    = "TXT"
  content = "\"5f2bd0a29d\""
  ttl     = 1
  comment = local.comment
}

# Empty DKIM key for every selector: no message is signed for this domain.
resource "cloudflare_dns_record" "dkim_null" {
  zone_id = var.zone_id
  name    = "*._domainkey.${var.zone}"
  type    = "TXT"
  content = "\"v=DKIM1; p=\""
  ttl     = 1
  comment = local.comment
}

resource "cloudflare_dns_record" "dmarc" {
  zone_id = var.zone_id
  name    = "_dmarc.${var.zone}"
  type    = "TXT"
  content = "\"v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s;\""
  ttl     = 1
  comment = local.comment
}

# Only Let's Encrypt may issue certificates (cert-manager, Caddy). Cloudflare adds
# CAA records for its own certificate authorities itself while Universal SSL is on.
resource "cloudflare_dns_record" "caa" {
  for_each = {
    iodef = "mailto:security@${var.zone}"
    issue = "letsencrypt.org"
  }

  zone_id = var.zone_id
  name    = var.zone
  type    = "CAA"
  ttl     = 1
  comment = local.comment
  data = {
    flags = 0
    tag   = each.key
    value = each.value
  }
}

resource "cloudflare_zone_dnssec" "this" {
  zone_id = var.zone_id
  status  = "active"
}
