resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_client_configuration" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  cluster_name         = var.cluster_name
  endpoints            = var.nodes.controlplane
  nodes                = [var.nodes.controlplane[0]]
}

data "talos_machine_configuration" "controlplane" {
  cluster_endpoint = "https://192.168.1.101:6443"
  cluster_name     = var.cluster_name
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  machine_type     = "controlplane"

  config_patches = [
    file("../patches/${var.cluster_name}/controlplane.yaml"),
    file("../patches/${var.cluster_name}/all.yaml"),
  ]

  docs               = false
  examples           = false
  kubernetes_version = var.kubernetes_version
  talos_version      = talos_machine_secrets.this.talos_version
}

data "talos_machine_configuration" "worker" {
  cluster_endpoint = "https://192.168.1.101:6443"
  cluster_name     = var.cluster_name
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  machine_type     = "worker"

  config_patches = [
    file("../patches/${var.cluster_name}/all.yaml"),
  ]

  docs               = false
  examples           = false
  kubernetes_version = var.kubernetes_version
  talos_version      = talos_machine_secrets.this.talos_version
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each = toset(var.nodes.controlplane)

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.key
}

resource "talos_machine_configuration_apply" "worker" {
  for_each = toset(var.nodes.worker)

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.key
}

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.nodes.controlplane[0]

  depends_on = [
    talos_machine_configuration_apply.controlplane,
  ]
}

data "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.nodes.controlplane[0]
}
