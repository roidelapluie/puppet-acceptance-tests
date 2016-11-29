.PHONY: rpm

WORKSPACE ?= .

test-dryrun:
	pybot --dryrun .

test: test-dryrun
	pybot tests

rpm:
	pybot --outputdir $(WORKSPACE)/results/robot/rpm rpm/pullrequest.robot

rpm-dryrun:
	pybot --outputdir $(WORKSPACE)/results/robot/rpm --loglevel DEBUG --dryrun rpm

facter: rpm
	pybot --outputdir $(WORKSPACE)/results/robot/$@ --loglevel DEBUG --dryrun $@

