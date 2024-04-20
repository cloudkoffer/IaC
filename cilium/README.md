# Talos / Deployment Talos / Cilium

- Create manifests.

  ``` shell
  helm repo add cilium https://helm.cilium.io/

  # https://github.com/cilium/cilium/blob/main/install/kubernetes/cilium/Chart.yaml
  helm template cilium cilium/cilium \
    --version 1.13.3 \
    --namespace kube-system \
    --values values.yaml \
    > manifests.yaml
  ```

- Update controlplane patch files.
