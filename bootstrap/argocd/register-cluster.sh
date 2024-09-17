#! /bin/bash

set -o errexit      # Exit on most errors (see the manual)
set -o nounset      # Disallow expansion of unset variables
set -o pipefail     # Use last non-zero exit code in a pipeline

argocd login localhost:8080 --insecure --username admin --password $(argocd admin initial-password -n argocd | grep -o '^\S*')
argocd repo add git@github.com:pradithya/argocd-hack.git --ssh-private-key-path ~/.ssh/id_rsa

# Add the k3d clusters to ArgoCD, this step will fail since the clusters are not reachable from the ArgoCD control plane
# We will fix this in the next steps
# Executing this step will create ArgoCD token in the target clusters, which we will use for creating the cluster credential
argocd cluster add k3d-cluster-1 -y || true
argocd cluster add k3d-cluster-2 -y || true
argocd cluster add k3d-cluster-3 -y || true

# Connect k3d-cluster-1 to the control plane of k3d-cluster-2 and k3d-cluster-3 so that ArgoCD can reach their API servers
docker network connect k3d-cluster-1 k3d-cluster-2-server-0
docker network connect k3d-cluster-1 k3d-cluster-3-server-0

# Get Token and CA of the target clusters
kubectx k3d-cluster-1
CLUSTER_1_TOKEN=$(kubectl get secret $(kubectl get secret -n kube-system | grep argocd | awk '{print $1}') -n kube-system -o json | jq  -r .data.token | base64 -d)
CLUSTER_1_CA=$(k3d kubeconfig get cluster-1 | yq '.clusters[0].cluster.certificate-authority-data')
echo $CLUSTER_1_CA
kubectx k3d-cluster-2
CLUSTER_2_TOKEN=$(kubectl get secret $(kubectl get secret -n kube-system | grep argocd | awk '{print $1}') -n kube-system -o json | jq  -r .data.token | base64 -d)
CLUSTER_2_CA=$(k3d kubeconfig get cluster-2 | yq '.clusters[0].cluster.certificate-authority-data')
echo $CLUSTER_2_CA
kubectx k3d-cluster-3
CLUSTER_3_TOKEN=$(kubectl get secret $(kubectl get secret -n kube-system | grep argocd | awk '{print $1}') -n kube-system -o json | jq  -r .data.token | base64 -d)
CLUSTER_3_CA=$(k3d kubeconfig get cluster-3 | yq '.clusters[0].cluster.certificate-authority-data')
echo $CLUSTER_3_CA


# Create the cluster credentials in the ArgoCD control plane based on the token and CA of the target clusters
kubectx k3d-cluster-1

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  namespace: argocd
  name: k3d-cluster-1-cluster-secret
  labels:
    argocd.argoproj.io/secret-type: cluster
    environment: development
type: Opaque
stringData:
  name: k3d-cluster-1
  server: "https://k3d-cluster-1-server-0:6443"
  config: | 
    {
      "bearerToken": "${CLUSTER_1_TOKEN}",
      "tlsClientConfig": { 
        "insecure": false, 
        "caData": "${CLUSTER_1_CA}"
      } 
    }
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  namespace: argocd
  name: k3d-cluster-2-cluster-secret
  labels:
    argocd.argoproj.io/secret-type: cluster
    environment: integration
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
    environment: production
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
echo "List of clusters"
echo "$(argocd cluster list)"
echo "========================================================================"
echo "========================================================================"
