TESTS = $(wildcard programs/test*.py)
TEST_RESULTS = ${TESTS:.py=.out}
TEST_REFERENCE = ${TESTS:.py=.ref}

.PHONY: all test ref clean test-clean jenkins

all:	bootstrapped.bin

test: ${TEST_RESULTS}

jenkins: clean
	$(MAKE) jenkins-test

jenkins-test: ${TEST_RESULTS}
	./jenkins-integration.py ${TEST_RESULTS}

ref: ${TEST_REFERENCE}

%.out: %.py bootstrapped.bin
	@echo "Testing $<"
	@./kpython --output-mode raw -- $< one two "three four" > $@.tmp
	@- test "`grep "< k > .K </ k >" $@.tmp`" && cp $@.tmp $@ && echo "$< passed"


%.ref: %.py
	-PYTHONHASHSEED=1 python3.3 $< one two "three four" > /dev/null 2>&1 && touch $@

bootstrapped.bin: python-kompiled/base.maude kpython
	rm -f bootstrapped.bin
	./kpython -cPGM="bootstrap"

semantics: python-kompiled/base.maude
	test -e bootstrapped.bin && touch bootstrapped.bin

python-kompiled/base.maude: ?*.k
	kompile python.k -v --transition "allocation"

clean: test-clean
	rm -rf .k
	rm -rf python-kompiled
	rm -f bootstrapped.bin
	rm -f kompile_*
	rm -f all_tokens.tok
	rm -f kmain-python.maude python.maude shared.maude
	rm -f out
	rm -f IN.maude
	rm -f *.k~
	rm -f *.orig
	rm -f junit-results.xml
	rm -f nohup.out

test-clean:
	rm -f programs/*.out programs/*.ref programs/*.out.tmp
