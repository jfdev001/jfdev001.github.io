---
title: 'Creating a Debian Package for FTorch'
date: 2026-02-12
permalink: /posts/2026/03/ftorch-debian-package/
tags:
    - Linux
    - Debian
    - Packaging 
    - CI/CD 
---

## Initial Attempt 

The below is simplified for GNU autotools projects; however, it is actually
not optimal for CMake projects since CMake comes bundled with CPack for easing
cross platform packaging 

* Debian Virtual Machine in VMware 
* Install the required dependencies
* Use ssh from host machine to vm for ease... you can't copy and paste
graphically from 
* private distribution, you just need to to have be on the release page 
for the repo, just put it in the debian package... you don't necessarily need
to upload it and make it an official package
* how to handle the torch dependency.. should be self contained
* build for GNU architectures
* Writing a CI for building it in the Git repo 

## CPack attempt 

* You only need to produce packages for debian and rpm.
* CPack automates this.
* Check the mastering CMake
* Check the professional cmake 
* Refer to representative large scale projects uses evanlib github: opencv (syntax),
claude desktop (devops for auto deploy), and keepassxc (syntax)
