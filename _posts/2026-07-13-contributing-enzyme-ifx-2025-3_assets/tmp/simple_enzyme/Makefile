###############################################################################
#
#  Generic single-file Fortran + Enzyme build pipeline
#
#  This replicates the lit test syntax
#  `RUN: %fc -flto -O1 -c %loadFortran %s -o /dev/stdout | %opt %loadEnzyme %enzyme -o %t.ll && %fc -flto -O1 %t.ll -o %t1 && %t1 | FileCheck %s`
#  but as a Makefile.
#
#  The compiler is selected with the COMPILER variable; the corresponding
#  per-compiler configuration file is then included automatically:
#
#      make COMPILER=ifx      # use Intel ifx   (loads ifx.mk)
#      make COMPILER=flang    # use LLVM Flang  (loads flang.mk)
#
#  In enzyme/test/Fortran/**/*.f90 you see lit syntax like
#  `%<SYMBOL>`. The generic definitions live in enzyme/test/lit.site.cfg.py.in
#  and the realized definitions in **/build/test/lit.site.cfg.py.
#
###############################################################################

###############################################################################
# Compiler selection
###############################################################################

COMPILER ?= ifx

ifeq ($(COMPILER),ifx)
  include ifx.mk
else ifeq ($(COMPILER),flang)
  include flang.mk
else
  $(error Unsupported COMPILER "$(COMPILER)". Supported values: ifx, flang)
endif

###############################################################################
# Source file
###############################################################################

SRC ?= test_enzyme.f90

BC   := $(basename $(SRC)).bc
ADBC := opt_$(basename $(SRC)).bc
ADLL := opt_$(basename $(SRC)).ll
EXE  := opt_$(basename $(SRC))
EXE_DIRECT := $(basename $(SRC))

###############################################################################
# Convenience targets
###############################################################################

.PHONY: lto nolto ll exec all clean

all: ll

# link-time optimization target to generate LLVM bitcode
lto: $(BC)

# no link-time optimization -> attempts per-file compilation, so it crashes
# on the unresolved Enzyme symbols (kept to document the failure)
nolto: $(EXE_DIRECT)

# produce human-readable optimized LLVM IR after the Enzyme passes
ll: $(ADLL)

# produce a working executable binary
exec: $(EXE)

clean:
	rm -f $(BC) $(ADBC) $(ADLL) $(EXE) *.mod

###############################################################################
# Targets
###############################################################################

# -flto defers global optimizations until the final link stage; this is
# needed because symbols can only be resolved after the loadEnzyme passes
# have run
$(BC): $(SRC)
	$(FC) $(FFLAGS) -c $(LOAD_FORTRAN) $< -o $@

# optimized LLVM bitcode with Enzyme loaded
$(ADBC): $(BC)
	$(OPT) $< $(LOAD_ENZYME) $(ENZYME) -o $@

# optimized human-readable code
$(ADLL): $(ADBC)
	$(DIS) $< -o $@

# get an executable from the optimized LLVM bitcode and do the final link
$(EXE): $(ADBC)
	$(FC) $(FFLAGS) $< -o $@

# direct compile without LTO: fails with undefined reference to
# `f__enzyme_autodiff_` because the Enzyme passes never run
$(EXE_DIRECT): $(SRC)
	$(FC) -O1 $(LOAD_FORTRAN) $< -o $@
