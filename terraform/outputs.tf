output "machineconfig_controlplane" {
  value     = data.talos_machine_configuration.controlplane.machine_configuration
  sensitive = true
}

output "machineconfig_worker" {
  value     = data.talos_machine_configuration.worker.machine_configuration
  sensitive = true
}

output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.this.kubernetes_client_configuration
  sensitive = true
}

output "kubeconfig_raw" {
  value     = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}
