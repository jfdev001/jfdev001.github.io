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

### Intel Fortran

Some earlier Intel compiler versions supported LLVM IR output, but this
capability is not consistently available in modern production toolchains.

### flang-classic

flang-classic was an early LLVM Fortran frontend supporting a subset of Fortran
(primarily Fortran 2003/2008). While usable in controlled settings, it is no
longer the main development focus.

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

[1] : LLVM Flang is not yet fully functioning: [LLVM docs](https://flang.llvm.org/docs/) and [LLVM Flang GitHub Project](https://github.com/orgs/llvm/projects/12)

[2] : [LLVM Blog: LLVM Flang and flang-classic history](https://blog.llvm.org/posts/2025-03-11-flang-new/)

[3] : [Linaro Blog: LLVM Flang and flang-classic performance relative to GFortran](https://www.linaro.org/blog/comparing-llvm-flang-with-other-fortran-compilers/)

[4] : [flang-compiler wiki: The state of flang-classic](https://github.com/flang-compiler/flang/wiki)

[5]: [DragonEgg: GCC to LLVM IR](https://dragonegg.llvm.org/)

[6] : [Intel Forums: IFX doesn't emit LLVM anymore](https://community.intel.com/t5/Intel-Fortran-Compiler/ifx-get-LLVM-IR-after-ifx-front-end/m-p/1548292)

[7] : [Fortran Lang Forums: Community Evaluation of State of LLVM Flang](https://fortran-lang.discourse.group/t/state-of-llvm-flang-development/8174/8)

[8] : [Gelbrecht 2023: Differentiable Programming for Earth System Modeling](https://gmd.copernicus.org/articles/16/3123/2023/)

[9] : [NASA ECCO: Adjoint Modeling](https://ecco-group.org/adjoint.htm)

[10] : [Cambridge ICCS Blog Post](https://iccs.cam.ac.uk/news/why-automatic-differentiation-important-climate-modelling)
