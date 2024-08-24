start:
	$(MAKE) -C cluster start
	$(MAKE) -C argocd start
	kubectx k3d-cluster-1
	kubectl apply -k .

stop:
	kubectx k3d-cluster-1 
	kubectl delete -k . --force --grace-period=0 --ignore-not-found
	$(MAKE) -C cluster stop