terraform {
  required_version = ">= 1.10"

  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.3"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.1"
    }
  }

  backend "s3" {
    bucket                      = "master"
    key                         = "tofu/servers.tfstate"
    region                      = "ru-1"
    endpoints                   = { s3 = "https://s3.twcstorage.ru" }
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    use_lockfile                = true
  }

  encryption {
    key_provider "pbkdf2" "main" {
      passphrase = var.state_passphrase
    }
    method "aes_gcm" "main" {
      keys = key_provider.pbkdf2.main
    }
    state {
      method   = method.aes_gcm.main
      enforced = true
    }
    plan {
      method   = method.aes_gcm.main
      enforced = true
    }
  }
}
