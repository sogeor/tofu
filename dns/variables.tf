variable "state_passphrase" {
  description = "Passphrase for OpenTofu state and plan encryption (also decrypts the servers state)."
  type        = string
  sensitive   = true
}

variable "zone" {
  description = "Cloudflare zone name."
  type        = string
  default     = "sogeor.com"
}

variable "zone_id" {
  description = "Cloudflare zone ID of var.zone (not secret)."
  type        = string
  default     = "99100f74ede67e0951e4b06a2d4f92fc"
}
