---
slug: homelab-setup-day-1
title: (Setup your own home lab) Day 1 - Planning for the requirements
author: Vo Luu Tuong Anh
author_title: VLTA of @TheFlightSims
author_url: https://github.com/anhvlttfs
author_image_url: https://avatars.githubusercontent.com/u/176574466?v=4
tags: [homelab, local-networking, active-directory]
---

This is the day zero of **TheFlightSims Challenge** - A 10-day challenge to set up a full-stack enterprise network at home, with Microsoft Active Directory, DevOps, and so on.

## Set up new operating system on bare metal

### Download & install new OPNSense instance on router

You can check out for the system requirements on the [OPNSense system requirements](https://opnsense.org/get-started/)

![OPNSense Requirements](/homelab-setup-day-1/opnsense-system-reqs.png)

From the official page, you can download new instance of OPNSense.

![OPNSense download page](/homelab-setup-day-1/opnsense-dvd-download.png)

I recommend using a VGA image (if your router doesn't support a serial interface). You can connect the monitor to the router via the HDMI port and let it output the image for you.

Installing OPNSense is pretty easy, just login as `installer` as logon and `opnsense` as password, setup the keyboard layout, and let the installer does the rest for you, from disk partitioning, to unpacking packages.

Once done, you **MUST** set for the root password, so you can log into the OPNSense system, using your own credential, instead of the default password of OPNSense

![OPNSense set root password](/homelab-setup-day-1/opnsense-set-root.png)
