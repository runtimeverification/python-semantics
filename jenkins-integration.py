#!/usr/bin/env python3.2

from xml.etree import ElementTree as ET
import sys
import os
import re

testsuite = ET.Element("testsuite")

for filename in sys.argv[1:]:
  try:
    testcase = ET.SubElement(testsuite, "testcase")
    testcase.set("name", re.sub(r"\.out$", ".py", filename))
    if os.path.isfile(filename) and os.stat(filename).st_mtime > os.stat(filename + ".tmp").st_mtime:
      outfile = open(filename, "r").read()
      fail = False
    elif os.path.isfile(filename + ".tmp"):
      outfile = open(filename + ".tmp", "r").read()
      if outfile.strip() == "":
        raise IOError("test results not found for " + filename)
      fail = True
    else:
      raise IOError("test results not found for " + filename)
    testcase.set("time", str(int(re.match(r".*\(([0-9]*)ms real\)", outfile).group(1)) // 1000))
    testcase.set("status", "unstable" if fail else "success")
    system_out = ET.SubElement(testcase, "system-out")
    system_out.text = outfile
  except:
    print(filename)
    raise
  
doc = ET.ElementTree(testsuite)
doc.write("junit-results.xml")
