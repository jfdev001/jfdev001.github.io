Title: Enabling Automatic Differentiation for the ICON Weather and Climate
Model Using Enzyme and the Intel Fortran Compiler

Differentiable programming is attracting increasing interest in weather and
climate modelling, enabling gradient-based methods for applications such as
model calibration, optimization, and sensitivity analysis. However, applying
automatic differentiation (AD) to large Fortran code bases remains challenging.
Traditional AD tools typically rely on source-to-source transformation and the
generation of derivative code, requiring additional tooling and integration
into existing build systems. In contrast, Enzyme performs AD at the LLVM
intermediate representation (IR) level, allowing differentiation to be
integrated directly into the compiler workflow while reducing the need for
source-level modifications. We present ongoing work to apply Enzyme to the ICON
weather and climate model using the LLVM-based Intel Fortran compiler (ifx). We
describe the integration workflow, discuss current challenges, and outline the
path toward enabling differentiable programming within ICON.
