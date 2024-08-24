apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- namespace.yaml

helmCharts:
- name: base
  namespace: infrastructure
  includeCRDs: true
  valuesFile: values.yaml
  additionalValuesFiles:
    - ${ARGOCD_ENV_PATH}/values.yaml
  releaseName: istio-base
  version: ${ARGOCD_ENV_VERSION}
  repo: https://istio-release.storage.googleapis.com/charts
