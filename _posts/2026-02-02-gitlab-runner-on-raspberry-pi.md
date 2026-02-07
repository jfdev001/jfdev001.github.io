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

If you choose to host a private GitLab instance on on-premises (on-prem)
infrastructure, you do not gain access to public (aka shared) GitLab runners
that can be used for CI/CD. Such private GitLab instances offers its
administrators much more control over the services they wish to offer on their
instance, and this means that you have to setup your own GitLab runners rather
than relying on public ones. In this article, I document my experiences setting
up a GitLab runner on a Rapsberry Pi 3B+ including why I did this and how I did
this. Sneak peak: there are some hardware quirks that I had to be careful of in
order to do things the *right* way.

Outline:
* Situation: Standards and workflows at IAP and limited server access 
* Action:  Use lightweight raspberry pi (dietpi OS) that has root partition
mounted to SSD for longer term read/writes and enabled boot from usb incase i bricked
it before that point setup with configured gitlab runner and image intended to
be used with codbases...
* Resolution: GitLab runner and docker image with everything one needs to 
run simple static analysis tests......
* Might be interesting to see how the static analysis fairs against a codebase
like ICON (i.e., stress test it...)
* details: https://igit.iap-kborn.de/icon-iap/test-gitlab-runners/-/issues/1
