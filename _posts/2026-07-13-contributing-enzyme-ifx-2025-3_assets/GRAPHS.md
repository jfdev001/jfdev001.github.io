# Graphs

Here I use text to describe information about llvm, ifx, and enzyme usage
visually.


flang

- analysis 
- lowering
- code generation linking


subset 
LLVM IR
MLIR 
FIR 


# References

* https://mcyoung.xyz/2023/08/01/llvm-ir/

* https://aosabook.org/en/v1/llvm.html

* https://github.com/llvm/llvm-project/blob/main/flang/docs/Overview.md

* Hsu2021: LLVM Techniques Tips and Best Practices... mentions pass manager

* https://lowlevelbits.org/how-to-learn-compilers-llvm-edition/

* https://medium.com/@princejain_77044/understanding-llvm-v-s-mlir-a-comprehensive-comparison-overview-9afc0214adc1

* https://news.ycombinator.com/item?id=35791960

* On generation of assembly code and assembly to linking: https://discourse.llvm.org/t/how-to-convert-llvm-ir-to-object-code/1739/2

* Optimization passes and pipeline for enzyme: https://docs.pasteurlabs.ai/projects/tesseract-core/latest/blog/2026-07-09-enzyme-lfortran-autodiff/

* [optimization passes in LLVM](https://llvm.org/docs/Passes.html)
