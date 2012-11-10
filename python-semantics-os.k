module PYTHON-SEMANTICS-OS

syntax OperatingSystem ::= "POSIX"

syntax String ::= pathSeparator(OperatingSystem)

rule pathSeparator(POSIX) => "/"

endmodule
