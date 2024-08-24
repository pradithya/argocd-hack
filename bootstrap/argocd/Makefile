start:
	kubectx k3d-cluster-1
	kubectl apply -n argocd -k .
	kubectl rollout status deploy/argocd-server -n argocd -w --timeout=5m
	kubectl rollout status statefulset/argocd-redis-ha-server -n argocd -w --timeout=5m
	./register-cluster.sh

stop:
	kubectx k3d-cluster-1
	kubectl delete -n argocd -k . --force --grace-period=0 --ignore-not-found
	