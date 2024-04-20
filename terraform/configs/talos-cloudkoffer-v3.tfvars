cluster_name       = "talos-cloudkoffer-v3"
cluster_endpoint   = "https://192.168.1.101:6443"
kubernetes_version = "1.27.2"
talos_version      = "v1.4.5"
node_data = {
  controlplane = [
    "192.168.1.1",
    "192.168.1.2",
    "192.168.1.3",
  ]
  worker = [
    "192.168.1.4",
    "192.168.1.5",
    "192.168.1.6",
    "192.168.1.7",
    "192.168.1.8",
    "192.168.1.9",
    "192.168.1.10",
  ]
}
