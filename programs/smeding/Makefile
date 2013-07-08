TESTS = $(wildcard *.py)
NOT_TESTS = 
REAL_TESTS = $(filter-out ${NOT_TESTS}, ${TESTS})
TEST_RESULTS = ${REAL_TESTS:.py=.out}
TEST_REFERENCE = ${REAL_TESTS:.py=.ref}

.PHONY: test

test: ${TEST_RESULTS}

ref: ${TEST_REFERENCE}

%.out: %.py
	@echo "Testing $<"
	@../../kpython --output-mode raw -- driver/driver.py $< > $@.tmp
	@- test "`grep "< k > .K </ k >" $@.tmp`" && cp $@.tmp $@ && echo "$< passed"

%.ref: %.py
	-PYTHONHASHSEED=1 python3.3 driver/driver.py $< > /dev/null 2>&1 && touch $@

clean:
	rm -f *.out *.ref *.out.tmp
