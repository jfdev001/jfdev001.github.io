---
title: 'Extra Mathematical Details: The Steady State Reaction-Diffusion Equations and their Solution in PETSc'
date: 2025-06-30
permalink: /posts/2025/06/petsc-nonlinear-reaction-diffusion-maths/
tags:
  - nonlinear
  - pdes
  - time independent
  - petsc
  - jacobian
  - gateaux derivative 
  - newton's method
---

In this article, some extra mathematical details related to the 
solution of the steady state reaction-diffusion equations using 
[PETSc](https://petsc.org/release/) are discussed. First, the simple nonlinear
governing equations of interest are shown. Then, Newton's method is presented
at the PDE level for generality rather than being presented at the algebraic
level. Subsequently, the spatial discretization via the finite difference method 
is shown for completeness. Finally, a commented PETSc implementation of the 
discretized reaction-diffusion equations is shown to concretely illustrate how 
the mathematical notation maps to code. 

# The Governing Equations

The general form of the one dimensional, time evolving heat equation 
can be modelled with diffusion (i.e., \\(\frac{\partial^2 u}{\partial x^2}\\) 
in 1D or \\(\nabla^2 u\\) in N-dimensions), reaction 
\\(R(u)\\), and source \\(f(\cdot)\\) processes for temperature (or substances 
more generally) with concentration \\(u(x, t)\\) and is given by

$$
\frac{\partial u}{\partial t} = \frac{\partial^2 u}{\partial x^2} + R(u) + f. \\ \tag{1}
$$

In this post, we focus on the time independent (aka steady state) form of 
equation (1)

$$
0 = \frac{\partial^2 u}{\partial x^2} + R(u) + f. \\ \tag{2}
$$

We define also \\(R(u) = -\rho \sqrt u\\) and \\(f(x) = 0\\) as well as the 
Dirichlet boundary conditions \\(u(0) = \alpha\\) and \\(u(1) = \beta\\) for our 
domain \\(\Omega \in [0, 1] \\).

Clearly, the
square root function in \\(R(u)\\) introduces a nonlinear term into
equation (2). Since identifying whether an equation has nonlinear terms naturally
determines whether we can use a linear or nonlinear solver, it is useful
to recall the definition of a [linear operator](https://mathworld.wolfram.com/LinearOperator.html)
\\(L\\) which is said to be linear if, for every pair of functions \\(f\\)
and \\(g\\) and a scalar \\(\theta\\)

$$
L(f + g) = L(f) + L(g),
$$

and

$$
L(\theta f) = \theta L(f).
$$

In this case, the square root term is obviously nonlinear.

# Newton's Method at the PDE Level

We present here Newton's method at the PDE level to make it as generally 
applicable as possible. Newton's method is often presented at the algebraic 
level since its presentation is paired with the discretization (e.g., via
finite difference methods, finite element methods, etc.) method of the PDEs. Since 
there are a large number of techniques to discretize PDEs, it is more general to 
formulate Newton's method in the context of the strong 
("original") form of the PDEs. You can then select and apply the appropriate 
steps for your desired discretization (e.g., for the finite element method,
this involves deriving a weak formulation and substituting the finite element
solution using specified basis functions) followed by an application of your
solver to the discretized PDEs.

Now, Newton's method is for solving general nonlinear equations of the form

$$
F(u) = 0. \\ \tag{3}
$$

Substituting equation (2) into equation (3) and then expanding terms

$$
F(u) = \frac{\partial^2 u}{\partial x^2} - \rho \sqrt u = 0, \\ \tag{4}
$$

we now have our governing equation in the desired general form. A cornerstone of
computational science is converting problems into forms that we know how
to solve effectively. We know and have numerous methods to solve linear 
systems of equations. Newton's method iteratively approximates solutions
to \\(u\\) in equation (4) by linearizing (i.e., converting a nonlinear problem
to a linear one) around an iterate, solving the new *linear* system for a 
step in the direction of the solution, and then adding that step to the
current iterate. That step in the direction of the solution is called a 
"Newton step" or perturbation. Mathematically, this solution process 
can be written as 

$$
\begin{aligned}
F(u^k + \delta u) &= F(u^k) + F'(u^k)(\delta u), && \text{(5.1)}\\
F'(u^k)(\delta u) &= -F(u^k), && \text{(5.2)} \\
u^{k+1} &= u^{k} + \delta u, && \text{(5.3)}
\end{aligned} 
$$ 

The "linearization" is equation (5.1): it is a truncated 
[Taylor series](https://en.wikipedia.org/wiki/Taylor_series) that is a linear
function of \\(\delta u\\) that approximates \\(F\\) near \\(u^k\\) at
iteration \\(k\\), therefore we have replaced our nonlinear function with a 
linear one. We seek the zero of this function, that is 
\\(F(u^k + \delta u) = 0\\) and rearrange to get equation (5.2). 
The term \\(F'(u)(\delta u)\\) may look a little suspicious, but
consider for a moment what \\(F\\) actually is. If \\(F\\) were a scalar
function, naturally \\(F'\\) is the ordinary derivative. Similarly, 
if \\(F\\) were a vector function, \\(F'\\) would be the Jacobian written
as \\(J_F(u^k)\\). However, \\(F\\) is neither a scalar nor a vector function,
but rather it is an operator: a map of one function space to another 
function space. Thus, we need 
the derivative of an operator. This is given by the 
[Gateaux derivative](https://en.wikipedia.org/wiki/Gateaux_derivative)

$$
dF(u; \delta u) = \lim_{\epsilon \rightarrow 0} \frac{F(u + \epsilon \delta u) - F(u)}{\epsilon} = \left . \frac{d}{d\epsilon} F(u + \epsilon \delta u) \right\vert_{\epsilon = 0}.
$$

It turns out that by definition, \\(F'\\) in 
\\(dF(u; \delta u) = F'(u)(\delta u)\\) is just the continuous linear operator
represented by the Jacobian matrix (see [Rall1971](https://www.sciencedirect.com/science/article/abs/pii/B9780125763509500059)].
Thus, to solve nonlinear PDE problems via Newton's method, we must do one of
the following:

**(a)** Provide the Jacobian explicitly after deriving and discretizing the 
Gateaux derivative.

**(b)** Allow a library (or write it yourself if you so desire) to compute the 
Jacobian by relying on automatic differentiation (e.g., 
[NonlinearSolver.jl: Solvers](https://docs.sciml.ai/NonlinearSolve/stable/native/solvers/#Nonlinear-Solvers))
and/or sparsity detection (e.g., 
[NonlinearSolve.jl: Declaring a Sparse Jacobian with Automatic Sparsity Detection](https://docs.sciml.ai/NonlinearSolve/stable/tutorials/large_systems/#Declaring-a-Sparse-Jacobian-with-Automatic-Sparsity-Detection)).

**(c)** Allow a library to symbolically compute the Jacobian (e.g.,
 [Mathematica: Unconstrained Optimization -- Methods for Solving Nonlinear Equations](https://reference.wolfram.com/language/tutorial/UnconstrainedOptimizationMethodsForSolvingNonlinearEquations.html),
 [FENICS: Solving the Nonlinear Variational Problem Directly](https://home.simula.no/~hpl/homepage/fenics-tutorial/release-1.0/webm/nonlinear.html#solving-the-nonlinear-variational-problem-directly), etc.).

It is worth noting that there are Jacobian-free methods (see 
[Knoll2004](https://www.sciencedirect.com/science/article/abs/pii/S0021999103004340)),
but these come with their own trade-offs. 

To be as explicit as possible, we now compute the Gateaux derivative of \\(F\\)

$$
\begin{aligned}
\left . \frac{d}{d\epsilon} F(u + \epsilon \delta u) \right\vert_{\epsilon = 0} &= \left . \frac{d}{d\epsilon}\left[ \frac{\partial^2}{\partial x^2}(u + \epsilon \delta u) - \rho \sqrt{(u + \epsilon \delta u)} \right] \right\vert_{\epsilon = 0} \\
&= \left . \frac{d}{d \epsilon}\left[\frac{\partial^2}{\partial x^2}u\right] + \frac{d}{d \epsilon}\left[\frac{\partial^2}{\partial x^2}\epsilon \delta u \right] - \frac{d}{d \epsilon} \left[ \rho \sqrt{(u + \epsilon \delta u)} \right] \right\vert_{\epsilon = 0} \\
&= \left . \frac{\partial^2}{\partial x^2} \delta u - \frac{d}{d \epsilon} \left[ \rho \sqrt{(u + \epsilon \delta u)} \right] \right\vert_{\epsilon = 0} \\
&= \left . \frac{\partial^2}{\partial x^2} \delta u - \frac{\rho}{2}(u + \epsilon \delta u)^{-\frac{1}{2}} \delta u \right\vert_{\epsilon = 0} \\
&= \frac{\partial^2}{\partial x^2} \delta u - \frac{\rho}{2 \sqrt u} \delta u,
\end{aligned} \\ \tag{6}
$$

and in the next section we perform the discretization to recover the Jacobian.

Once we have the Gateaux derivative, equation (5.3) is simply an update of the 
solution space in the direction "pointing" toward the zero of our nonlinear function. 

# Discretization by the Finite Difference Method

Since equation (6) defines a linear operator on \\(\delta u\\), we only 
care about discretizing the coefficients of \\(\delta u\\). That is, we 
want the discrete form of the continuous linear operator 

$$
F'(u) = \frac{\partial}{\partial x^2} - \frac{\rho}{2 \sqrt u},
$$ 

since \\(F'(u)\\) acts on \\(\delta u\\) as represented by 
\\(F'(u)(\delta u)\\) in equation (5.2). If we apply a centered finite 
difference scheme to discretize the second derivative operator acting on
\\(\delta u\\), we can consider the local stencil acting on points \\(i-1\\), 
\\(i\\), and \\(i+1\\) in the 1D mesh  as 

$$
\frac{\partial}{\partial x^2} \delta u \approx \frac{-1 \delta u_{i-1} + 2 \delta u_i - 1 \delta u_{i+1}}{h^2}.
$$

Moreover, \\(u\\) in \\(\frac{\rho}{2 \sqrt u}\\) corresponds to simply to 
\\(u_i^{k}\\). We now frame the action of the Jacobian on the perturbation \\(\delta u\\) in 
the context of Newton iteration. The Jacobian can therefore 
be written---emphasizing the coefficients of the Jacobian by wrapping
them in brackets---in the form

$$
\begin{aligned}
F'(u^k)(\delta u) &= J_F(u^k) \delta u \\
&= \left[ \frac{-1}{h^2} \right] \delta u_{i-1} + \left[ \frac{2}{h^2} \right] \delta u_i + \left[ \frac{-1}{h^2} \right] \delta u_{i+1} - \left[\frac{-\rho}{2 \sqrt{u^k_i}}\right]\delta u_i \\
&= \left[ \frac{-1}{h^2} \right] \delta u_{i-1} + \left[ \frac{2}{h^2} - \frac{\rho}{2 \sqrt{u^k_i}} \right] \delta u_i + \left[ \frac{-1}{h^2} \right] \delta u_{i+1}.
\end{aligned}
$$

With the components of the Jacobian explicitly specified, we can now propose
functions for implementing the solution of the reaction-diffusion equations
using PETSc. 

# Commented Implementation in PETSc

PETSc provides a suite of nonlinear solvers, preconditioners, data types
for linear algebra, automatic and highly scalable parallelism, and more 
while the user need only provide a comparatively simple---at least for the
problem we consider in this blog---set of functions that specify their 
particular problem. Per figure (1), the user needs only to implement 
`FormFunctionLocal`---which is simply \\(F(u)\\)---as well as 
`FormJacobianLocal`---which is simlpy \\(J_F(u^k)\\).

<figure>
    <img src="/images/petsc_user_code.png">
    <figcaption><font size="4">Figure (1): An overview of a full PETSc solution to 
    the reaction-diffusion equations. Critically, the user need only implement
    two functions. Taken from Bueller2021.</font></figcaption>
</figure>

{% highlight c linenos %}
int main() {
    return 0;
}
{% endhighlight %}


Here I present the relevant 

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
        * Above discussion found from [fenics question on maths for newtons method](https://fenicsproject.discourse.group/t/mathematically-correct-representation-of-newtons-method-in-weak-formulation/14439)
    * Some not so useful notes anymore 
        * For a description of some example function spaces, I use the notation [ch. 2.2. in He 2012](https://uu.diva-portal.org/smash/record.jsf?pid=diva2%3A544511&dswid=-3123)... need to write \\(R: H^1_E \rightarrow H^{-1}\\) but need to justify
    dual space corresponds to affine subspace \\(H^1_E = \phi + H^1_0\\) where \\(\phi \in H^1\\) (find also ref for this as this is just GPT output...)
        * [SO: all separable hilbert spaces are isomorphic to one another](https://math.stackexchange.com/questions/314113/dual-space-of-h1)
        * isomorphism implies that if \\(H^1 \rightarrow H^{-1}\\), then since 
            \\(H^1_E \subset H^1 \implies H^1_E \rightarrow H^{-1} \equiv H^1 \rightarrow H^{-1}\\)
    * [Gateaux derivative in context of FEM discussed by imperial college london](https://finite-element.github.io/8_nonlinear_problems.html)
    * [cls overflow: Newton iteration perturbations have to be in linear vector space...](https://scicomp.stackexchange.com/questions/45146/notation-for-defining-operators-for-residual-form-of-pde)

    * [definition: gateaux derivative](https://en.wikipedia.org/wiki/Gateaux_derivative)

* [implementation from book with your comments added](https://github.com/bueler/p4pdes/blob/master/c/ch4/reaction.c)

# References

[1] : Bueller2021

[2] : Logg2012

[3] : Heath2018

[4] : [Bangerth FEM Lectures: gateaux derivative and derivative for operators](https://www.youtube.com/watch?v=oVvIWMDctlE)

[5] : [Custom Newton Solver](https://jsdokken.com/dolfinx-tutorial/chapter4/newton-solver.html)


