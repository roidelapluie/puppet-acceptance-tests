.PHONY: rpm

test: test-dryrun
	pybot tests

rpm:
	pybot rpm

rpm-dryrun:
	pybot --loglevel DEBUG --dryrun rpm

test-dryrun: rpm-dryrun
	pybot --dryrun tests
