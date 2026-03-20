---
title: 'Printer Rejects USB Drive: How I Fixed It'
date: 2026-03-20
permalink: /posts/2026/03/fixing-printer-rejecting-usb-drive/
tags:
    - USB
    - Printer
    - File System
    - FAT32
---

I recently ran into a frustrating problem: I wanted to print a PDF directly
from a USB stick, but the printer kept showing "memory device is not working
properly." The drive had previously been flashed with Debian, so I assumed
deleting the old files and copying my PDF would be enough. This was, of course,
not the solution. In this short article, I cover what I did to fix the problem.

When I plugged the drive into my Linux laptop and called `fdisk -l`, the output
showed a Linux partition still lingering on the drive:

```
Disk /dev/sda: 7.46 GiB Device     Boot   Start      End  Sectors Size Id Type
/dev/sda2       1064960 15646719 14581760   7G 83 Linux
```

Even after copying my PDF, the printer refused to read it. It turns out
printers are picky and cannot read Linux filesystems like ext4. They expect a
FAT32 (or sometimes exFAT) partition starting at the beginning of the drive.
This makes sense since FAT32 is one of the oldest and widely supported file
systems (see [Kingston Tech: Understanding file systems and drive
formatting](https://www.kingston.com/en/blog/personal-storage/understanding-file-systems))
Changing permissions (`chmod +777`) on Linux didn't help either. In retrospect,
it makes sense that this didn't work since the printer cannot understand Linux
file permissions.

However, the fix was straightforward:

* Wipe the old partitions and create a fresh DOS partition table.
* Create a single primary FAT32 partition covering the entire drive.
* Format the partition as FAT32.

On Linux, the steps are simple using `fdisk` and `mkfs.vfat`:

```shell
sudo umount /dev/sda* 
# then use: o > n > p > 1 > Enter > Enter > t > b > W95 FAT32 > w 
sudo fdisk /dev/sda  
sudo mkfs.vfat -F 32 /dev/sda1
```

After that, I copied my PDF to the root of the USB drive, plugged it into the
printer, and it worked immediately.

This little episode was a great reminder: USB drives that were once used for
Linux installations often leave behind partitions that devices like printers
cannot read. It taught me to always make sure your filesystem matches the
device's expectations.
