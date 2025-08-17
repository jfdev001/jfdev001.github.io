---
title: "N-Body Simulation in C with MPI and OpenMP"
excerpt: "Code at [github.com/jfdev001/parallel-nbody](https://github.com/jfdev001/parallel-nbody).<br/><img src='/images/simulation_world.png'>"
collection: portfolio
---

The \\(N\\)-body problem is a classic problem in which \\(N\\) discrete bodies 
mutually interact in a dynamical system consisting of positions, forces, and 
velocities. A parallel algorithm for simulating the evolution of this dynamical system was implemented using C and MPI. Simulations were conducted for 100 timesteps, the 
number of discrete bodies was \\(N \in \{512,1024,4096,10000\}\\), and the number 
of MPI processes was between 2 and 128. All experiments were conducted using the 
Vrije Universiteit's DAS-5 cluster's ASUS nodes with Intel E5\nobreakdash-2630v3 
CPUs. As a bonus optimization, OpenMP was added to the MPI implementation. For 
4 processes with \\(N=10000\\), the speedup and efficiency for the pure MPI 
program were \\(2.31\\) and \\(57.64\%\\), respectively. For MPI+OpenMP 
(aka Hybrid MPI) on the same problem the speedup and efficiency were \\(7.80\\) 
and \\(194.95\%\\), respectively.


See [jfdev001/parallel-nbody](https://github.com/jfdev001/parallel-nbody).
