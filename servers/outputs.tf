output "servers" {
  description = "Servers with connection details."
  sensitive   = true
  value = {
    for name, s in local.servers : name => {
      groups     = s.groups
      ipv4       = s.public_ipv4
      ssh        = "ssh -p ${s.ssh_port} ${s.public_ipv4}"
      wg_address = s.wg_address
    }
  }
}
