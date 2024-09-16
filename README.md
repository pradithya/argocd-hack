# ArgoCD Hack

Repository for experimenting with ArgoCD multi cluster setup.

## Requirements

- [K3d](https://k3d.io/v5.7.3/)
- [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/)
- [yq](https://github.com/mikefarah/yq)
- You need to add SSH key to the GitHub account and store the private key in the `~/.ssh/id_rsa` file. The same SSH key pair will be used by ArgoCD to access this repository.

## Getting Started

To start the local cluster, run the following command:

```bash
make
```

This command will:
1. Create 3 k3d clusters
2. Install ArgoCD in the first cluster (k3d-cluster-1)
3. Install ArgoCD applications
