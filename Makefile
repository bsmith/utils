INSTALLBIN=${HOME}/bin

.PHONY: default
default: install

.PHONY: install installdeps
installdeps:
	cpanm --installdeps .
install: installdeps
	install move_and_symlink.pl ${INSTALLBIN}/move_and_symlink

.PHONY: test
test:
	prove ./test_m_a_s.pl