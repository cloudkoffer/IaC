# Provisioning / Kubernetes / Talos / Terraform

## Prerequisite

### CLI tools

- terraform
- talosctl
- kubectl

## Installation

- Configure environment variables.

  ``` shell
  vi .envrc
  ```

- Boot the nodes using either USB sticks or a network boot (F12).

- Wait until the nodes have entered `maintenance` mode.

  ``` shell
  for node in {1..10}; do
    echo -n "Node ${node}: "
    talosctl get machinestatus \
      --nodes="192.168.1.${node}" \
      --output=jsonpath='{.spec.stage}' \
      --insecure
  done
  ```

- Initialise Terraform state

  ``` shell
  terraform init -upgrade
  ```

- Check and correct Terraform formatting if necessary.

  ``` shell
  terraform fmt -recursive
  ```

- Validate Terraform configuration.

  ``` shell
  terraform validate
  ```

- Execute a Terraform plan.

  ``` shell
  terraform plan
  ```

- Execute a Terraform apply.

  ``` shell
  terraform apply
  ```

- Retrieve talosconfig.

  ``` shell
  terraform output -raw talosconfig > talosconfig
  export TALOSCONFIG="$(pwd)/talosconfig"
  ```

- Wait until cluster is healthy.

  ``` shell
  talosctl health
  ```

- Retrieve kubeconfig.

  ``` shell
  terraform output -raw kubeconfig_raw > kubeconfig
  export KUBECONFIG="$(pwd)/kubeconfig"
  ```

<!--
## Post-Installation

- Install `directpv`

  ``` shell
  kubectl krew install directpv
  kubectl directpv install
  kubectl directpv drives ls
  kubectl directpv drives format --drives /dev/nvme1n1 --nodes node-1,node-2,node-3
  ```
-->

## Maintenance

``` shell
export TALOSCONFIG="$(pwd)/talosconfig"
export KUBECONFIG="$(pwd)/kubeconfig"
```

- Upgrade Talos.

  > **INFO**: Perform the upgrade one by one for each node.

  ``` shell
  TALOS_VERSION=v1.7.4

  talosctl upgrade \
    --image="ghcr.io/siderolabs/installer:${TALOS_VERSION}" \
    --nodes=192.168.1.x
  ```

- Stage-Upgrade Talos

  > **INFO**: Use if the above upgrade fails due to a process holding a file open on disk.

  ``` shell
  TALOS_VERSION=v1.7.4

  talosctl upgrade \
    --image="ghcr.io/siderolabs/installer:${TALOS_VERSION}" \
    --nodes=192.168.1.x \
    --stage

  talosctl reboot \
    --nodes=192.168.1.x \
    --wait
  ```

- Upgrade Kubernetes.

  ``` shell
  KUBERNETES_VERSION=1.30.1

  talosctl upgrade-k8s \
    --to="${K8S_VERSION}"
  ```
