variable "cluster_name" {
  description = "The name for the Talos cluster."
  type        = string
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
