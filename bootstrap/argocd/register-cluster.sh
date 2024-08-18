#! /bin/bash

set -o errexit      # Exit on most errors (see the manual)
set -o nounset      # Disallow expansion of unset variables
set -o pipefail     # Use last non-zero exit code in a pipeline

argocd login localhost:8080 --insecure --username admin --password $(argocd admin initial-password -n argocd | grep -o '^\S*')
argocd repo add git@github.com:pradithya/argocd-hack.git --ssh-private-key-path ~/.ssh/id_rsa

argocd cluster add k3d-cluster-2 -y || true
argocd cluster add k3d-cluster-3 -y || true

docker network connect k3d-cluster-1 k3d-cluster-2-server-0
docker network connect k3d-cluster-1 k3d-cluster-3-server-0

kubectx k3d-cluster-2
CLUSTER_2_TOKEN=$(kubectl get secret $(kubectl get secret -n kube-system | grep argocd | awk '{print $1}') -n kube-system -o json | jq  -r .data.token | base64 -d)
CLUSTER_2_CA=$(k3d kubeconfig get cluster-2 | yq '.clusters[0].cluster.certificate-authority-data')
echo $CLUSTER_2_CA
kubectx k3d-cluster-3
CLUSTER_3_TOKEN=$(kubectl get secret $(kubectl get secret -n kube-system | grep argocd | awk '{print $1}') -n kube-system -o json | jq  -r .data.token | base64 -d)
CLUSTER_3_CA=$(k3d kubeconfig get cluster-3 | yq '.clusters[0].cluster.certificate-authority-data')
echo $CLUSTER_3_CA

kubectx k3d-cluster-1

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  namespace: argocd
  name: k3d-cluster-2-cluster-secret
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: k3d-cluster-2
  server: "https://k3d-cluster-2-server-0:6443"
  config: | 
    {
      "bearerToken": "${CLUSTER_2_TOKEN}",
      "tlsClientConfig": { 
        "insecure": false, 
        "caData": "${CLUSTER_2_CA}"
      } 
    }
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  namespace: argocd
  name: k3d-cluster-3-cluster-secret
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: k3d-cluster-3
  server: "https://k3d-cluster-3-server-0:6443"
  config: | 
    {
      "bearerToken": "${CLUSTER_3_TOKEN}",
      "tlsClientConfig": { 
        "insecure": false, 
        "caData": "${CLUSTER_3_CA}"
      } 
    }
EOF

echo "========================================================================"
echo "========================================================================"
echo "ArgoCD setup complete"
echo "Access the ArgoCD UI at https://localhost:8080"
echo "Username: admin"
echo "Password: $(argocd admin initial-password -n argocd | grep -o '^\S*')"
echo "========================================================================"
echo "========================================================================"