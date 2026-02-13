---
title: 'Lightweight CI/CD on a Raspberry Pi 3B+: Deploying a Robust
Self-Managed GitLab Runner'
date: 2026-02-12
permalink: /posts/2026/02/gitlab-runner-on-raspberry-pi/
tags:
    - Linux
    - Raspberry Pi
    - CI/CD
    - GitLab
    - Static Code Analysis
---

If you choose to host a self-managed (i.e. private) GitLab instance on
on-premises infrastructure, you do not get access to GitLab’s shared (public)
runners for CI/CD. Unlike GitLab.com or GitLab Dedicated, a private GitLab
instance puts you fully in control, but that control comes with
responsibility: you have to bring your own runners. In this article, I document
my experience setting up a GitLab runner on a Raspberry Pi 3B+, why I chose
this route, and how I did it. Spoiler: while the setup itself is fairly
straightforward, there are some Raspberry Pi–specific hardware quirks that are
worth handling correctly if you care about long-term stability and
recoverability.

1. [CI/CD and GitLab](#cicd-and-gitlab)
    1. [What is CI/CD](#what-is-cicd)
    2. [The Importance of Static Code Analysis](#the-importance-of-static-code-analysis)
    3. [What is GitLab](#what-is-gitlab)
2. [The Raspberry Pi 3B+](#the-raspberry-pi-3b)
    1. [Why a Raspberry Pi](#why-a-raspberry-pi)
    2. [Setting up the Pi](#setting-up-the-pi)
    3. [Enabling USB Boot](#enabling-usb-boot)
    4. [Moving the Root Filesystem to an SSD](#moving-the-root-filesystem-to-an-ssd)
3. [Static Analysis of a Representative Codebase](#static-analysis-of-a-representative-codebase)
    1. [ARM-native Docker image](#arm-native-docker-image)
    2. [Simple Performance Results](#simple-performance-results)
4. [Conclusion](#conclusion)
5. [Appendix](#appendix)
    1. [Verifying Compiler Optimizations in Assembly](#verifying-compiler-optimizations-in-assembly)
    2. [Static Code Analysis Dockerfile](#static-code-analysis-dockerfile)

# CI/CD and GitLab

Before diving into hardware, it’s worth briefly setting the stage.

## What is CI/CD

Continuous Integration (CI) and Continuous Deployment/Delivery (CD) are
practices that automate the process of:

* building code,
* running tests,
* performing static code analysis,
* and deploying artifacts whenever changes are pushed to a repository.

The goal is to catch issues early, reduce manual steps, and make software
delivery repeatable and reliable.

## The Importance of Static Code Analysis 

Static analysis is of particular interest since it is essentially the automated
scanning of code in order to find and report vulnerabilities and errors. For
example, consider the following C code snippet:

```c
// @file main.c
// @brief Illustrates usefulness of static code analysis.
#include <stdlib.h>
void foo(int x) {
  int buf[10];
  buf[x] = 0;
}

int main() {
  int *p;
  free(p);
  foo(10);
  return 0;
}
```

Take a moment to scan the above program and see what might be problematic about
it. Once you're ready, you could go ahead and compile it with your favorite
compiler and have the compiler emit warnings. For example, we can use `gcc`
with strict warnings set (see `man gcc`):

```
$ gcc -Wpedantic -Wextra -Wall main.c 
main.c: In function ‘foo’:
main.c:3:7: warning: variable ‘buf’ set but not used [-Wunused-but-set-variable]
    3 |   int buf[10];
      |       ^~~
main.c: In function ‘main’:
main.c:9:3: warning: ‘p’ is used uninitialized [-Wuninitialized]
    9 |   free(p);
      |   ^~~~~~~
```

Great! With just a few flags (note, only the `-Wall` flag is actually relevant
here, but to be very strict I included the `-Wpedantic` and `-Wextra`), we have
got some quite clear and very useful warnings! Line 3 tells us we have an
unused variable named `buf` while line 7 tells us we have an uninitialized
variable `p` that we are calling `free` on. Calling `free` on an uninitialized
pointer is undefined behavior (see `man 3 free`), so we can already infer that
this very simple program will crash. Note that the unused variable is not a
particularly harmful aspect of the program since it will get optimized out by
the compiler anyways. See section [Verifying Compiler Optimizations in
Assembly](#verifying-compiler-optimizations-in-assembly) of this article for
details. However, as a good practice you should not declare variables you
don't use, and `gcc` warnings can alert you to such artifacts in your code.

While we can easily use `gcc` to emit warnings, this requires that we compile
our program. We *can* halt `gcc` after the compilation proper stage so that the
assembler doesn't convert the assembly to object code; however, as you scale
the number of files up, you end up wasting computational resources to emit
assembly code when that is not actually a necessary stage to detect many
potential errors in the code. 

Instead, we can use a tool like `cppcheck` that, per its [design
docs](https://master.dl.sourceforge.net/project/cppcheck/Articles/cppcheck-design.pdf?viasf=1),
performs only a *modified subset* of the phases that a compiler would normally
perform such as the preprocessing, tokenizing, and abstract syntax tree
construction. A major difference is `cppcheck` will not assemble nor link code.
Moreover, `cppcheck` can catch things that a compiler would not. In general,
this is the approach of static code analysis: don't compile or run your code,
but use parsing techniques to catch errors or produce warnings instead. For
example, if we call `cppcheck` on the same program,

```
$ cppcheck main.c 
Checking main.c ...
main.c:6:6: error: Array 'buf[10]' accessed at index 10, which is out of bounds. [arrayIndexOutOfBounds]
  buf[x] = 0;
     ^
main.c:12:7: note: Calling function 'foo', 1st argument '10' value is 10
  foo(10);
      ^
main.c:6:6: note: Array index out of bounds
  buf[x] = 0;
     ^
main.c:11:8: error: Uninitialized variable: p [uninitvar]
  free(p);
       ^
```

we get the crucial error that our array access is out of bounds! We did not see
this error when using `gcc`. You can also see that the uninitialized variable
is caught as well, so in fact there is overlap in what a compiler can catch and
what a static code analyzer can catch. 

You can hopefully understand now why static code analysis in particular is so
valuable and why you would want to include it in a CI/CD pipeline.

## What is GitLab

GitLab is a web-based DevOps platform that combines (non-exhaustively):

* Git repository hosting,
* issue tracking,
* CI/CD pipelines,
* container registries,

into a single application. One of GitLab’s strengths is how tightly integrated
CI/CD is with the project (aka repository) itself. That is, pipelines are
defined declaratively via a `.gitlab-ci.yml` file in a a project's root
directory. The feature of GitLab that executes CI/CD pipelines is known as
GitLab runners (analogous to GitHub actions). 

GitLab runners are daemons (i.e., background processes, see `man daemon`) that
run on either public (aka shared) servers or are configured to run on on-prem
infrastructure. The [runner execution
flow](https://docs.gitlab.com/runner/#runner-execution-flow) is highly
intuitive, and involves essentially two steps: 

1. Initial registration of the runner with the GitLab instance.
2. Continuous polling of the GitLab instance by the runner for CI/CD jobs.

Only step (1) requires active administration since step (2) is handled by the
runner itself.

Per the GitLab runner [documentation](see
[here](https://docs.gitlab.com/ci/runners/)), shared runners are not available
to self-managed instances. The following table summarizes the different GitLab
tiers:

Tier             | Shared Runner Available| On-prem | Cloud| 
---------------- | -----------------------| --------| -----|
GitLab.com       | yes                    | no      | yes  | 
Self-managed     | no                     | yes     | no   | 
GitLab Dedicated | yes                    | no      | yes  | 

What does this mean? It means that for a self-managed GitLab instance, the 
administrators maintain full control of their data and infrastructure. So,
if you want to use CI/CD, you need to setup any GitLab runners yourself.

# The Raspberry Pi 3B+

GitLab runners can be setup on virtually any hardware with networking
capabilities; however, since I was primarily interested in a lightweight
runner, I chose to deploy a Raspberry Pi 3B+.

## Why a Raspberry Pi

The Raspberry Pi 3B+ checked several boxes for me:

* A spare Pi was given to me by another department at work.
* It’s cheap.
* Low power consumption.
* Full control over OS, storage, and networking.

The last point, that is full control, is particularly important because I am
not an administrator of any of the servers we have at work. By getting my own
hardware, I can experiment with the GitLab runner setup without bothering IT.

For CI workloads like static analysis, linting, and lightweight builds, the Pi
is perfectly sufficient. Where it could struggle is with multiple developers
submitting CI jobs since I have disabled concurrent jobs by default. However,
it can certainly tolerate use by less than five developers, which is the
current state of the users of the self-managed GitLab instance. More than this
would require a runner on more powerful hardware, but that is a next step in
the following circumstances:

1. I find that the developers at work are using GitLab CI/CD enough.
2. IT is willing to give us such access to the local compute clusters.

## Setting up the Pi

I knew that I would be heavily resource constrained, so I opted for a Linux
operating system tailored for minimal resource consumption on Raspberry Pis.
[DietPi](https://dietpi.com/) fits exactly this requirement and was a breeze to
install. Since DietPi is Debian-based, it was also extremely comfortable to
administer. But most importantly, DietPi consumed about half of the RAM that the
headless Raspberry Pi OS does. Obviously, I want to dedicate as much RAM as
possible to the GitLab runner and its operations, so minimizing extraneous RAM
utilization was a high priority.

To initially setup the Pi, I flashed DietPi OS onto a microSD, plugged that
into the Pi, connected an HDMI cable to a monitor, connected a keyboard,
and plugged in power supply. I then went through the setup stage to get
language settings and networking working. Straightforward. Boom, done.

However, as an aside, I will voluntarily and shamefully admit that while
selecting my regulatory domain for WiFi (see [Wiki: WLAN
Channels](https://en.wikipedia.org/wiki/List_of_WLAN_channels#Interference_concerns)
and [Linux wireless regulatory
domains](https://www.marcusfolkesson.se/blog/linux-wireless-regulatory/)), I
accidentally selected GE. I live in Germany. This was a silly oversight since
GE corresponds to Georgia, and when I was scanning for WiFi connections on my
local network nothing was coming up. After switching to DE, of course my
problem was solved. In short: know basic geography and nomenclature and avoid
spending half an hour troubleshooting network connectivity issues.

## Enabling USB Boot

We've got the Pi initially setup, so I now can focus on bolstering
recoverability. SD cards fail. Filesystems get corrupted. Eventually, you will
brick something, so might as well put measures in place to facilitate easy
recovery.

The Raspberry Pi supports USB boot via a one-time programmable (OTP) bit that
enables booting from USB mass storage devices. According to recent
[documentation](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-3b-zero-2-w),
this should already be enabled on newer Pi models.

However, when I checked:

```
$ vcgencmd get_config program_usb_boot_mode
```

on the Pi, I got

```
program_usb_boot_mode=0
```

This means USB boot was, in fact, not enabled.

To fix this, I had to explicitly update `/boot/firmware/config.txt` to enable USB
boot, then reboot once to permanently set the OTP bit. This update is very
simple: just append the following to the end of `/boot/firmware/config.txt`
file:

```
program_usb_boot_mode=1
```

This is a one-way operation, but one that significantly improves recovery
options if the system becomes unbootable. Why? Because now I can drop any Linux
distribution on a USB stick, then plug it into the Pi to triage any issues
without having to pull out the Pi microSD to make changes to it with another
computer.

## Moving the Root Filesystem to an SSD

MicroSD cards have limited write endurance (see
[here](https://news.ycombinator.com/item?id=44156142)). While it is perhaps a
bit overengineering, I wanted to move the root filesystem, where lots of write
operations would occur, to a more durable SSD and leave the largely read-only
bootloader on the microSD.

Moving the root filesystem was a multistep process. Ultimately, the goal was 
two-fold:

1. Update kernel parameters in `/boot/firmware/cmdline.txt` to point the root
   file system to the SSD.
2. Update `/etc/fstab` on the SSD to reflect the new filesystem information.

First, I plugged the microSD and SSD into a Linux machine. I then needed to
create mount points for the filesystems on those storage devices. By listing
block devices,

```
$ lsblk
NAME         MAJ:MIN RM   SIZE   R0 TYPE MOUNTPOINTS
sda            8:0    0 476.9G    0 disk
 |_sda1        8:1    0   512M    0 part  
 |_sda2        8:1    0   2.3G    0 part 
mmcblk0      179:0    0  58.3G    0 disk
 |_mmcblk0p1 179:1    0   128M    0 part 
 |_mmcblk0p2 179:2    0  58.2G    0 part 
nvme0n1      259:0    0 476.9G    0 disk 
 |_nvme0n1p1 259:1    0   260M    0 part /boot/efi
 |_nvme0n1p2 259:2    0 358.4G    0 part /
 |_...
```

I could look to see the disk and partition sizes. The `nvme0n1` disk is the 
SSD on my laptop, the `sda` disk is the SSD I will use for the Pi, and the 
`mmcblk0` is the microSD. I then created mount points for the SSD and microSDs:

```
$ mkdir -p /media/pi/ssd 
$ mkdir -p /media/pi/msd/boot
$ mkdir -p /media/pi/msd/root
$ sudo mount /dev/sda2 /media/pi/ssd/
$ sudo mount /dev/mmcblk0p1 /media/pi/msd/boot 
$ sudo mount /dev/mmcblk0p2 /media/pi/msd/root
```

I could then copy the contents of the microSD root directory to its new 
location on the SSD:

```
$ cp -a /media/pi/msd/root/* /media/pi/ssd/
```

Now I need to set the kernel boot parameters where the root filesystem is.
I need the partition unique ID of the root partition on the SSD, so I listed
this with

```
$ lsblk -o +PARTUUID
```

and then set the parameter in `/boot/firmware/cmdline.txt` on the microSD boot
partition I've mounted like

```
root=PARTUUID=<PARTUUID of the SSD root partition>
```

I updated also `/etc/fstab` on the SSD so that the root filesystem mounts from
the SSD and not the microSD. Lastly, I booted the Pi to verify everything
works.

If you looked closely when I listed the block devices, you may have noticed
that while the disk size of the SSD is 476.9G, the size of the root partition
is only 2.3G. The reason there are two partitions in the first place is because
at one point I tried just booting the Pi directly with the SSD, so this required
that I flash DietPi onto the SSD. Flashing the SSD created a boot and root 
partition that were obviously significantly smaller than the total disk space
available. I could have used a tool like `gparted`, however, DietPi already
comes with a simple tool to expand the partition. So after booting up the Pi,
I simply called 

```
$ dietpi-drive_manager
```
and voila, expanding the root partition to maximize usage of the SSD is done.

At this point, the system boots normally and the heavy I/O happens on the SSD.
Exactly what we want for CI workloads.

# Static Analysis of a Representative Codebase

With the system stable, the next step was validating whether the Pi is actually
useful as a CI runner.

## ARM-native Docker image

Installing the GitLab runner was surprisingly easy once the Pi was stable. You
can follow the [GitLab runner installation
docs](https://docs.gitlab.com/runner/install/), but in short all I needed to do
was `curl` the setup script and then execute it. I chose to use the [Docker
executor](https://docs.gitlab.com/runner/executors/docker/) for my GitLab
runner, meaning CI jobs are run in Docker containers managed by the runner. To
that end, I built a custom Docker image that comes preloaded with several
static analysis tools:

* Fortran:
[fortitude](https://github.com/PlasmaFAIR/fortitude/releases/tag/v0.7.5).
* Python: [ruff](https://github.com/astral-sh/ruff/releases/tag/0.14.14).
* Shell:
[shellcheck](https://github.com/koalaman/shellcheck/releases/tag/v0.11.0).
* CMake:
[cmakelang](https://github.com/cheshirekow/cmake_format/releases/tag/v0.6.13).
* Make: [checkmake](https://github.com/checkmake/checkmake/releases/tag/v0.3.2).

This image is used directly by GitLab CI jobs running on the Pi. If you're
interested, the image is available at [Docker Hub:
jfdev001/iap-gitlab-ci](https://hub.docker.com/repository/docker/jfdev001/iap-gitlab-ci/general).
Naturally, the target architecture is ARM since that's the Pi's architecture;
however, one could easily adapt the Dockerfile for x86-64 architecture. See
section [Static Code Analysis Dockerfile](#static-code-analysis-dockerfile) for
the full Dockerfile at the time of this writing.

It's also worth noting that during the GitLab runner setup on the Pi, I
provided some [advanced
configuration](https://docs.gitlab.com/runner/configuration/advanced-configuration/#the-runnersdocker-section)
to enforce only a subset of valid Docker images that could be used, a RAM limit
for Docker jobs, and a limit on the total memory of jobs when SWAP space is
also used. These restrictions were necessary to keep the intention of the
runner for lightweight jobs codified and not just socially contracted.

## Simple Performance Results

Naturally, I wanted to test how my new GitLab runner could handle static
analysis of a representative codebase. To that end, I submitted a job to
perform static analysis of the [ICON weather/climate
model](https://gitlab.dkrz.de/icon/icon-model) codebase using `fortitude`. For
context, in the `src` directory of this codebase, there are roughly 500k lines
of code spread over 900 files. I forked the ICON codebase to our self-managed
GitLab instance, and provided a job file like the one below:

```yml
# @file .gitlab-ci.yml
# @brief Static analysis of ICON's 500k+ lines of code 900 file Fortran codebase
icon-src-static-analysis:
  stage: test
  image: jfdev001/iap-gitlab-ci:static-analysis-base
  tags:
    - lightweight
  script: |
    # Only emit warning of syntax errors detected, omits specific details 
    # NOTE: || true included to prevent job from automatically crashing 
    find codebases/icon/ -iname "*.f90" -type f\
      -exec fortitude check {} + > /dev/null || true
```

Fortitude completes a full analysis of the codebase in about 10 seconds. For a
low-power, fanless ARM board, that's more than acceptable, and perfectly
adequate for pre-merge CI checks.

# Conclusion

Running a GitLab runner on a Raspberry Pi 3B+ turned out to be both practical
and educational. In summary, I:

1. Chose a Raspberry Pi for cost and control.
2. Enabled USB boot via OTP for long-term recoverability.
3. Moved the root filesystem to an SSD to avoid microSD card wear.
4. Validated the setup with real CI workloads using a custom ARM-native Docker
   image.

The result is a small, quiet, low-power CI runner that does exactly what it
needs to do, and does it reliably. If you're running a self-managed GitLab
instance and want full control over your CI infrastructure without breaking the
bank, a Raspberry Pi is a surprisingly solid option, as long as you respect its
hardware quirks.

# Appendix

Extra details for anything that I felt didn't belong in the main article are
included below.

## Verifying Compiler Optimizations in Assembly

The following section is a deliberate detour into compiler behavior. While
tangential to the CI setup itself, it helps clarify what truly matters when
interpreting static analysis and compiler warnings.

In the example program in section [The Importance of Static Code
Analysis](#the-importance-of-static-code-analysis), you can verify pretty
easily that the unused variable `buf` is harmless by comparing the assembly
generated for `main.c` when optimization flags are turned off and on. In the
following paragraphs, I walk you through assembly code, which is the lowest
level code that is semantically meaningful, for `main.c`. 

With `gcc`, by default the optimization flags are turned off, and we can
explicitly halt the compiler after the compilation proper stage to emit
assembly code, thus preventing the assembler stage (which converts the assembly
code to object files that are not readable with text editors). If we call 

```
$ gcc -O0 -S -fverbose-asm -o main_debug.s main.c 
```

and look at the `foo` section of `main_debug.s`, we see 

```nasm
; @file main_debug.s 
; @brief Snippet of foo section of debug mode gcc assembly output.
; @note For highlighting reasons, I use ';' to denote comments. However, 
;       this is GNU assembly, so '#' would be the syntactically correct choice.
foo:
.LFB6:
    .cfi_startproc
    endbr64 
    pushq %rbp 
    .cfi_def_cfa_offset 16
    .cfi_offset 6, -16
    movq %rsp, %rbp 
    .cfi_def_cfa_register 6
    subq $64, %rsp 
    movl %edi, -52(%rbp) ; x, x
;    main.c:4: void foo(int x) {
    movq %fs:40, %rax ; MEM[(<address-space-1> long unsigned int *)40B], tmp84
    movq %rax, -8(%rbp) ; tmp84, D.2541
    xorl %eax, %eax ; tmp84
;    main.c:6:   buf[x] = 0;
    movl -52(%rbp), %eax ; x, tmp83
    cltq
    movl $0, -48(%rbp,%rax,4) ;, buf[x_2(D)]
;    main.c:7: }
    nop 
    movq -8(%rbp), %rax ; D.2541, tmp85
    subq %fs:40, %rax ; MEM[(<address-space-1> long unsigned int *)40B], tmp85
    je .L2 
    call __stack_chk_fail@PLT 
.L2:
    leave 
    .cfi_def_cfa 7, 8
    ret 
    .cfi_endproc
```

If you have never seen assembly before, the syntax above can be pretty
overwhelming. Fortunately, with the `-fverbose-asm` flag, `gcc` annotated the
important parts so that we can more easily decipher what's going on. Even if
you were unable to read assembly, you could infer from line 20 that somewhere
before line 20 the memory for the `buf` array gets allocated. Why? Because
line 20 is a comment indicating that the proceding assembly corresponds to
`buf[x] = 0`. Therefore, at some point before line 20 in the assembly code,
there must be some allocation of memory for the array. 

Okay, but if we don't want to play an inference game, how do we know *how* much
memory for `buf` actually get allocated? From `main.c` we see that `buf` is
an array where each element is of type `int` and the array can store 10
elements. While the exact number of bytes for C data types might vary from one
hardware architecture to the next, the minimum size for `int` is 4 bytes. 
Now we know that `buf` requires 40 bytes of memory. 

If we know *how* much memory is needed for `buf`, *where* in the assembly can
we look to confirm that memory is allocated? To understand that, you must
understand that when a program executes, every function call requires the
operating system to allocate memory for the functions local variables,
arguments, and return value. The region of memory for a particular function
that gets allocated is called a stack frame. The stack frame is part of the
program (aka *process*) stack itself which has a total size that is much
smaller than the total amount of memory that can be allocated on the heap (see
`RLIMIT_STACK` and `RLIMIT_DATA` in `man getrlimit`). Lines 9 and 12 tell us
that we are allocating a stack frame for the the `foo` function, but the key
giveaway that we are allocating memory for `buf` on the stack is in line 14
with `subq $64, %rsp`. The `$64` says that we need 64 bytes of memory for this
stack frame! 

So there you have it, we allocate 64 bytes which is more... more than actually
needed for the array. Why are we allocating more memory than we need? Well, we
know also that memory must be allocated for the local variable `x` so that is
another 4 bytes. Great, we need at least 44 bytes of memory for our stackframe,
but yet we allocate 64 bytes. It turns out that by default we allocate also 8
bytes for a [stack
canary](https://mcuoneclipse.com/2019/09/28/stack-canaries-with-gcc-checking-for-stack-overflow-at-runtime/)
as a way of securing our code (see `-fstack-protector` in `man gcc`, and note
that in Ubuntu 14.10 `-fstack-protector-strong` is enabled by default). Now we
need at least 52 bytes of memory for our stack frame! Yet we still are
allocating 64 bytes...

It turns out that this is the result of the [System V Application Binary
Interface (ABI)](https://wiki.osdev.org/System_V_ABI), which mandates that for
x86-64 architectures the stack is 16-byte aligned, so therefore additional
bytes are used to pad the stack frame until the memory allocated for the stack
frame is a multiple of 16. 64 is a multiple of 16, therefore, while we only
*need* 52 bytes for the `foo` function call, we *must* allocate 64 bytes to
comply with the ABI. The ABI ensures many things, but with respect to
alignment, it guarantees that a program can run without modification on
multiple operating systems and that function calls occur in a standardized way.

That was a **huge** digression in order to say "hey, we know that when
optimizations are turned off, memory for `buf` in the stack frame is
allocated." But what about when we turn *on* optimizations? Oh no... we're
going to have to look at more scary assembly to see how the compiler treats
unused variables, which is the warning we saw that `gcc` emitted way back in
section [The Importance of Static Code
Analysis](#the-importance-of-static-code-analysis). If we call,

```
$ gcc -O3 -S -fverbose-asm -o main_opt_verbose.s main.c
```

and look at the `foo` section of `main_opt.s`, we see 

```nasm
; @file main_opt.s
; @brief Snippet of foo section of optimized gcc assembly output.
foo:
.LFB16:
	.cfi_startproc
	endbr64	
# main.c:7: }
	ret	
	.cfi_endproc
```

This assembly is much easier to interpret than the unoptimized assembly.
You can clearly see that no `pushq %rbp` operation occurs and no allocation 
of memory for the stack frame with a `subq $LITERAL, %rsp` operation occurs.
The compiler intelligently optimized the stack frame allocation out because
no work occurs in the function call.

All of this just to say that the warning emitted in section [The Importance of
Static Code Analysis](#the-importance-of-static-code-analysis) regarding the
unused variable `buf` can actually be safely ignored since it has no effect on
an optimized object file anyway.

## Static Code Analysis Dockerfile

Here is the Dockerfile used to build the static analysis oriented image for the
Docker executor on the GitLab runner.

```docker
# @file Dockerfile
# @brief Static analysis base image for AARCH64 (e.g., Raspberry Pi 3B+)
FROM python:3.12-slim

# Install system dependencies and static analysis tools 
ARG SHELLCHECK_ARCH=aarch64
ARG SHELLCHECK_VERSION=0.11.0  # https://github.com/koalaman/shellcheck/releases/tag/v0.11.0
ARG CHECKMAKE_ARCH=arm64
ARG CHECKMAKE_VERSION=0.3.2  # https://github.com/checkmake/checkmake/releases/tag/v0.3.2
ARG RUFF_VERSION=0.14.14     # https://github.com/astral-sh/ruff/releases/tag/0.14.14
ARG FORTITUDE_VERSION=0.7.5  # https://github.com/PlasmaFAIR/fortitude/releases/tag/v0.7.5
ARG CMAKELANG_VERSION=0.6.13 # https://github.com/cheshirekow/cmake_format/releases/tag/v0.6.13
RUN \
    # install system dependencies
    apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    tar \
    unzip && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* && \
    # install shellcheck
    curl -L https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.${SHELLCHECK_ARCH}.tar.gz -o shellcheck.tar.gz && \
    tar -xf shellcheck.tar.gz && \
    rm shellcheck.tar.gz && \
    mv shellcheck-v${SHELLCHECK_VERSION}/shellcheck /usr/bin/ && \
    rm -rf shellcheck-v${SHELLCHECK_VERSION} && \
    # install checkmake
    curl -L https://github.com/checkmake/checkmake/releases/download/v${CHECKMAKE_VERSION}/checkmake-v${CHECKMAKE_VERSION}.linux.${CHECKMAKE_ARCH} -o /usr/local/bin/checkmake && \
    chmod +x /usr/local/bin/checkmake && \
    # install python based tools
    pip install --no-cache-dir \
        ruff==${RUFF_VERSION} \
        fortitude-lint==${FORTITUDE_VERSION} \
        cmakelang==${CMAKELANG_VERSION}

CMD ["bash"] 
```
