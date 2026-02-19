---
slug: homelab-setup-day-1
title: (Setup your own home lab) Day 1 - Set up new operating system on bare metal
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

After restarting, OPNSense will launch. However, the interface is not yet assigned - OPNSense cannot distinguish between WAN and LAN interfaces. To configure this, in the main interface, select `1` to assign the interface.

In my case, I set up the `re0` interface as the WAN and `re1` as the LAN. The WAN interface has the static IP address of my home network (`172.16.0.2/16`), while the LAN interface is assigned the first IP address in the local network (`192.168.1.1/24`).

![OPNSense interface assignment](/homelab-setup-day-1/opnsense-interface-assignment.png)

After assigning the interface, you can try accessing the router via the web interface, as management will be much easier, by connecting your laptop or desktop computer to a switch, and allowing the router to connect to the same switch. Note that the DHCP server may not be working, so you may also need to assign your client a static IP address.

![OPNSense Web Interface](/homelab-setup-day-1/opnsense-web-interface.png)

You can configure additional advanced features, such as network monitoring, to quickly troubleshoot issues in case of internet connection loss.

![OPNSense Uplink Monitoring](/homelab-setup-day-1/opnsense-uplink-monitor.png)

### Download & install new Windows hypervisor host on HV01

For the Windows Server installation, it is pretty much straight forward - you click the installation, select "Windows Server 2022 Datacenter Evaluation (Desktp Experience)", do the partitioning, and let the installer does the rest for you

![Windows Server setup experience](/homelab-setup-day-1/windows-server-setup.png)

Once the setup is complete, you will be rebooted into the Windows OOBE screen. Since the installation medium is *"Evaluation"*, you may need to convert into *Production*, by using this command

```cmd
dism /online /Set-Edition:ServerDatacenter /ProductKey:<Your product key> /AcceptEula
```

In case you don't have a product key, but still want to escape the evaluation mode, you can try using the [KMS public key by Microsoft](https://learn.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys?tabs=windows102016%2Cwindows81%2Cserver2025%2Cversion1803#windows-server-ltsc)
. Note that you may need to restart the server right after

Another consideration is uninstalling optional features and apps, such as Microsoft Edge, Microsoft Paint, and Windows Hello. It is nice to know that Edge is considered as optional feature in Windows Server, so you can uninstall it in **Control Panel**, or in the **System Setting > App** and **System Setting > Optional Features**. A optional features installed should look like this

![Windows Server Optional Features](/homelab-setup-day-1/windows-server-optional-features-list.png)

After everything above are done, you can install **Hyper-V** roles onto the hypervisor host, and features such as **Network Virtualization**, **Windows Server Backup**, **System Data Archiver**, and **System Insights**

Another note for the Hyper-V host is turn on the Remote Desktop, with secure connection, so you can remotely control it without always plug your monitor, keyboard, and mouse into it.

![Windows Server enable RDP](/homelab-setup-day-1/windows-server-enable-rdp.png)

Once everything above is done, try to restart the Windows Server, installing drivers and get latest drivers for hardware, restart it again, and put into ready for installing new virtual machines on top of it.
