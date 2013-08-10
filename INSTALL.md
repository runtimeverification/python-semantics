## Installation

Please let us know if these instructions are insufficient or if you needed to
do any installation steps not listed explicitly.

### 1. Install basic dependencies
- The Java Virtual Machine, to run the K framework tools
- `git`, to check out the code
- `make`, to run the build script
- If using Windows, you'll probably need cygwin

### 2. Install Python 3.3
- Depending on your platform, you may be able to find a binary at http://www.python.org/getit/
- If you need to install from source, you may find the commands `apt-get build-dep python3.2` (on 
  Debian), or `yum install yum-utils; yum-builddep python3.2` (on RPM Linux) useful, otherwise you
  may install a version of python3.3 without many features.
- All the usual procedures for installing Linux software apply. See the README file for Python for
  more details.

### 3. Install K
- Download the K Framework from Github:
  <https://github.com/kframework/k>
- This version of the Python semantics works with the v3.2.1 release of the
  K framework. Download the repository and check out the tag with the following commands:
```
git clone https://github.com/kframework/k.git; git checkout tags/v3.2.1
```
- See the README included with K for build and installation instructions.

### 4. Build the Python semantics
- Ensures `kompile` and `krun` are included in your `$PATH`.
- Run `make` in the project root directory.
- This should take at least 5 hours, so you should probably let it run overnight. If you want to speed it up, and are not interested in making use of import statements in your code, you can significantly increase performance by modifying the `kpython` file and uncommenting line 8. That should decrease the time it takes to run to only about 5-10 minutes. However, then import statements will not have a correct semantics.
- To run programs, use the `kpython` shell script. It is designed to behave similarly to the
  python3.3 command line tool, although it does not currently suppport an interactive interpreter.

To check if kpython is behaving correctly:
```
$ make programs/testpass.out
Testing programs/testpass.py
programs/testpass.py passed
$
```

See [README.md](README.md) for a summary of the features supported by the `kpython`
tool.
