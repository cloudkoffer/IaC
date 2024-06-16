# Talos / Deployment Talos / Manual

## Prerequisite

### CLI tools

- talosctl
- kubectl

## Installation

- Configure environment variables.

  ``` shell
  vi .envrc
  ```

- Boot the nodes using either USB sticks or a network boot (F12).

- Wait until the nodes have entered maintenance mode.

  ``` shell
  for i in {1..10}; do
    echo -n "Node ${i}: "
    talosctl get machinestatus \
      --insecure \
      --nodes "192.168.1.${i}" \
      --output jsonpath='{.spec.stage}'
  done
  ```

- Create talos machine secrets.

  ``` shell
  talosctl gen secrets --output-file secrets.yaml
  ```

- Create talos client and machine configuration.

  ``` shell
  talosctl gen config "${CLUSTER_NAME}" "${CLUSTER_ENDPOINT}" \
    --config-patch="@../patches/${CLUSTER_NAME}/all.yaml" \
    --config-patch-control-plane="@../patches/${CLUSTER_NAME}/controlplane.yaml" \
    --install-image="ghcr.io/siderolabs/installer:${TALOS_VERSION}" \
    --kubernetes-version="${KUBERNETES_VERSION}" \
    --with-docs=false \
    --with-examples=false \
    --with-secrets=secrets.yaml

  export TALOSCONFIG="$(pwd)/talosconfig"
  talosctl config endpoint 192.168.1.1 192.168.1.2 192.168.1.3
  talosctl config node 192.168.1.1
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
  for node in "${NODES_CONTROLPLANE[@]}"; do
    talosctl apply-config \
      --nodes="${node}" \
      --file=controlplane.yaml \
      --insecure
  done

  for node in "${NODES_WORKER[@]}"; do
    talosctl apply-config \
      --nodes="${node}" \
      --file=worker.yaml \
      --insecure
  done
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
  talosctl kubeconfig kubeconfig
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
    --to="${KUBERNETES_VERSION}"
  ```
