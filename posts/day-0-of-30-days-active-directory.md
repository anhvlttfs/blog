---
title: Setting up a new Home Lab - Day 0
date: 2025-11-01
permalink: /homelab-setup/day-1
---

# Day 1

This is the day zero of **TheFlightSims Challenge** - A 14-day challenge to set up a full-stack enterprise network at home, with Microsoft Active Directory, DevOps, and so on.

## What am I having?

To be honest, I only have

- A Raspberry Pi 5 (8GB of RAM, 256GB of SSD, and 64GB of SD Card)
- A Dell OptiPlex 7050 (16GB of RAM, 256GB of SSD, and 256GB of HDD), all are working in good condition.

Additionally, I also have following equipments:

- Two safety sockets (3 sockets and 8x sockets) - for electronic safety
- A Wifi router (TP-Link WR820N) - as network router and wireless modem
- A non-configurable switch (TP-Link) - for network physicial segmentation
- 2 external cooling fans (one for my Raspberry Pi, another to make the air cycle better for OptiPlex 7050)

## Hosting method

At first, two servers may good enough for a local home network. However, as I want to make sure it also a replication of a standard networking in most enterprise, I think it is better to either:

- Buy new devices, sockets, and investing in a new cooling system; or...
- Force both servers running bare metal hypervisor

And, as you expected, I choose the second option.

Why? Because:

1. It is cheaper
2. Manageability. Instead of manage each physical server - with different roles, services, and applications individuality, we can only manage a physical hypervisor host.
3. Scalibility. Running hypervisor means your servers as virtual machines (VMs) are able to scale up on high demand, and scale down on low demand.

## Planning on services and where to host

Since all servers are running bare metal hypervisor, so I decide to run those servers with hypervisor software:

- Raspberry Pi 5 will run LXD as the management layer (I know LXD is not bare metal hypervisor, but it has features as most bare metal hypervisors do), running on a top of Ubuntu Server 24.04 LTS.
- Dell OptiPlex 7050 will run Windows Server 2022 Datacenter with Hyper-V role enabled. It will host for Windows Server VMs, since Active Directory is the core service of my home network, and it runs best on Windows Server VMs host on a Hyper-V. Note that the edition must be Datacenter, because the Standard Edition only supports up to 5 VMs running.

More over, some roles and services must install for managebility, security, or backup

- File Server with SMB-enabled for backup over the network
  - On Windows Server, it also needs data deduplication, enhanced storage, storage migration services, and storage replica.
  - On Ubuntu Server, it is configured with Samba.
- Shell service
  - On Windows Server, it is Windows Remote Management (WinRM) over PowerShell and Windows Management Instrument (WMI). However, I prefer using WinRM with Powershell over WMI, since WMI is better for complex scripting, with built-in .NET Framework 4.8
  - On Ubuntu Server, it is Secure Shell (sshd). It may need to disable access using password, and only authenticate with certificate.
- Manage via web interface
  - On Windows Server: Windows Admin Center
  - On Ubuntu Server: Cockpit
- Additionally, Windows Server will have to install those features for further system investigation and backup:
  - Microsoft Defender Antivirus
  - Setup and Boot Event Collection
  - System Data Archiver
  - System Insights
  - Windows Server Backup

## Roles and Services running on VMs

For servers as VMs running on Windows Server Hyper-V:

1. Two domain controllers
   - Active Directory Domain Services (AD DS)
   - Active Directory Certficate Services (AD CS)
   - DNS Server
   - File Server
2. Authentication server
   - Active Directory Federation Services (AD FS)
   - File Server
   - Network Policy and Access Services (NPS)
   - And all RSAT features
3. Database server
   - SQL Server 2022 Enterprise
   - File Server
4. Web Server
   - Web Service (IIS)
   - File Server

For server as VMs running on LXD:

1. Exit relay DNS server
   - Pi-Hole Ad-blocker
2. DevOps server
   - GitLab EE
3. DevOps Runner
   - GitLab Runner
   - Docker CE

## Device naming and IPv4 assignments


