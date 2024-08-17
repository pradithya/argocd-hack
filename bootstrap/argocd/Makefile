start:
	kubectx k3d-cluster-1
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
	kubectl rollout status deploy/argocd-server -n argocd -w --timeout=5m
	./register-cluster.sh

stop:
	kubectx k3d-cluster-1
	kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl delete -f -
	