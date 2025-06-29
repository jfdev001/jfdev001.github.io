---
title: 'Mapping a PETSc Implementation of Steady-State Reaction Diffusion Equations to Mathematics'
date: 2025-06-29
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
    * Formulate newton method at the PDE level (independent of discretization
        which is relevant for using FDM vs FVM vs FEM etc.)
        * See FENICS Book pg 39-48, particularly 1.2.3
        * See [Fenics custom newton solvers](https://jsdokken.com/dolfinx-tutorial/chapter4/newton-solver.html)
    * Some not so useful notes anymore 
        * For a description of some example function spaces, I use the notation [ch. 2.2. in He 2012](https://uu.diva-portal.org/smash/record.jsf?pid=diva2%3A544511&dswid=-3123)... need to write \\(R: H^1_E \rightarrow H^{-1}\\) but need to justify
    dual space corresponds to affine subspace \\(H^1_E = \phi + H^1_0\\) where \\(\phi \in H^1\\) (find also ref for this as this is just GPT output...)
        * [SO: all separable hilbert spaces are isomorphic to one another](https://math.stackexchange.com/questions/314113/dual-space-of-h1)
        * isomorphism implies that if \\(H^1 \rightarrow H^{-1}\\), then since 
            \\(H^1_E \subset H^1 \implies H^1_E \rightarrow H^{-1} \equiv H^1 \rightarrow H^{-1}\\)
    * [Gateaux derivative in context of FEM discussed by imperial college london](https://finite-element.github.io/8_nonlinear_problems.html)
    * [cls overflow: Newton iteration perturbations have to be in linear vector space...](https://scicomp.stackexchange.com/questions/45146/notation-for-defining-operators-for-residual-form-of-pde)
    * [bangerth fem: gateaux derivative and derivative for operators](https://www.youtube.com/watch?v=oVvIWMDctlE)

    * [definition: gateaux derivative](https://en.wikipedia.org/wiki/Gateaux_derivative)

* [implementation from book with your comments added](https://github.com/bueler/p4pdes/blob/master/c/ch4/reaction.c)


