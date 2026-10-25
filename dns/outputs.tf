output "dnssec_ds" {
  description = "DS record published at the registrar (Cloudflare Registrar adds it automatically)."
  value       = cloudflare_zone_dnssec.this.ds
}
