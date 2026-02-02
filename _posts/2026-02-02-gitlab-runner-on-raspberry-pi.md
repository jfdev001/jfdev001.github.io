---
title: 'Setting up a GitLab runner on a Raspberry Pi 3B+'
date: 2026-02-02
permalink: /posts/2026/02/gitlab-runner-on-raspberry-pi/
tags:
    - Linux
    - Raspberry Pi
    - CI/CD
    - GitLab
---

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
