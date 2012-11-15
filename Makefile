TESTS = $(wildcard programs/test*.py)
TEST_RESULTS = ${TESTS:.py=.out}
TEST_REFERENCE = ${TESTS:.py=.ref}

.PHONY: all test ref clean test-clean

all:	python-compiled.maude

test: ${TEST_RESULTS}

ref: ${TEST_REFERENCE}

%.out: %.py python-compiled.maude
	./kpython $< > $@.tmp
	-@ test "`grep "< k > (.).K </ k >" $@.tmp`" && cp $@.tmp $@

%.ref: %.py
	- python3.2 $< > /dev/null 2>&1 && touch $@

python-compiled.maude: ?*.k
	kompile python.k -v

clean: test-clean
	rm -rf .k
	rm -f python-compiled.maude
	rm -f kompile_*
	rm -f all_tokens.tok
	rm -f kmain-python.maude python.maude shared.maude
	rm -f out
	rm -f IN.maude
	rm -f *.k~

test-clean:
	rm -f programs/*.out programs/*.ref programs/*.out.tmp
