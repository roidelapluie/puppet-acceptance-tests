test:
	find . -type f -name '*.sh' -print -exec bash -n '{}' ';'

test-facter:
	./runtests.sh facter
