start:
	$(MAKE) -C cluster start
	kubectl apply -k .
	$(MAKE) -C argocd start

stop:
	$(MAKE) -C argocd stop
	$(MAKE) -C cluster stop