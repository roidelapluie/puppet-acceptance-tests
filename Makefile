test: test-dryrun
	pybot tests
	pybot --dryrun facter

facter-dryrun:
	pybot --dryrun facter

test-dryrun: facter-dryrun
	pybot --dryrun tests
