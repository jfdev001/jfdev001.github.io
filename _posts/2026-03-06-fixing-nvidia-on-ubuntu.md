---
title: 'Fixing a Broken NVIDIA / GNOME Setup on Ubuntu'
date: 2026-03-06
permalink: /posts/2026/03/nvidia-on-ubuntu/
tags:
    - gpu
    - ubuntu
    - nvidia
    - broken drivers
---

Recently my Ubuntu installation ended up in a broken state after a reboot:
external displays stopped working, `nvidia-smi` failed inside the desktop
environment (DE), and the system would hang while stopping `gdm` during
shutdown. Interestingly, the NVIDIA driver still worked in recovery mode, which
suggested the kernel modules themselves were not completely broken. I decided
to reset both the NVIDIA stack and the DE entirely since I
have had issues in the past with GPU weirdness.

One thing that helped diagnose root issues was disabling the graphical splash
screen during boot. By default Ubuntu hides most boot messages behind the
splash screen, which makes it hard to see where the system is hanging.

To see the real boot output, while in the Ubuntu DE I edited the GRUB
configuration:

```
sudo nano /etc/default/grub
```

In the line:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
```

I removed quiet splash so it became:

```
GRUB_CMDLINE_LINUX_DEFAULT=""
```

Then I updated the GRUB:

```
sudo update-grub
```

Now Ubuntu displayed the full boot log instead of the splash screen. This made
it obvious that the system was hanging while rebooting from the DE due to
`gdm`, which pointed toward a joint problem with the DE and GPU stack rather
than the kernel itself.

At this point, I hard reset, then powered back on. I then pressed `ESC` in
order to reveal the GRUB boot menu. I then entered recovery mode and fixed the
issue as follows:

First, I updated the system to ensure all packages and kernel components were
consistent:

```
apt update && apt upgrade
```

Next, I completely removed all NVIDIA and CUDA packages:

```
apt --purge remove "*nvidia*" "*cuda*"
```

To make sure no stale desktop configuration remained, I also removed the GNOME
desktop and the display manager:

```
apt --purge remove ubuntu-desktop gdm3
```

Then I cleaned up any remaining dependencies:

```
apt autoremove
```

After that, I reinstalled the desktop environment:

```
apt install ubuntu-desktop gdm3
```

Finally, I let Ubuntu reinstall the recommended GPU drivers automatically:

```
ubuntu-drivers install
```

After rebooting, the system came up normally again. NVIDIA worked inside the
desktop environment, external displays were detected, and the `gdm` shutdown
hang was gone. While perhaps not the most elegant solution, completely
resetting both the GPU drivers and the desktop environment turned out to be the
fastest path to a clean state.

**Update (2026-03-10)**

Interestingly, this solution worked only temporarily. I did not dig into
system logs; however, it turns out that by default `ubuntu-drivers` will try
and install the most recent stable driver available. In this, on my Ubuntu 24.04
system with v6.17 kernel, the automatically installed driver was
nvidia-driver-590. Oddly, this is actually *not* the driver version that is
recommended if you list the available devices for which drivers are available
with

```shell
ubuntu-drivers devices
```

The output was 

```text
driver   : nvidia-driver-580-open - distro non-free recommended
```

So, in order to properly fix my problem, I did the following:

```shell
# 1. Purge all NVIDIA leftovers
sudo apt purge '*nvidia*' '*cuda*'
sudo apt autoremove

# 2. Update package lists
sudo apt update

# 3. Install NVIDIA driver 580
sudo apt install nvidia-driver-580 nvidia-settings nvidia-prime

# 5. Reboot
sudo reboot
```

I ended up doing this for v6.14 kernel, which I set to the default kernel
loaded during boot by modifying `/etc/default/grub` with

```text
GRUB_DEFAULT="Advanced options for Ubuntu>Ubuntu, with Linux 6.14.0-37-generic"
```

and then `sudo update-grub`.

I have since had no issues with my drivers or display manager :))
