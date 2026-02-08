---
title: 'Lightweight CI/CD: Seting up a GitLab Runner on a Raspberry Pi 3B+'
date: 2026-02-07
permalink: /posts/2026/02/gitlab-runner-on-raspberry-pi/
tags:
    - Linux
    - Raspberry Pi
    - CI/CD
    - GitLab
---

If you choose to host a self-managed (i.e. private) GitLab instance on
on-premises infrastructure,  you do not get access to GitLab’s shared (public)
runners for CI/CD. Unlike GitLab.com or GitLab Dedicated, a private GitLab
instance puts you fully in control, but that control comes with
responsibility. You have to bring your own runners. In this article, I document
my experience setting up a GitLab runner on a Raspberry Pi 3B+, why I chose
this route, and how I did it. Spoiler: while the setup itself is fairly
straightforward, there are some Raspberry Pi–specific hardware quirks that are
worth handling correctly if you care about long-term stability and
recoverability.

<!--
# CI/CD and GitLab 

* what is CI/CD
* what is gitlab
* gitlab hosted runners are not available to self-managed instances, but *are*
available to GitLab dedicated users (see [here](https://docs.gitlab.com/ci/runners/)),
we don't have the dedicated users plan

# Bootstrapping the Raspberry Pi 3B+

* why? cheap, already available, i can configure it myself 
* use the one time programmable memory (OTP) to allow usb bootable for easier
recovery should i brick the system.... in theory this option should already 
be enabled per the most recent docs (see [here](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-3b-zero-2-w)),
however, this may be only on newer manufactured versions of the Pi, and when
i called `vcgencmd get_config program_usb_boot_mode` it printed 
`program_usb_boot_mode=0`, which means i had to update the `/boot/firmware/config.txt`
* for better sustainability, i attach an SSD and mount the root partition 
on the SSD and leave the /boot/firmware partition on the microSD
    * this meant i needed 
Plug-in microSD and SSD to a linux machine
lsblk -o +PARTUUID
cp -a root on microSD to an expanded partition on the SSD
Update /boot/firmware cmdline.txt such that the root filesystem corresponds to
the PARTUUID of the SSD 
Update /etc/fstab on SSD such that the root file system is on the SSD 
and the bootloader (i.e., /boot/firmware) is on the microSD 
dietpi-drive_manager to expand the file system to fill the partition

# Static Analysis of a Representative Codebase

* i wrote a docker image that comes preloaded with several static analysis
tools... the image is built specifically for ARM since this is the target
architecture.
* in about 30 seconds fortitude can perform static anlysis of 500k LOC 
over ~900 files 

# Conclusion 

* summary of what i did 
-->

# CI/CD and GitLab

Before diving into hardware and bootloaders, it’s worth briefly setting the
stage.

## What is CI/CD?

Continuous Integration (CI) and Continuous Deployment/Delivery (CD) are
practices that automate the process of:

building code,

running tests,

performing static analysis,

and deploying artifacts

whenever changes are pushed to a repository.

The goal is to catch issues early, reduce manual steps, and make software
delivery repeatable and reliable.

## What is GitLab?

GitLab is a web-based DevOps platform that combines:

Git repository hosting

issue tracking

CI/CD pipelines

container registries

and more

into a single application. One of GitLab’s strengths is how tightly integrated
CI/CD is with the repository itself: pipelines are defined declaratively via
.gitlab-ci.yml.

Why runners matter for self-managed GitLab

GitLab CI pipelines are executed by GitLab runners, agents that poll GitLab for
jobs and execute them.

If you use:

GitLab.com → shared runners are available

GitLab Dedicated → shared runners are available

Self-managed GitLab → ❌ no shared runners

As documented in GitLab’s runner documentation (see here), shared runners are
not available to self-managed instances unless you are on the Dedicated
offering. In our case, we’re not, so self-hosted runners are mandatory.

# Bootstrapping the Raspberry Pi 3B+

## Why a Raspberry Pi?

The Raspberry Pi 3B+ checked several boxes for me:

It’s cheap

I already had one available

Low power consumption

ARM architecture matches several of our deployment targets

Full control over OS, storage, and networking

For CI workloads like static analysis, linting, and lightweight builds, this is
more than sufficient.

## Enabling USB boot (OTP memory)

One thing I care deeply about with unattended systems is recoverability. SD
cards fail. Filesystems get corrupted. Eventually, you will brick something.

The Raspberry Pi supports USB boot via a one-time programmable (OTP) bit that
enables booting from USB mass storage devices. According to recent
documentation, this should already be enabled on newer Pi models (see here).

However, when I checked:

vcgencmd get_config program_usb_boot_mode


I got:

program_usb_boot_mode=0

Which means USB boot was not enabled.

To fix this, I had to explicitly update /boot/firmware/config.txt to enable USB
boot, then reboot once to permanently set the OTP bit. This is a one-way
operation, but one that significantly improves recovery options if the system
becomes unbootable.

## Moving the root filesystem to an SSD

Running a CI runner continuously on a microSD card is not something I’d
recommend. SD cards have limited write endurance, and CI workloads can be
surprisingly write-heavy.

My approach:

Keep /boot/firmware on the microSD

Move the root filesystem (/) to an external SSD

This gives:

better performance

vastly improved durability

simpler recovery (swap SSDs if needed)

Migration steps (high-level)

Plug the microSD and SSD into a Linux machine

Identify partitions and PARTUUIDs:

lsblk -o +PARTUUID


Create and expand a root partition on the SSD

Copy the root filesystem from the microSD:

cp -a /mnt/microsd-root/. /mnt/ssd-root/


Update /boot/firmware/cmdline.txt to point root= to the SSD’s PARTUUID

Update /etc/fstab on the SSD so that:

/ mounts from the SSD

/boot/firmware mounts from the microSD

Boot the Pi and verify everything works

Expand the filesystem to fill the SSD:

dietpi-drive_manager


At this point, the system boots normally, but the heavy I/O happens on the SSD,
exactly what we want for CI workloads.

# Static Analysis of a Representative Codebase

With the system stable, the next step was validating whether the Pi is actually
useful as a CI runner.

## ARM-native Docker image

I built a custom Docker image that comes preloaded with several static analysis
tools. The key detail: the image is built specifically for ARM, avoiding
emulation overhead and ensuring realistic performance.

This image is used directly by GitLab CI jobs running on the Pi.

## Performance results

On a representative codebase:

~500k lines of code

~900 files

One of the static analysis tools (Fortitude) completes a full analysis in about
30 seconds.

For a low-power, fanless ARM board, that’s more than acceptable, and perfectly
adequate for pre-merge CI checks.

# Conclusion

Running a GitLab runner on a Raspberry Pi 3B+ turned out to be both practical
and educational.

In summary, I:

Set up a self-hosted GitLab runner for a private GitLab instance

Chose a Raspberry Pi for cost, control, and ARM compatibility

Enabled USB boot via OTP for long-term recoverability

Moved the root filesystem to an SSD to avoid SD card wear

Validated the setup with real CI workloads using ARM-native Docker images

The result is a small, quiet, low-power CI runner that does exactly what it
needs to do, and does it reliably. If you’re running a self-managed GitLab
instance and want full control over your CI infrastructure without breaking the
bank, a Raspberry Pi is a surprisingly solid option, as long as you respect its
hardware quirks.

<!--Outline:
* Situation: Standards and workflows at IAP and limited server access 
* Action:  Use lightweight raspberry pi (dietpi OS) that has root partition
mounted to SSD for longer term read/writes and enabled boot from usb incase i bricked
it before that point setup with configured gitlab runner and image intended to
be used with codbases...
* Resolution: GitLab runner and docker image with everything one needs to 
run simple static analysis tests......
* Might be interesting to see how the static analysis fairs against a codebase
like ICON (i.e., stress test it...)... it has no issue with this at all
(static analysis possible in ~30 seconds)
* details: https://igit.iap-kborn.de/icon-iap/test-gitlab-runners/-/issues/1
-->
