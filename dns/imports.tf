# Objects created in the Cloudflare dashboard before this stack existed.
# Import blocks run in CI on the first apply; remove them afterwards.

import {
  to = cloudflare_zone_dnssec.this
  id = var.zone_id
}

import {
  to = cloudflare_dns_record.server["odin"]
  id = "${var.zone_id}/003a50f13c3b84a4706b2752b7295f92"
}

import {
  for_each = {
    "185.199.108.153" = "318793c59189e0e2e929b6f0a98164da"
    "185.199.109.153" = "a5c76b9b236a56b59b69a22701978061"
    "185.199.110.153" = "2b5db5cc1a2f39d587bca52b13c94e02"
    "185.199.111.153" = "95c38763fca6ac205cdab75b13c24d61"
  }
  to = cloudflare_dns_record.pages_apex[each.key]
  id = "${var.zone_id}/${each.value}"
}

import {
  to = cloudflare_dns_record.docs
  id = "${var.zone_id}/59fc00bb7fa6e885774ac40b566d7720"
}

import {
  to = cloudflare_dns_record.spf
  id = "${var.zone_id}/87ce5a6a99cccf4e9615e49bd2c1531c"
}

import {
  to = cloudflare_dns_record.dmarc
  id = "${var.zone_id}/3bd29a2def6fb89b0bcc245f5f5642ed"
}

import {
  to = cloudflare_dns_record.service["master-odin"]
  id = "${var.zone_id}/c92b266e3edef409ad197b96595d67ac"
}

import {
  to = cloudflare_dns_record.dkim_null
  id = "${var.zone_id}/0e383d057f2461ebea145678ed701cc6"
}
