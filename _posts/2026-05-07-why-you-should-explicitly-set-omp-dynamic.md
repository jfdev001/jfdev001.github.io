---
title: 'OpenMP Defaults Are Not Portable: A Note on OMP_DYNAMIC'
date: 2026-05-07
permalink: /posts/2026/05/omp-dynamic/
tags:
    - OpenMP
    - HPC
    - Performance Portability
    - Reproducibility 
---

For reproducible scaling experiments, it is good practice to explicitly set
`OMP_DYNAMIC=false`, especially when you want to guarantee the number of
threads spawned for each parallel region. In this short article, I explain why
this is important and how one can sift through the GCC codebase (140k+ files
and more than 5 million LOC) plus the OpenMP standard to find this information.

Controlling the exact thread count is important for reproducibility. If the
runtime is allowed to dynamically adjust the number of threads, the same
program may exhibit different performance characteristics across compilers,
systems, or execution environments. Explicitly disabling dynamic thread
adjustment helps ensure that scaling measurements and performance comparisons
are consistent and interpretable.

Interestingly, this is not strictly necessary when using GCC, because GCC’s
OpenMP runtime (`libgomp`) already defaults to `OMP_DYNAMIC=false`.

However, relying on the default behavior is not portable. The OpenMP standard
does not mandate a default value for `OMP_DYNAMIC`:

>  TODO: quote here 

This means compiler implementers are free to choose the default behavior of
their OpenMP implementation.

`OMP_DYNAMIC` controls whether the OpenMP runtime may dynamically adjust the
number of threads used in parallel regions. Explicitly disabling it ensures
more predictable and reproducible behavior across systems and compilers.

If you want to verify GCC's behavior yourself, you can trace it directly
through the `libgomp` source code:

TODO: copy paste code snippets here

* The function implementing the dynamic-thread behavior:
  [proc.c#L180](https://github.com/gcc-mirror/gcc/blob/bb0515578b0e087efda1c438a2ee14f9dbb6fa3b/libgomp/config/linux/proc.c#L180)

* Where that function is called:
  [parallel.c#L73](https://github.com/gcc-mirror/gcc/blob/bb0515578b0e087efda1c438a2ee14f9dbb6fa3b/libgomp/parallel.c#L73)

* And finally, where the default value is initialized (`dyn_var = false`):
  [env.c#L78](https://github.com/gcc-mirror/gcc/blob/bb0515578b0e087efda1c438a2ee14f9dbb6fa3b/libgomp/env.c#L78)
