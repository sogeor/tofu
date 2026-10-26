# Telegram Bot API proxy at tg.sogeor.com for the status page alerts (see workers/telegram-proxy.js).

resource "cloudflare_workers_script" "telegram_proxy" {
  account_id         = data.cloudflare_zone.this.account.id
  script_name        = "telegram-proxy"
  main_module        = "telegram-proxy.js"
  content_file       = "${path.module}/workers/telegram-proxy.js"
  content_sha256     = filesha256("${path.module}/workers/telegram-proxy.js")
  compatibility_date = "2026-10-01"

  bindings = [{
    name = "BOT_ID"
    type = "plain_text"
    text = var.telegram_bot_id
  }]

  # The request path contains the bot token: no Workers logs or Logpush.
  logpush = false
  observability = {
    enabled = false
  }
}

resource "cloudflare_workers_custom_domain" "telegram_proxy" {
  account_id = data.cloudflare_zone.this.account.id
  zone_id    = var.zone_id
  hostname   = "tg.${var.zone}"
  service    = cloudflare_workers_script.telegram_proxy.script_name
}
