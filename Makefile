TESTS = $(wildcard programs/*.py)
TEST_RESULTS = ${TESTS:.py=.out}

test: ${TEST_RESULTS}

%.out: %.py python-compiled.maude
	test -n "`krun --parser=./parser $< | grep "< k > (.).K </ k >"`"
	@ cp .k/krun_tmp/maude_out $@

python-compiled.maude: ?*.k
	kompile python.k

clean:
	rm -rf .k
	rm -f python-compiled.maude
	rm -f kompile_*
	rm -f all_tokens.tok
	rm -f kmain-python.maude python.maude shared.maude
	rm -f out
	rm -f programs/*.out
