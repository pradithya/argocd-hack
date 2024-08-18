start:
	$(MAKE) -C cluster start
	$(MAKE) -C argocd start
	kubectl apply -k .

stop:
	kubectl delete -k .
	$(MAKE) -C argocd stop
	$(MAKE) -C cluster stop