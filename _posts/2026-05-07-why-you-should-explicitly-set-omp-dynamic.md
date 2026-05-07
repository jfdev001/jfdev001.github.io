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
OpenMP implementation (`gcc/libgomp`) already defaults to `OMP_DYNAMIC=false`
(well, sort of... more on that later). However, relying on the default behavior
is not portable. Per [section 6.3:
OMP_DYNAMIC](https://www.openmp.org/spec-html/5.0/openmpse51.html) of the
OpenMP standard:

>  The behavior of the program is implementation defined if the value of OMP_DYNAMIC is neither true nor false. 

Moreover, per [section 2.5: Internal Control
Variables](https://www.openmp.org/spec-html/5.0/openmpse13.html#x48-660002.5)
and [section 2.5.2: Internal Control Variable
Initialization](https://www.openmp.org/spec-html/5.0/openmpsu31.html#x50-680002.5.2),
the variable `dyn_var` determines whether dynamic adjustment of the number of
threads is enabled, and its value is implementation defined. This means
compiler developers are free to choose the default behavior of their OpenMP
implementation. In principle, this means that a compiler implementer may choose
to enable dynamic adjustment of the number of threads by default.

Note that the internal control variable `dyn_var` simply reads from
`OMP_DYNAMIC` if its defined. However, explicitly disabling it ensures more
predictable and reproducible behavior across systems and compilers.

How do we know, though, that GCC defaults to `OMP_DYNAMIC=false`? Well, GCC
does not actually "set" `OMP_DYNAMIC`, so that's why I wrote "sort of" earlier.
Really, GCC defines `dyn_var` in a struct of configuration variables that can
be updated by environment variables. If the environment variable doesn't
exist, then the default value of the configuration variable is used. If
you want to verify GCC's behavior yourself, you can trace it directly through
the `gcc/libgomp` source code:

```shell
$ git clone --depth 1 https://github.com/gcc-mirror/gcc.git
$ cd gcc
$ cd libgomp 
$ rg dyn_var
parallel.c 
73: if (icv->dyn_var)

env.c
78: .dyn_var = false
```

From `ripgrep`, we can see where `dyn_var` gets used in
[parallel.c#L73](https://github.com/gcc-mirror/gcc/blob/bb0515578b0e087efda1c438a2ee14f9dbb6fa3b/libgomp/parallel.c#L73).
We can also see from
[env.c#L78](https://github.com/gcc-mirror/gcc/blob/bb0515578b0e087efda1c438a2ee14f9dbb6fa3b/libgomp/env.c#L78),
the default value of `dyn_var`, and thus know its value for certain without
having to guess or treat GCC as a black box.

```c
// @file env.c
const struct gomp_default_icv gomp_default_icv_values = {
  .nthreads_var = 1,
  .thread_limit_var = UINT_MAX,
  .run_sched_var = GFS_DYNAMIC,
  .run_sched_chunk_size = 1,
  .default_device_var = INT_MIN,
  .max_active_levels_var = 1,
  .bind_var = omp_proc_bind_false,
  .nteams_var = 0,
  .teams_thread_limit_var = 0,
  .dyn_var = false            // <----------------- DEFAULT VALUE!!!! 
};
```

Overall, `OMP_DYNAMIC` is a small but important example of a broader issue in
HPC: default behavior is not guaranteed to be portable, even when it is
consistent within a specific compiler like GCC. For reproducible performance
experiments, especially scaling studies, explicitly setting OpenMP
configuration variables removes ambiguity and ensures that results are
comparable across compilers, systems, and environments. As shown in GCC’s
libgomp implementation, even seemingly "fixed" defaults are ultimately
implementation details and relying on them implicitly can introduce hidden
variability into performance measurements. When in doubt: always set OpenMP
environment variables explicitly for reproducible performance work.
