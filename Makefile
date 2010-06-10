
VERSION=dev
BUILD=1
TESTS=spectrum_tests_suite
LITMUS_ROOT=ext/litmus.js

src/spectrum.js: src/spectrum.src.js
	perl -e 'undef $$/; $$_ = <STDIN>; s{rule{(.*?)}x}{$$a=$$1;$$a =~ s{//.*?$$}{}gm; $$a =~ s/\s+//gs; $$a =~ s/\\h/[ \\t]/g; $$a =~ s{/}{\\/}g; "/$$a/g"}sge; print' < src/spectrum.src.js > src/spectrum.js

test: src/spectrum.js ext/litmus.js/ext/pkg.js/src/pkg.js
	$(LITMUS_ROOT)/bin/litmus -I swipe:ext/swipe.js/src -I spectrum:src -I spectrum_tests:tests $(TESTS)

ext/litmus.js/ext/pkg.js/src/pkg.js:
	git submodule init && \
	git submodule update && \
	cd ext/litmus.js && \
	make

BUILD/usr/share/js:
	mkdir -p BUILD/usr/share/js

BUILD/usr/share/js/spectrum.js: BUILD/usr/share/js src/spectrum.js
	java -jar ext/yuicompressor.jar --type js src/spectrum.js > BUILD/usr/share/js/spectrum.js

BUILD/usr/share/js/spectrum.debug.js: BUILD/usr/share/js src/spectrum.js
	cp src/spectrum.js BUILD/usr/share/js/spectrum.debug.js

RPMS/noarch/spectrum.js-$(VERSION)-$(BUILD).noarch.rpm: BUILD/usr/share/js/spectrum.js BUILD/usr/share/js/spectrum.debug.js
	mkdir -p {BUILD,RPMS,SRPMS} && \
	rpmbuild --define '_topdir $(CURDIR)' --define 'version $(VERSION)' --define 'release $(BUILD)' -bb SPECS/spectrum.js.spec

dist: RPMS/noarch/spectrum.js-$(VERSION)-$(BUILD).noarch.rpm

clean:
	rm -rf BUILD RPMS filelist spectrum-js-*

