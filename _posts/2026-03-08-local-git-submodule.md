---
title: 'Local git submodules for custom build scripts and automation...'
date: 2026-02-12
permalink: /posts/2026/03/local-git-submodules/
tags:
    - Git
    - Bash
    - Build
---

* you should be able to modify `.git/config` in order to specify submodules
that you would like.. then you can modify `.git/info/exclude` to exclude 
certain submodules as well so that you get build scripts that are reproducible
but also that aren't shared across machines....
