---
title: 'Mapping a PETSc Implementation of Steady-State Reaction Diffusion Equations to Mathematics'
date: 2025-06-28
permalink: /posts/2025/06/petsc-nonlinear-reaction-diffusion-maths/
tags:
  - nonlinear
  - pdes
  - petsc
  - jacobian
  - gateaux derivative 
---

In this article, I explain how PETSc impelmentation maps to mathematics.


# Outline 

* Context of equation

$$
F(u) = \frac{d^2}{dx^2} u - \rho \sqrt u + f = 0
$$

* you need to use newton iteration because nonlinear

* formulation of jacobian requires gateaux derivative
    * For a description of some example function spaces, I use the notation [ch. 2.2. in He 2012](https://uu.diva-portal.org/smash/record.jsf?pid=diva2%3A544511&dswid=-3123)... need to write \\(R: H^1_E \rightarrow H^{-1}\\) but need to justify
dual space corresponds to affine subspace \\(H^1_E = \phi + H^1_0\\) where \\(\phi \in H^1\\) (find also ref for this as this is just GPT output...)


* [implementation from book with your comments added](https://github.com/bueler/p4pdes/blob/master/c/ch4/reaction.c)

* [fem: gateaux derivative and derivative for operators](https://www.youtube.com/watch?v=oVvIWMDctlE)

* [definition: gateaux derivative](https://en.wikipedia.org/wiki/Gateaux_derivative)

