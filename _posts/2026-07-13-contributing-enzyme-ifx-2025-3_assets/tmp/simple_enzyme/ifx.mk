###############################################################################
#
#  Configuration for the Intel ifx compiler
#
#  Pipeline (matches enzyme/test/Fortran lit tests):
#
#      ifx -flto -O1 -c              -> test_enzyme.bc
#      opt  -load=LLVMEnzyme-X.so    -> opt_test_enzyme.bc
#      llvm-dis                      -> opt_test_enzyme.ll
#      ifx -flto -O1                 -> opt_test_enzyme (executable)
#
#  NOTE: ifx + LLVM <= 16 uses the OLD pass manager, hence
#  `--enable-new-pm=0` and `-load=` in the Enzyme invocation.
#
#  Everything is overridable on the command line, e.g.
#
#      make COMPILER=ifx ENZYME_PASS=/path/to/LLVMEnzyme-15.so
#
###############################################################################

# Compiler and LLVM utilities
FC        := ifx
OPT       ?= opt
DIS       ?= llvm-dis
LINK      ?= llvm-link

# Common compile flags for the LTO pipeline
FFLAGS    ?= -flto -O1

# Directory holding the Fortran Enzyme module files (enzyme.mod, ...)
ENZYME_MOD   ?= $(HOME)/dev/Enzyme/build/build-2023.0.0/modules

# Enzyme LLVM pass plugin
ENZYME_PASS  ?= $(HOME)/dev/Enzyme/build/build-2023.0.0/Enzyme/LLVMEnzyme-15.so

# Fortran include path for the Enzyme module
LOAD_FORTRAN = -I$(ENZYME_MOD)

# Flags that load the Enzyme pass plugin into opt
LOAD_ENZYME  = --enable-new-pm=0 -load=$(ENZYME_PASS) --enzyme-attributor=0

# Name of the Enzyme pass to run
ENZYME       = -enzyme
