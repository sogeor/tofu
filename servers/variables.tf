variable "state_passphrase" {
  description = "Passphrase for OpenTofu state and plan encryption."
  type        = string
  sensitive   = true
}
