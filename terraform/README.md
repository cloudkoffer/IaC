# Talos / Deployment Talos / Terraform

## Prerequisite

### CLI tools

- terraform
- talosctl
- kubectl

## Installation

- Configure environment variables.

  ``` shell
  CLOUDKOFFER=v3 # v1, v2, v3
  CLUSTER_NAME="talos-cloudkoffer-${CLOUDKOFFER}"

  case "${CLOUDKOFFER}" in
    v1) NUMBER_OF_NODES=5 ;;
    v2) NUMBER_OF_NODES=10 ;;
    v3) NUMBER_OF_NODES=10 ;;
  esac
  ```

- Boot the nodes using either USB sticks or a network boot (F12).

- Wait until the nodes have entered `maintenance` mode.

  ``` shell
  for i in {1..${NUMBER_OF_NODES}}; do
    echo -n "Node ${i}: "
    talosctl get machinestatus \
      --nodes="192.168.1.${i}" \
      --output="jsonpath='{.spec.stage}'" \
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
  terraform plan -var-file="configs/${CLUSTER_NAME}.tfvars"
  ```

- Execute a Terraform apply.

  ``` shell
  terraform apply -var-file="configs/${CLUSTER_NAME}.tfvars"
  ```

- Retrieve talosconfig.

  ``` shell
  terraform output -raw talosconfig > talosconfig
  talosctl config merge talosconfig
  rm -rf talosconfig
  ```

- Configure talosctl default context.

  ``` shell
  talosctl config use-context "${CLUSTER_NAME}"
  ```

- Wait until cluster is healthy.

  ``` shell
  talosctl health
  ```

- Retrieve kubeconfig.

  ``` shell
  talosctl kubeconfig
  ```

- Configure kubectl default context.

  ``` shell
  kubectl config use-context "admin@${CLUSTER_NAME}"
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
