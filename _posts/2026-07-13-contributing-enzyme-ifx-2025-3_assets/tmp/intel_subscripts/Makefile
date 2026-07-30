.PHONY: all clean

all: ix.ll ix_p1.ll

OPT_ARGS = -O0

ix.ll: ix.o
	llvm-dis $< -o  $@

ix.o: ix.f90
	ifx -flto $(OPT_ARGS) -c $< -o $@

ix_p1.ll: ix_p1.o
	llvm-dis $< -o  $@

ix_p1.o: ix_p1.f90
	ifx -flto $(OPT_ARGS) -c $< -o $@

clean:
	rm *.o *.ll
