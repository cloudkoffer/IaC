# Talos / Deployment Talos / Terraform

## Prerequisite

### CLI tools

- terraform
- talosctl
- kubectl
- op

## Installation

- Configure environment variables.

  ``` shell
  CLOUDKOFFER="v3" # v1, v2, v3
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
      --insecure \
      --nodes "192.168.1.${i}" \
      --output jsonpath='{.spec.stage}'
  done
  ```

- Initialise Terraform state

  ``` shell
  GITLAB_USER="$(op read "op://QAware-Showcases/GitLab - Talos - Project Access Token/username" --account=qawaregmbh)"
  GITLAB_TOKEN="$(op read "op://QAware-Showcases/GitLab - Talos - Project Access Token/password" --account=qawaregmbh)"

  terraform init \
    -upgrade \
    -backend-config="address=https://gitlab.com/api/v4/projects/43783075/terraform/state/${CLUSTER_NAME}" \
    -backend-config="lock_address=https://gitlab.com/api/v4/projects/43783075/terraform/state/${CLUSTER_NAME}/lock" \
    -backend-config="unlock_address=https://gitlab.com/api/v4/projects/43783075/terraform/state/${CLUSTER_NAME}/lock" \
    -backend-config="username=${GITLAB_USER}" \
    -backend-config="password=${GITLAB_TOKEN}" \
    -backend-config="lock_method=POST" \
    -backend-config="unlock_method=DELETE" \
    -backend-config="retry_wait_min=5"
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

- Configure environment variables.

  ``` shell
  CLOUDKOFFER="v3" # v1, v2, v3
  CLUSTER_NAME="talos-cloudkoffer-${CLOUDKOFFER}"

  TALOS_VERSION="v1.4.5"
  K8S_VERSION="1.27.2"
  ```

- Upgrade Talos

  > **INFO**: Perform the upgrade one by one for each node.

  ``` shell
  talosctl upgrade \
    --image="ghcr.io/siderolabs/installer:${TALOS_VERSION}" \
    --context="${CLUSTER_NAME}" \
    --nodes 192.168.1.x
  ```

- Stage-Upgrade Talos

  > **INFO**: Use if the above upgrade fails due to a process holding a file open on disk.

  ``` shell
  talosctl upgrade \
    --image="ghcr.io/siderolabs/installer:${TALOS_VERSION}" \
    --stage \
    --context="${CLUSTER_NAME}" \
    --nodes 192.168.1.x

  talosctl reboot \
    --wait \
    --context="${CLUSTER_NAME}" \
    --nodes 192.168.1.x
  ```

- Upgrade Kubernetes

  ``` shell
  talosctl upgrade-k8s \
    --to="${K8S_VERSION}" \
    --context="${CLUSTER_NAME}"
  ```