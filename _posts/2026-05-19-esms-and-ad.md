---
title: 'Autodiff: Why Earth System Modeling Still Depends on Compiler Infrastructure'
date: 2026-05-19
permalink: /posts/2026/05/esms-and-ad/
tags:
  - automatic differentiation
  - compilers
  - LLVM
  - Fortran
  - high performance computing
  - scientific computing
  - climate modeling
  - earth system modeling
---

Large scientific simulation codes written in Fortran underpin much of climate
science, weather prediction, and geophysical modeling. Increasingly, these
codes are not only used for forward simulation but also for inverse problems
where one wants to infer parameters, sensitivities, or initial conditions from
observations. Recent work in Earth system modeling has increasingly argued that
differentiable programming could enable more systematic calibration, data
assimilation, uncertainty quantification, and hybrid ML–physics workflows in
large scientific models. In this context, automatic differentiation (AD) has
become a key enabling technology. However, applying these ideas to large
Fortran codebases exposes a less visible dependency: the maturity of the
compiler infrastructure itself. This article discusses autodifferentiation in
the context of Fortran codebases as well as its relationship to compiler
infrastructure.

1. [Why Automatic Differentiation Matters](#why-automatic-differentiation-matters)
    1. [Parameter Estimation and Calibration](#parameter-estimation-and-calibration)
    2. [Data Assimilation](#data-assimilation)
    3. [Sensitivity Analysis and Uncertainty Quantification](#sensitivity-analysis-and-uncertainty-quantification)
    4. [Why Are These Applications Difficult in Legacy Fortran Codes](#why-are-these-applications-difficult-in-legacy-fortran-codes)
2. [Enzyme and the LLVM Dependency](#enzyme-and-the-llvm-dependency)
    1. [The Fortran to LLVM Ecosystem](#the-fortran-to-llvm-ecosystem)
        1. [DragonEgg (legacy)](#dragonegg-legacy)
        2. [Intel Fortran](#intel-fortran)
        3. [flang-classic](#flang-classic)
        4. [LLVM Flang (flang-new)](#llvm-flang-flang-new)
    2. [Why These Compilers Matter for Automatic Differentiation](#why-these-compilers-matter-for-automatic-differentiation)
    3. [Why Some HPC Codes Avoid LLVM-Based Toolchains](#why-some-hpc-codes-avoid-llvm-based-toolchains)
3. [Open Problems and Outlook](#open-problems-and-outlook)
4. [References](#references)


# Why Automatic Differentiation Matters

Scientific models are used to "predict the future", but they are also heavily
concerned with the following question:

> What parameter values or initial conditions best explain observed data?

Fundamentally, investigating parameters of models and initial conditions
can lead to optimized models and thus better predictions for critical domains
like severe weather events as well as improving our understanding of physical
phenomena.

This question shows up in several key workflows:

## Parameter Estimation and Calibration

Large models often include empirical parameters that must be tuned against
observational data. Gradient-based optimization methods are significantly more
efficient than derivative-free approaches, but they require accurate gradients
of model outputs with respect to inputs.

In Earth system modeling, this is especially relevant because models often
contain \\(O(10^2)\\) or more free parameters that are traditionally tuned manually.

## Data Assimilation

In numerical weather prediction and climate modeling, variational data
assimilation methods (e.g., 4D-Var) rely on gradients of a cost function with
respect to model states. These gradients are typically computed using adjoint
models, these are models that are explicitly created to avoid repeated
evaluations of the forward model (i.e., the numerical weather or climate model,
which is general a very expensive model).

## Sensitivity Analysis and Uncertainty Quantification

Understanding how perturbations in parameters propagate through nonlinear
systems is essential for assessing model robustness and uncertainty.
Second-order information (Hessians) can further improve uncertainty estimates
and optimization.

Across these applications, **derivatives** are a central computational object.

## Why Are These Applications Difficult in Legacy Fortran Codes

Historically, gradients in large Fortran codebases have been obtained through:

- manually written adjoint models  
- finite-difference approximations  
- limited symbolic or specialized differentiation tools  

Each approach has limitations:

- manual adjoints are difficult to maintain as models evolve (i.e., you now
need to carefully manage *two* codebases)
- finite differences are computationally expensive and numerically sensitive  
- symbolic methods struggle with large, imperative, real-world codebases  

As a result, many production scientific models either lack full differentiation
support or rely on specialized and fragile toolchains.

Automatic differentiation offers a more scalable and maintainable alternative
for many gradient-computation workflows by generating derivatives
systematically and with machine precision accuracy.


# Enzyme and the LLVM Dependency

Enzyme implements AD at the level of LLVM intermediate representation (IR).
This enables program-level differentiation while preserving compiler
optimizations, but introduces a strict requirement:

> The source program must be lowered into LLVM IR in a form that preserves its semantics.

For C and C++ code, this is generally straightforward due to the maturity of
compilers that can emit LLVM IR for those languages. For Fortran, the situation
is more complex due to the diversity and maturity of available LLVM-based
compiler frontends.

## The Fortran to LLVM Ecosystem

Several compiler paths exist for lowering Fortran into LLVM IR, each with
different levels of maturity:

### DragonEgg (legacy)

DragonEgg was a GCC plugin that enabled LLVM IR emission from gfortran. It is
effectively unmaintained and tied to outdated compiler versions, making it
impractical for modern use.

### flang-classic

flang-classic was an early LLVM Fortran frontend supporting a subset of Fortran
(primarily Fortran 2003/2008). While usable in controlled settings, it is no
longer the main development focus.

### Intel Fortran

As of 2021, Intel provides LLVM-based C/C++ compilers in their oneAPI
distribution. These compilers can emit LLVM bitcode, which is just the binary
serialization format of LLVM IR. It was not, however, until 2023 that Intel
released an LLVM-based Fortran compiler (ifx). Therefore, Enzyme *can* be used
on the LLVM IR outputs of Intel compilers, and this is reflected if one
inspects the CI/CD of Enzyme. 

```yaml
# @file .github/workflows/fortran.yml 
# @brief Verify that Intel is tested in Enzyme CI/CD
# @reference https://github.com/EnzymeAD/Enzyme/blob/ba0c1fa1e5829bb79f0f58896e8bd8053716daa9/.github/workflows/fortran.yml#L39-L51
.
.
.
jobs:
  build-and-test-fortran:
    name: Fortran ${{matrix.build}} ${{matrix.os}}
    runs-on: ${{matrix.os}}
    strategy:
      fail-fast: false
      matrix:
        build: ["Release", "Debug"]
        os: [ubuntu-22.04]
        llvm: [15]
        include:
          - llvm: 15             <---- Using LLVM v15
            ifx: 2023.0.0        <---- Proof that Intel compilers work with Enzyme!
            mpi: 2021.7.1
.
.
.
```

Similarly, one can get a hint about how to emit LLVM IR by looking at the 
comments with `! RUN` in the Fortran test cases in Enzyme:

```fortran
! @file enzyme/test/Fortran/ForwardMode/allocatableArraySimple.f90
! @brief Show comments that hint Intel --> LLVM IR
! @reference https://github.com/EnzymeAD/Enzyme/blob/ba0c1fa1e5829bb79f0f58896e8bd8053716daa9/enzyme/test/Fortran/ForwardMode/allocatableArraySimple.f90

! RUN: if [ %llvmver -ge 13 ]; then ifx -flto -O0 -c  %s -o /dev/stdout | %opt %loadEnzyme -enzyme -o %t && ifx -flto -O0 %t -o %t1 && %t1 | FileCheck %s; fi
! RUN: if [ %llvmver -ge 13 ]; then ifx -flto -O1 -c  %s -o /dev/stdout | %opt %loadEnzyme -enzyme -o %t && ifx -flto -O1 %t -o %t1 && %t1 | FileCheck %s; fi
! RUN: if [ %llvmver -ge 13 ]; then ifx -flto -O2 -c  %s -o /dev/stdout | %opt %loadEnzyme -enzyme -o %t && ifx -flto -O2 %t -o %t1 && %t1 | FileCheck %s; fi
! RUN: if [ %llvmver -ge 13 ]; then ifx -flto -O3 -c  %s -o /dev/stdout | %opt %loadEnzyme -enzyme -o %t && ifx -flto -O3 %t -o %t1 && %t1 | FileCheck %s; fi

module AD
    implicit none
    interface
        subroutine selectFirst__enzyme_fwddiff(fnc, x, dx, y, dy)
            ! ...
        end subroutine
    end interface
end module

program app
    ! calls to the autodiffed fortran code here...
end program 
```

The comments in the above file shows:

```fortran
! ifx -flto -O0 -c  %s -o /dev/stdout | %opt %loadEnzyme -enzyme -o %t ...
```

This line is repeated for different optimization levels (i.e., `-O<level>`).
More importantly, it shows that if we pass `-flto`, we emit LLVM bitcode
rather than emitting native machine code (i.e., code that has been lowered to
x86 instructions, ARM instructions, etc.). We can then disassemble this bitcode
to get human-readable (though already optimized) LLVM IR. Here is what the 
process of recovering human-readable LLVM IR would look like given a file
called `hello.f90` below:

```fortran
! @file  hello.f90
! @brief Example fortran file to be compiled to LLVM IR
PROGRAM main
    WRITE(*,*) "Hello world!"
END PROGRAM main
```

Then you can simply call,

```shell
ifx -flto -c hello.f90 -o /dev/stdout | llvm-dis-15 -o - > hello.ll
```

and `hello.ll` will contain LLVM IR like:

```llvm
; ModuleID = '<stdin>'
source_filename = "hello.f90"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@strlit = internal unnamed_addr constant [11 x i8] c"hello world", !llfort.type_idx !0
@anon.68ba48b9c6c80ce889c10c7426f57970.0 = internal unnamed_addr constant i32 65536
@anon.68ba48b9c6c80ce889c10c7426f57970.1 = internal unnamed_addr constant i32 2
; ...
```

It is in this way that LLVM IR is recovered from the Intel compiler and passed
to Enzyme so that autodifferentiation can be performed!

While modern Intel compilers (e.g., `ifx`) *can* emit LLVM IR, many HPC
codebases have not yet fully adopted the modern Intel compiler toolchain.
Rather, they still rely on the legacy toolchain (e.g., `ifort`) and therefore
cannot exploit the LLVM backend of modern Intel compilers yet.

For reference, this `hello.ll` file was generated on an x86 Ubuntu 24.04 LTS
machine using LLVM-v15 and `ifx` version 2023.0.0. In case you're interested
in replicating this process, you can get LLVM and Intel compilers as follows:

```shell
# install spack: https://spack-tutorial.readthedocs.io/en/latest/tutorial_basics.html
# necessary since i wanted to test with intel@2023.0.0 since Enzyme uses this
# and Intel does not provide older versions of Intel oneAPI for download through
# their website directly

# load spack
. /path/to/spack/share/spack/setup-env.sh

# install intel compilers
spack install --add intel-oneapi-compilers@2023.0.0

# load intel compilers
spack load intel-oneapi-compilers@2023.0.0

# verify compiler
ifx --version

# install llvm-15 
# reference: https://github.com/EnzymeAD/Enzyme/blob/ba0c1fa1e5829bb79f0f58896e8bd8053716daa9/.github/workflows/fortran.yml#L54-L60
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
sudo apt-add-repository "deb http://apt.llvm.org/`lsb_release -c | cut -f2`/ llvm-toolchain-`lsb_release -c | cut -f2`-15 main"
```

### LLVM Flang (flang-new)

LLVM Flang is the current LLVM-integrated Fortran frontend actively developed
within the LLVM project. It aims to become a full replacement for earlier Flang
implementations but is still evolving and does not yet fully support all
real-world Fortran codes.

## Why These Compilers Matter for Automatic Differentiation

The feasibility of AD in large Fortran applications depends less on the AD tool
itself and more on whether the compiler infrastructure can reliably lower the
entire codebase into a stable IR representation.

In practice, this introduces several constraints:

- incomplete frontend support limits which codes can be differentiated  
- missing language features restrict applicability to subsets of real applications  
- compiler instability complicates integration into production workflows  

Even if AD tools like Enzyme are technically capable, their usefulness is
bounded by frontend maturity.


## Why Some HPC Codes Avoid LLVM-Based Toolchains

Large operational models, such as climate and Earth system models, typically
prioritize:

- compiler stability and long-term reproducibility  
- performance consistency across architectures  
- minimal disruption to established build systems  

While LLVM-based Fortran toolchains are promising, they are still evolving and
may not yet match the robustness or optimization quality of mature compilers
such as gfortran or vendor toolchains.

As a result, LLVM-based AD workflows are often feasible only under constrained
conditions, such as:

- restricted subsets of Fortran  
- controlled build environments  
- partial refactoring of legacy code  
- hybrid compilation pipelines  

# Open Problems and Outlook

Despite significant progress in both LLVM Flang and AD frameworks such as
Enzyme, several challenges remain:

- **Frontend completeness:** Full compiler support for modern Fortran standards
is still in progress.  
- **Toolchain stability:** HPC environments require long-term reproducibility
and stable behavior.  
- **Performance parity:** LLVM-based Fortran compilers still vary in
optimization quality compared to mature alternatives like GNU and Intel compilers.  
- **Integration complexity:** End-to-end AD workflows remain difficult to
deploy in existing, legacy scientific software stacks.

At the same time, the direction of development is strongly supported by recent
literature in Earth system modeling, which highlights differentiable
programming as a key enabler for:

- systematic parameter calibration  
- gradient-based data assimilation  
- uncertainty quantification using Hessian information  
- integration of machine learning into process-based models  
- hybrid physics–ML modeling frameworks  

These developments suggest that AD is becoming a central component of
next-generation scientific modeling workflows.

For now applying automatic differentiation to large Fortran codebases remains
as much a compiler infrastructure problem as it is an algorithmic one.

While not covered in the present article, it is also worth noting that there is
growing traction in geophysical/atmospheric modeling using languages like Julia
for which the open-source community is already committed to differentiable
programming, see [Oceananigans.jl](https://github.com/CliMA/Oceananigans.jl),
[ClimaAtmos.jl](https://github.com/CliMA/ClimaAtmos.jl), and
[SpeedyWeather.jl](https://github.com/SpeedyWeather/SpeedyWeather.jl); however,
operational weather models like [ECMWF
IFS](https://github.com/ecmwf-ifs/openifs), [NOAA's Transition to
UFS](https://github.com/ufs-community/ufs-weather-model), and the [DWD's
ICON](https://gitlab.dkrz.de/icon/icon-model) are all written in Fortran. So
Fortran is not going anywhere anytime soon.

# References

[1] : LLVM Flang is not yet fully functioning: [LLVM
docs](https://flang.llvm.org/docs/) and [LLVM Flang GitHub
Project](https://github.com/orgs/llvm/projects/12)

[2] : [LLVM Blog: LLVM Flang and flang-classic
history](https://blog.llvm.org/posts/2025-03-11-flang-new/)

[3] : [Linaro Blog: LLVM Flang and flang-classic performance relative to
GFortran](https://www.linaro.org/blog/comparing-llvm-flang-with-other-fortran-compilers/)

[4] : [flang-compiler wiki: The state of
flang-classic](https://github.com/flang-compiler/flang/wiki)

[5]: [DragonEgg: GCC to LLVM IR](https://dragonegg.llvm.org/)

[6] : [Intel Forums: IFX doesn't emit LLVM (directly)
anymore](https://community.intel.com/t5/Intel-Fortran-Compiler/ifx-get-LLVM-IR-after-ifx-front-end/m-p/1548292)

[7] : [Fortran Lang Forums: Community Evaluation of State of LLVM
Flang](https://fortran-lang.discourse.group/t/state-of-llvm-flang-development/8174/8)

[8] : [Gelbrecht 2023: Differentiable Programming for Earth System
Modeling](https://gmd.copernicus.org/articles/16/3123/2023/)

[9] : [NASA ECCO: Adjoint Modeling](https://ecco-group.org/adjoint.htm)

[10] : [Cambridge ICCS Autodiff Blog
Post](https://iccs.cam.ac.uk/news/why-automatic-differentiation-important-climate-modelling)

[11] : [Intel Developer Content: Get to Know
LLVM](https://www.intel.com/content/www/us/en/developer/archive/case-study/getting-to-know-llvm-based-oneapi-compilers.html)

[12] : [NASA Advanced Supercomputing Division: Introduction to Intel's
LLVM-based
compilers](https://www.nas.nasa.gov/hecc/support/kb/introduction-to-intels-llvm-based-compilers_708.html)

[13] : [Intel Developer Content: C/C++ Compilers Complete Adoption of
LLVM](https://www.intel.com/content/www/us/en/developer/articles/technical/adoption-of-llvm-complete-icx.html)

[14] : [LLVM Docs: Link Time Optimization](https://llvm.org/docs/LinkTimeOptimization.html)

[15] : [Moses 2020: Instead of Rewriting Foreign Code for Machine Learning,
Automatically Synthesize Fast Gradients](https://arxiv.org/pdf/2010.01709)

[16] : [Ruhela 2024: Investigating the Performance of LLVM-Based Intel Fortran
Compiler (ifx)](https://link.springer.com/chapter/10.1007/978-3-031-73716-9_12)
