cluster_name       = "talos-cloudkoffer-v1"
cluster_endpoint   = "https://192.168.1.101:6443"
talos_version      = "v1.7.4"
kubernetes_version = "1.30.1"
nodes = {
  controlplane = [
    "192.168.1.1",
    "192.168.1.2",
    "192.168.1.3",
  ]
  worker = [
    "192.168.1.4",
    "192.168.1.5",
  ]
}
