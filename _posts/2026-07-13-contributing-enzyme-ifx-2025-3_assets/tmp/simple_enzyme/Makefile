# @brief Build a simple test file following the testing pipeline for IFX,
#        see enzyme/test/Fortran/**/*.f90
# 
# @description This test file basically replicates the lit test syntax
# `RUN: %fc -flto -O1 -c %loadFortran %s -o /dev/stdout | %opt %loadEnzyme %enzyme -o %t.ll && %fc -flto -O1 %t.ll -o %t1 && %t1 | FileCheck %s`
# but as a Makefile
#
# In enzyme/test/Fortran/**/*.f90, you see lit syntax like
# `%<SYMBOL>`. You can find the generic definitions in enzyme/test/lit.site.cfg.py.in
# and the realized definitions **/build/test/lit.site.cfg.py
#
# NOTE: I rely on spack to load llvm and intel compiler dependencies:
# spack load intel-oneapi-compilers@2023.0.0
# spack load llvm@15.0.7
#
# NOTE: You can replicate this on levante but spack load intel-oneapi-compilers@2023.0.0 will
# fail for some reason... so you need to manually source the intel environment files...
# spack location -i intel-oneapi-compilers@2023.0.0
# /sw/spack-levante/intel-oneapi-compilers-2023.0.0-65ewtu/setvars.sh
.PHONY: lto nolto ll all

fc = $(shell which ifx)

opt = $(shell which opt)

disassemble = $(shell which llvm-dis)

# TODO: this is a bit weird... because the config tests uses the build
# artifacts not the install artifacts... though it's unclear to me how to use
# the install artifacts...
# i wonder if there is an even an intention to use the install artifacts...
loadFortran = -I/home/jf01/dev/Enzyme/build/build-2023.0.0/modules

# uses old pass manager flags since LLVM <= 16 in this example... required
# inspecting lit cfg *.py file
loadEnzyme = --enable-new-pm=0 -load=/home/jf01/dev/Enzyme/build/build-2023.0.0/Enzyme/LLVMEnzyme-15.so --enzyme-attributor=0

# NOTE: pay attention to this, i am using llvm <= 16 so may be different for you
enzyme = -enzyme

# ---- TARGETS  ----
all:  # empty target 

# link-time optimization target to generate llvm bitcode
lto: test_enzyme.bc

# FAILS!! no link-time optimization, so attempts per file compilation, so crash
nolto: test_enzyme

# produce human readable optimized LLVM IR after enzyme passes 
ll: opt_test_enzyme.ll

# produce a working executable binary
exec: opt_test_enzyme

clean:
	rm *test_enzyme *.bc *.ll

# ---- END TARGETS  ----

# flto means defers global optimizations until final link stage... this is
# because there are symbols that cannot be resolved here which can be 
# only resolved if loadEnzyme passes occur
test_enzyme.bc: test_enzyme.f90
	$(fc) -flto -O1 -c $(loadFortran) $< -o $@

# optimized LLVM bitcode with Enzyme loaded
opt_test_enzyme.bc: test_enzyme.bc 
	$(opt) $< $(loadEnzyme) $(enzyme) -o $@

# optimized human readable code 
opt_test_enzyme.ll: opt_test_enzyme.bc
	$(disassemble) $< -o $@

# Get executable from this optimized LLVM IR and perform final linking 
opt_test_enzyme: opt_test_enzyme.ll
	$(fc) -flto -O1 $< -o $@

# includes final link stage and will crash due to undefined symbols!!
#
# [jf01@lapfrazier] simple_enzyme$ make nolto 
# ifx -O1 -I/home/jf01/dev/Enzyme/build/build-2023.0.0/modules test_enzyme.f90 -o test_enzy
# ld: /tmp/ifx0052089676NTAddZ/ifx39HOZO.o: in function `MAIN__':
# test_enzyme.f90:(.text+0x3f): undefined reference to `f__enzyme_autodiff_'
test_enzyme: test_enzyme.f90
	$(FC) -O1 $(loadFortran) $< -o $@
