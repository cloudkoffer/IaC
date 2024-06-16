terraform {
  required_providers {
    # https://github.com/siderolabs/terraform-provider-talos/releases
    talos = {
      source  = "siderolabs/talos"
      version = "0.2.0"
    }
  }
}

provider "talos" {}
