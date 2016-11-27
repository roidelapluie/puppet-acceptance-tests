test: test-dryrun
	pybot tests

rpm-dryrun:
	pybot --dryrun rpm

test-dryrun: rpm-dryrun
	pybot --dryrun tests
