test: test-dryrun
	pybot tests

rpm:
	pybot rpm

rpm-dryrun:
	pybot --dryrun rpm

test-dryrun: rpm-dryrun
	pybot --dryrun tests
