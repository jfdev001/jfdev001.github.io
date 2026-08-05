###############################################################################
#
#  Configuration for the LLVM Flang compiler
#
#  Pipeline (mirrors enzyme_heat2d/Makefile):
#
#      flang -emit-llvm -flto -O1 -c -> test_enzyme.bc
#      opt  -load-pass-plugin=...    -> opt_test_enzyme.bc
#      llvm-dis                      -> opt_test_enzyme.ll
#      flang -flto -O1               -> opt_test_enzyme (executable)
#
#  NOTE: flang + LLVM >= 17 uses the NEW pass manager, hence
#  `-load-pass-plugin=` and `-passes=` in the Enzyme invocation.
#
#  Everything is overridable on the command line, e.g.
#
#      make COMPILER=flang ENZYME_PASS=/path/to/LLVMEnzyme-21.so
#
###############################################################################

# Compiler and LLVM utilities
FC        := flang-21
OPT       ?= opt
DIS       ?= llvm-dis
LINK      ?= llvm-link

# Common compile flags for the LTO pipeline
FFLAGS    ?= -emit-llvm -flto -O1

# Directory holding the Fortran Enzyme module files (enzyme.mod, ...)
ENZYME_MOD   ?= $(HOME)/work/Enzyme/build-flang/modules

# Enzyme LLVM pass plugin
ENZYME_PASS  ?= $(HOME)/work/Enzyme/build-fortran/Enzyme/LLVMEnzyme-21.so

# Fortran include path for the Enzyme module
LOAD_FORTRAN = -I$(ENZYME_MOD)

# Flags that load the Enzyme pass plugin into opt
LOAD_ENZYME  = -load-pass-plugin=$(ENZYME_PASS)

# Name of the Enzyme pass to run
ENZYME       = -passes=enzyme
