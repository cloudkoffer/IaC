terraform {
  required_providers {
    # https://github.com/siderolabs/terraform-provider-talos/releases
    talos = {
      source  = "siderolabs/talos"
      version = "0.5.0"
    }
  }
}

provider "talos" {}
