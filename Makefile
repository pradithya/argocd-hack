start:
	$(MAKE) -C bootstrap/cluster start
	$(MAKE) -C bootstrap/argocd start

stop:
	$(MAKE) -C bootstrap/argocd stop
	$(MAKE) -C bootstrap/cluster stop