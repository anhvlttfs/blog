---
slug: homelab-setup-day-0
title: (Setup your own home lab) Day 0 - Planning for the requirements
author: Vo Luu Tuong Anh
author_title: VLTA of @TheFlightSims
author_url: https://github.com/anhvlttfs
author_image_url: https://avatars.githubusercontent.com/u/176574466?v=4
tags: [homelab, local-networking, active-directory]
---

This is the day zero of **TheFlightSims Challenge** - A 10-day challenge to set up a full-stack enterprise network at home, with Microsoft Active Directory, DevOps, and so on.

## What am I having?

To be honest, I only have

- [A Raspberry Pi 5](https://www.raspberrypi.com/products/raspberry-pi-5/) (8GB of RAM, 256GB of SSD, and 64GB of SD Card)
- A [Dell OptiPlex 7050](https://www.dell.com/support/product-details/en-vn/product/optiplex-7050-desktop/drivers) (16GB of RAM, 238GB of SSD, and 238GB of HDD)

Additionally, I also have the following equipment:

- Two safety sockets (3x sockets and 8x sockets) - as extension and for electronic safety
- A [Cisco LinkSys EA2700](https://www.smallnetbuilder.com/wireless/wireless-reviews/cisco-linksys-ea2700-gigabit-dual-band-wireless-n600-router-reviewed/) as wireless access point
- A [Cisco CBS110-8T-D-EU](https://www.cisco.com/c/en/us/products/collateral/switches/business-110-series-unmanaged-switches/datasheet-c78-744158.html) unmanaged network switch.

## Hosting method

Firstly, two servers may be good enough for a local home network. However, as I want to make sure it is also a replication of standard networking in most enterprises, I think it is better to either:

- Buy new devices, sockets, and invest in a new cooling system; or...
- Force both servers to run a bare metal hypervisor

And, as you expected, I chose the second option.

Why? Because:

1. It is cheaper.
2. Manageability. Instead of managing each physical server with different roles, services, and applications individually, we can manage all servers as VMs on a single physical hypervisor host.
3. Scalability. Running a hypervisor means your servers are virtual machines (VMs) that can scale on demand.

## Planning Hypervisor host and VMs

### Planning on services and where to host

Since all servers are running bare metal hypervisors, I decided to run those servers with hypervisor software.

- Raspberry Pi 5 will run [LXD](https://canonical.com/lxd) as the management layer, running on top of Ubuntu Server 24.04 LTS.
- Dell OptiPlex 7050 will run [Windows Server 2022](https://learn.microsoft.com/en-us/windows-server/get-started/whats-new-in-windows-server-2022) with the [Hyper-V](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/) role enabled. It will host Windows Server VMs, since Active Directory is the core service of my network, and it runs best on Windows Server VMs hosted on Hyper-V. *Note that the Windows Server edition must be Datacenter, because the Standard Edition only supports up to 2 VMs of Windows Server instance running.*

Moreover, some roles and services must be installed for manageability, security, or backup.

- Shell service: **On Windows Server**, it is Windows Remote Management (WinRM) over PowerShell and Windows Management Instrumentation (WMI). However, I prefer using WinRM with PowerShell over WMI, as WMI is designed for complex scripting with .NET Framework 4.8. **On Ubuntu Server**, it is Secure Shell (`sshd`). It may need to disable access using a password and only authenticate with a certificate.
- Manage via web interface: **On Windows Server**, it is [Windows Admin Center](https://www.microsoft.com/en-us/windows-server/windows-admin-center). **On Ubuntu Server**, it is [Cockpit](https://cockpit-project.org/).
- Additionally, Windows Server will have to install those features for further system investigation and backup: Microsoft Defender Antivirus, Setup and Boot Event Collection, System Data Archiver, System Insights, and Windows Server Backup.

### Roles and Services running on VMs

For servers as VMs running on Windows Server Hyper-V:

1. 2 domain controllers: Active Directory Domain Services (AD DS), Active Directory Certificate Services (AD CS), and DNS Server.
2. Authentication server: Active Directory Federation Services (AD FS), Network Policy and Access Services (NPS), and all RSAT features.
3. Database server: [Microsoft SQL Server 2022](https://www.microsoft.com/en-us/sql-server/sql-server-2022).
4. Web Server: [Web Server (IIS)](https://learn.microsoft.com/en-us/iis/get-started/introduction-to-iis/introduction-to-iis-architecture).
5. [Windows Server Update Service](https://learn.microsoft.com/en-us/windows-server/administration/windows-server-update-services/get-started/windows-server-update-services-wsus)
6. [A Keycloak server](https://www.keycloak.org/) as compatible layer with OIDC and SAML.

For the server as VMs running on LXD:

1. The exit relay DNS server: [Pi-Hole Ad-blocker](https://pi-hole.net/).
2. DevOps server: [GitLab EE](https://about.gitlab.com/enterprise/).
3. DevOps Runner: [GitLab Runner](https://docs.gitlab.com/runner/)
4. Disposable DaaS Server: [KASM Instance](https://www.kasmweb.com/docs/develop/index.html)

## Networking

### Local Domain Names

Since this is only for the home network, the TLDs of the domain should ideally not be published or used publicly to prevent conflicts with the wider Internet. For example, avoid using `.com` or `.net`. Also, avoid using the `.local` domain, as it causes mDNS issues.

As the best practice, look for [registered TLDs on IANA](https://www.iana.org/domains/root/db) to prevent conflicts for a local domain name.

In this case, I will use the domain `workshop.neko`. Alternatively, `web.neko` is used for web deployments. (eg. IIS host or GitLab Pages).

## Hypervisor disk partitioning and disk-based computing for backup plans

### On the HV01 (running Windows Server 2022)

HV01 on Dell OptiPlex 7050 has two disks, both in good condition.

Since the system must also have a backup solution, I decided to do the following partition scheme:

- On the nNVME SSD: Since the SSD has fast I/O, it will become the primary disk, where it holds both the host operating system and all VM contents (incl. disks, configurations, and snapshots).
- On the SATA SSD: It is much slower, but more reliable, so it becomes the secondary disk for holding backup contents, incl. backup of host machine, backup of VMs (VMs will send backups via SMB to the host).

### On the HV02 (running Ubuntu Server 24.04 LTS)

HV02 on Raspberry Pi 5 has 2 disks, both in good condition.

- On SSD: Since it stores both the backup content sent from HV01 over the network, it should be at least the size of the OptiPlex 7050 backup partition, and the rest for the OS and all VMs.
- On the SD card: It is much slower than the SSD, so it will become a backup solution for the operating system on Raspberry Pi 5.
