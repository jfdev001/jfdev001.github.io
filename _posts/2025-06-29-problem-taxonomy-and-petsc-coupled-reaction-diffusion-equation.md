---
title: 'Solver Problem Taxonomy with Application to PETSc Coupled Reaction-Diffusion Equation'
date: 2025-06-29
---

* A table to differentiate method types
* Note that linear problems can be easily formulated as nonlinear problems
    and subsequently solved via newton methods
* What about problems with mixed nonlinear and linear terms
* Example with Petsc coupled reaction diffusion equation and how some terms
might be treated explicitly and others implicitly while the solve itself
is still generally nonlinear due to the nonlinear terms enforcing this...

![](../../files/linear_nonlinear_time_solver_relationships.png)
