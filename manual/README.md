# Talos / Deployment Talos / Manual

## Prerequisite

### CLI tools

- talosctl
- kubectl

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

  TALOS_VERSION="v1.4.5"
  K8S_VERSION="1.27.2"
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

- Create configuration.

  ``` shell
  talosctl gen secrets --output-file secrets.yaml
  ```

  ``` shell
  # option 1 - single step
  talosctl gen config "${CLUSTER_NAME}" https://192.168.1.101:6443 \
    --with-secrets=secrets.yaml \
    --config-patch="@../patches/${CLUSTER_NAME}/all.yaml" \
    --config-patch-control-plane="@../patches/${CLUSTER_NAME}/controlplane.yaml" \
    --config-patch-worker="@../patches/${CLUSTER_NAME}/worker.yaml" \
    --install-disk=/dev/nvme0n1 \
    --install-image="ghcr.io/siderolabs/installer:${TALOS_VERSION}" \
    --kubernetes-version="${K8S_VERSION}" \
    --with-docs=false \
    --with-examples=false
  ```

  ``` shell
  # option 2 - multiple steps
  talosctl gen config "${CLUSTER_NAME}" https://192.168.1.101:6443 \
    --with-secrets=secrets.yaml \
    --install-disk=/dev/nvme0n1 \
    --install-image="ghcr.io/siderolabs/installer:${TALOS_VERSION}" \
    --kubernetes-version="${K8S_VERSION}" \
    --with-docs=false \
    --with-examples=false
  talosctl machineconfig patch controlplane.yaml \
    --patch="@../patches/${CLUSTER_NAME}/all.yaml" \
    --output=controlplane.yaml
  talosctl machineconfig patch controlplane.yaml \
    --patch="@../patches/${CLUSTER_NAME}/controlplane.yaml" \
    --output=controlplane.yaml
  talosctl machineconfig patch worker.yaml \
    --patch="@../patches/${CLUSTER_NAME}/all.yaml" \
    --output=worker.yaml
  talosctl machineconfig patch worker.yaml \
    --patch="@../patches/${CLUSTER_NAME}/worker.yaml" \
    --output=worker.yaml
  ```

- Configure endpoints and nodes for future talosctl commands.

  ``` shell
  talosctl config endpoint 192.168.1.1 192.168.1.2 192.168.1.3 --talosconfig=talosconfig
  talosctl config node 192.168.1.1 --talosconfig=talosconfig
  talosctl config merge talosconfig
  ```

- Configure talosctl default context.

  ``` shell
  talosctl config use-context "${CLUSTER_NAME}"
  ```

<!--
- Optional: Apply configuration to iPXE.

  ``` shell
  scp controlplane.yaml ubnt@192.168.1.254:/var/lib/tftpboot/
  scp worker.yaml ubnt@192.168.1.254:/var/lib/tftpboot/
  ```
-->

- Apply configuration to nodes.

  ``` shell
  # cloudkoffer-v1, cloudkoffer-v2 and cloudkoffer-v3
  talosctl apply-config --insecure --nodes=192.168.1.1 --file=controlplane.yaml
  talosctl apply-config --insecure --nodes=192.168.1.2 --file=controlplane.yaml
  talosctl apply-config --insecure --nodes=192.168.1.3 --file=controlplane.yaml
  talosctl apply-config --insecure --nodes=192.168.1.4 --file=worker.yaml
  talosctl apply-config --insecure --nodes=192.168.1.5 --file=worker.yaml
  ```

  ``` shell
  # cloudkoffer-v2 and cloudkoffer-v3
  talosctl apply-config --insecure --nodes=192.168.1.6 --file=worker.yaml
  talosctl apply-config --insecure --nodes=192.168.1.7 --file=worker.yaml
  talosctl apply-config --insecure --nodes=192.168.1.8 --file=worker.yaml
  talosctl apply-config --insecure --nodes=192.168.1.9 --file=worker.yaml
  talosctl apply-config --insecure --nodes=192.168.1.10 --file=worker.yaml
  ```

- Bootstrap kubernetes cluster.

  ``` shell
  talosctl bootstrap
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
    --context="${CLUSTER_NAME}" \
    --nodes 192.168.1.x
  ```
