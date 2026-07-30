# Could base %<SYMBOL> on enzyme/test/lit.site.cfg.py.in
.PHONY: lto nolto ll all

# NOTE: you should still spack load the desired dependencies since that will
# update critical env vars?
fc = /home/jf01/dev/spack/opt/spack/linux-skylake/intel-oneapi-compilers-2023.0.0-h5rub7u7jue4s4ihgqbtjj6m3yr2o2lk/compiler/2023.0.0/linux/bin/ifx

opt = /home/jf01/dev/spack/opt/spack/linux-skylake/llvm-15.0.7-yhxdeabnmvf3p5hdgfurt2e5ubsqrb6j/bin/opt

dissassemble = /home/jf01/dev/spack/opt/spack/linux-skylake/llvm-15.0.7-yhxdeabnmvf3p5hdgfurt2e5ubsqrb6j/bin/llvm-dis

# TODO: this is a bit weird... because the config tests uses the build
# artifacts not the install artifacts... though it's unclear to me how to use
# the install artifacts...
# i wonder if there is an even an intention to use the install artifacts...
loadFortran = -I/home/jf01/dev/Enzyme/build/build-2023.0.0/modules


# # TODO: is hte %opt necessary before this stage?? probably...
# use oldPM from build version
loadEnzyme = --enable-new-pm=0 -load=/home/jf01/dev/Enzyme/build/build-2023.0.0/Enzyme/LLVMEnzyme-15.so --enzyme-attributor=0

enzyme = -enzyme

# targets
all: 
lto: test_enzyme.o
ll: opt_test_enzyme.ll
nolto: test_enzyme
exec: opt_test_enzyme

# flto means delay the link stage... this is because there are symbols
# that cannot be resolved here.... hence the loadEnzyme 
# NOTE: this is LLVM bitcode and is not human readable
test_enzyme.o: test_enzyme.f90
	$(fc) -flto -O1 -c $(loadFortran) $< -o $@

# optimized LLVM bitcode with Enzyme loaded
opt_test_enzyme.o: test_enzyme.o
	$(opt) $< $(loadEnzyme) $(enzyme) -o $@

opt_test_enzyme.ll: opt_test_enzyme.o
	$(dissassemble) $< -o $@

# Get executable from this optimized LLVM IR 
opt_test_enzyme: opt_test_enzyme.ll
	$(fc) -flto -O1 $< -o $@

# includes link phase and will crash due to undefined symbol!!
#
# [jf01@lapfrazier] simple_enzyme$ make nolto 
# ifx -O1 -I/home/jf01/dev/Enzyme/build/build-2023.0.0/modules test_enzyme.f90 -o test_enzy
# ld: /tmp/ifx0052089676NTAddZ/ifx39HOZO.o: in function `MAIN__':
# test_enzyme.f90:(.text+0x3f): undefined reference to `f__enzyme_autodiff_'
test_enzyme: test_enzyme.f90
	$(FC) -O1 $(loadFortran) $< -o $@

clean:
	rm test_enzyme *.o *.ll
