variable "cluster_name" {
  description = "The name for the Talos cluster."
  type        = string
  nullable    = false
}

variable "cluster_endpoint" {
  description = "The endpoint for the Talos cluster."
  type        = string
  default     = "https://192.168.1.101:6443"
  nullable    = false
}

variable "nodes" {
  description = "A map of node data."
  type = object({
    controlplane = list(string)
    worker       = list(string)
  })
  nullable = false
}

variable "talos_version" {
  description = "The talos version for the Talos cluster."
  type        = string
  nullable    = false
}

variable "kubernetes_version" {
  description = "The kubernetes version for the Talos cluster."
  type        = string
  nullable    = false
}
