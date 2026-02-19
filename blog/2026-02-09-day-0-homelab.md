---
slug: homelab-setup-day-0
title: (Day 0) [Setup your own home lab] Planning for the requirements
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
- A [Dell OptiPlex 7050](https://www.dell.com/support/product-details/en-vn/product/optiplex-7050-desktop/drivers) (16GB of RAM, 238GB of SSD, and 298GB of HDD)

Additionally, I also have the following equipment:

- Two safety sockets (3x sockets and 8x sockets) - as extension and for electronic safety
- A Wifi router ([TP-Link WR820N](https://www.tp-link.com/ae/support/download/tl-wr820n/)) - as a network router and wireless modem
- A non-configurable switch (TP-Link) - for network physical segmentation
- 2 external cooling fans (one for my Raspberry Pi, another to make the air cycle better for OptiPlex 7050)

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
- Dell OptiPlex 7050 will run [Windows Server 2022](https://learn.microsoft.com/en-us/windows-server/get-started/whats-new-in-windows-server-2022) with the [Hyper-V](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/) role enabled. It will host Windows Server VMs, since Active Directory is the core service of my home network, and it runs best on Windows Server VMs hosted on Hyper-V. *Note that the Windows Server edition must be Datacenter, because the [Standard Edition only supports up to 2 VMs of Windows Server instance running](https://blog.anhvlt.io.vn/homelab-setup/docs/Core-based_licensing_guidance.pdf).*

Moreover, some roles and services must be installed for manageability, security, or backup.

- File Server with SMB enabled for backup over the network. **On Windows Server**, it also needs data deduplication, enhanced storage, storage migration services, and storage replicas. **On Ubuntu Server**, it is configured with [Samba](https://www.samba.org/).
- Shell service: **On Windows Server**, it is Windows Remote Management (WinRM) over PowerShell and Windows Management Instrumentation (WMI). However, I prefer using WinRM with PowerShell over WMI, as WMI is designed for complex scripting with .NET Framework 4.8. **On Ubuntu Server**, it is Secure Shell (`sshd`). It may need to disable access using a password and only authenticate with a certificate.
- Manage via web interface: **On Windows Server**, it is [Windows Admin Center](https://www.microsoft.com/en-us/windows-server/windows-admin-center). **On Ubuntu Server**, it is [Cockpit](https://cockpit-project.org/).
- Additionally, Windows Server will have to install those features for further system investigation and backup: Microsoft Defender Antivirus, Setup and Boot Event Collection, System Data Archiver, System Insights, and Windows Server Backup.

### Roles and Services running on VMs

For servers as VMs running on Windows Server Hyper-V:

1. Two domain controllers: Active Directory Domain Services (AD DS), Active Directory Certificate Services (AD CS), and DNS Server.
2. Authentication server: Active Directory Federation Services (AD FS), Network Policy and Access Services (NPS), and all RSAT features.
3. Database server: [Microsoft SQL Server 2022](https://www.microsoft.com/en-us/sql-server/sql-server-2022).
4. Web Server: [Web Server (IIS)](https://learn.microsoft.com/en-us/iis/get-started/introduction-to-iis/introduction-to-iis-architecture).

For the server as VMs running on LXD:

1. The exit relay DNS server: [Pi-Hole Ad-blocker](https://pi-hole.net/).
2. DevOps server: [GitLab EE](https://about.gitlab.com/enterprise/).
3. DevOps Runner: [GitLab Runner](https://docs.gitlab.com/runner/), [Docker CE](https://docs.docker.com/engine/install/).

## Networking

### Local Domain Names

Since this is only for the home network, the TLDs of the domain should ideally not be published or used publicly to prevent conflicts with the wider Internet. For example, avoid using `.com` or `.net`. Also, avoid using the `.local` domain, as it causes mDNS issues.

As the best practice, look for [registered TLDs on IANA](https://www.iana.org/domains/root/db) to prevent conflicts for a local domain name.

In this case, I will use the domain `workshop.neko`. Alternatively, `web.neko` is used for web deployments. (eg. IIS host or GitLab Pages).

### Private IPv4 address map

I expect under 100 clients (not servers!) will join into my network, I will use the `192.168.1.0/24` - which has in total of 254 IP addresses.

I segmented it into parts, as you can see in the table below

<table>
    <thead>
        <tr>
            <th>Address Range</th>
            <th>Max devices</th>
            <th>Purposes</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><code>192.168.1.1</code> - <code>192.168.1.4</code></td>
            <td>4</td>
            <td>Routers and Essential Networking Devices (Switches, Load Balancing)</td>
        </tr>
        <tr>
            <td><code>192.168.1.5</code> - <code>192.168.1.9</code></td>
            <td>5</td>
            <td>Hypervisor server range</td>
        </tr>
        <tr>
            <td><code>192.168.1.10</code> - <code>192.168.1.29</code></td>
            <td>20</td>
            <td><strong>HV01</strong> VMs range</td>
        </tr>
        <tr>
            <td><code>192.168.1.30</code> - <code>192.168.1.49</code></td>
            <td>20</td>
            <td><strong>HV02</strong> VMs range</td>
        </tr>
        <tr>
            <td><code>192.168.1.50</code> - <code>192.168.1.109</code></td>
            <td>60</td>
            <td>Reserved for VMs in different hypervisor hosts</td>
        </tr>
        <tr>
            <td><code>192.168.1.110</code> - <code>192.168.1.254</code></td>
            <td>145</td>
            <td>Client range</td>
        </tr>
    </tbody>
</table>

### Actual device naming & IP address assignment

<table>
    <thead>
        <tr>
            <th>Server Name</th>
            <th>Installed Roles based on Software</th>
            <th>Operating System</th>
            <th>IPv4 assignment</th>
            <th>IPv6 assignment (postfix)</th>
            <th>Note</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>-</td>
            <td>Router</td>
            <td>-</td>
            <td><code>192.168.1.1</code></td>
            <td>-</td>
            <td>Router (TP-Link)</td>
        </tr>
        <tr>
            <td>HV01</td>
            <td>Hyper-V</td>
            <td>Windows Server 2022</td>
            <td><code>192.168.1.5</code></td>
            <td>-</td>
            <td>Hypervisor host</td>
        </tr>
        <tr>
            <td>HV02</td>
            <td>LXD</td>
            <td>Ubuntu 24.04 LTS</td>
            <td><code>192.168.1.6</code></td>
            <td>-</td>
            <td>Hypervisor host</td>
        </tr>
        <tr>
            <td>DC01</td>
            <td>AD DS, AD CS, DNS Server</td>
            <td>Windows Server 2022</td>
            <td><code>192.168.1.10</code></td>
            <td><code>::fff8</code></td>
            <td>Primary Domain Controller</td>
        </tr>
        <tr>
            <td>DC02</td>
            <td>AD DS, AD CS, DNS Server</td>
            <td>Windows Server 2022</td>
            <td><code>192.168.1.11</code></td>
            <td><code>::fff9</code></td>
            <td>Secondary Domain Controller</td>
        </tr>
        <tr>
            <td>AUTH</td>
            <td>AD FS, NPS, RSATs</td>
            <td>Windows Server 2022</td>
            <td><code>192.168.1.20</code></td>
            <td>-</td>
            <td>Federation Services and RADIUS</td>
        </tr>
        <tr>
            <td>WEB</td>
            <td>Web Server (IIS, without .NET 3.5), Windows Container</td>
            <td>Windows Server 2022</td>
            <td><code>192.168.1.21</code></td>
            <td>-</td>
            <td>Web Services, with GitLab Runner support</td>
        </tr>
        <tr>
            <td>DB</td>
            <td>SQL Server 2022</td>
            <td>Windows Server 2022</td>
            <td><code>192.168.1.22</code></td>
            <td>-</td>
            <td>Database Server</td>
        </tr>
        <tr>
            <td>pihole</td>
            <td>Pi-Hole DNS Server</td>
            <td>Ubuntu 24.04 LTS</td>
            <td><code>192.168.1.30</code></td>
            <td>-</td>
            <td>DNS Resolver Server</td>
        </tr>
        <tr>
            <td>gitlab-devops</td>
            <td>GitLab EE</td>
            <td>Ubuntu 24.04 LTS</td>
            <td><code>192.168.1.35</code></td>
            <td>-</td>
            <td>GitLab EE instance</td>
        </tr>
        <tr>
            <td>gitlab-runner</td>
            <td>GitLab Runner, Docker CE</td>
            <td>Ubuntu 24.04 LTS</td>
            <td><code>192.168.1.40</code></td>
            <td>-</td>
            <td>GitLab Runner instance</td>
        </tr>
    </tbody>
</table>

## Hypervisor disk partitioning and disk-based computing for backup plans

### On the HV01 (running Windows Server 2022)

HV01 on Dell OptiPlex 7050 has two disks, both in good condition.

Since the system must also have a backup solution, I decided to do the following partition scheme:

- On the SSD: Since the SSD has fast I/O, it will become the primary disk, where it holds both the host operating system and all VM contents (incl. disks, configurations, and snapshots).
- On the HDD: It is much slower, but more reliable, so it becomes the secondary disk for holding backup contents, incl. backup of host machine, backup of VMs (VMs will send backups via SMB to the host).

### On the HV02 (running Ubuntu Server 24.04 LTS)

HV02 on Raspberry Pi 5 has 2 disks, both in good condition.

- On SSD: Since it stores both the backup content sent from HV01 over the network, it should be at least the size of the OptiPlex 7050 backup partition, and the rest for the OS and all VMs.
- On the SD card: It is much slower than the SSD, so it will become a backup solution for the operating system on Raspberry Pi 5.

### Calculation for disks, including for backup solution

From the above needs, I sum up into a quick calculation

<p>
    <style> 
        table, th, tr, td {
          border: 1px solid black;
          border-collapse: collapse;
        }
    </style>
    <table>
        <tr>
            <th>Host</th>
            <th>Disk Type</th>
            <th>Disk No.</th>
            <th>Partition</th>
            <th>Size</th>
            <th>Purpose</th>
            <th>Note</th>
        </tr>
        <tr>
            <td rowspan="6">HV01</td>
            <td rowspan="4">SSD</td>
            <td rowspan="4">0</td>
            <td>0</td>
            <td>100 MB</td>
            <td>Boot Partition (UEFI)</td>
            <td>This partition is automatically created through WinPE</td>
        </tr>
        <tr>
            <td>1</td>
            <td>30 GB</td>
            <td>Host Operating System (Windows Server 2022)</td>
            <td>This partition is automatically created through WinPE</td>
        </tr>
        <tr>
            <td>2</td>
            <td>737 MB</td>
            <td>Windows Recovery Environment</td>
            <td>This partition is automatically created through WinPE</td>
        </tr>
        <tr>
            <td>3</td>
            <td>208 GB</td>
            <td>Virtual machine contents</td>
            <td>-</td>
        </tr>
        <tr>
            <td rowspan="2">HDD</td>
            <td rowspan="2">1</td>
            <td>0</td>
            <td>231 GB</td>
            <td>Back up partition</td>
            <td>May need Data Deduplication configured to reduce size</td>
        </tr>
        <tr>
            <td>1</td>
            <td>67 GB</td>
            <td>Local Software Repository</td>
            <td>Store software such as Windows installation, SQL Server installation, and so on, for fast deployment</td>
        </tr>
        <tr>
            <td rowspan="5">HV02</td>
            <td rowspan="4">SSD</td>
            <td rowspan="4">0</td>
            <td>0</td>
            <td>530 MB</td>
            <td>Raspberry Pi boot partition</td>
            <td>-</td>
        </tr>
        <tr>
            <td>1</td>
            <td>51 GB</td>
            <td>Host Operating System (Ubuntu 24.04 LTS)</td>
            <td>This partition is locked at 4GB at the time of creation using Raspberry Pi Imager, but you can mount it on Ubuntu Desktop to resize the partition.</td>
        </tr>
        <tr>
            <td>2</td>
            <td>8 GB</td>
            <td>Swap Partition</td>
            <td>Useful when Ubuntu needs a place to free up less used memory space for essential applications</td>
        </tr>
        <tr>
            <td>3</td>
            <td>190 GB</td>
            <td>Backup partition over SMB</td>
            <td>This partition is <strong>for backup service via SMB from Windows Server</strong>. Host Ubuntu should not backup into this.</td>
        </tr>
        <tr>
            <td>SD Card</td>
            <td>1</td>
            <td>0</td>
            <td>64 GB</td>
            <td>Backup partition for local host</td>
            <td>This partition is <strong>for Ubuntu Server itself.</strong></td>
        </td>
    </table>
</p>

## What's next?

Looking for Day 1? [Here you go! ->](https://blog.anhvlt.io.vn/homelab-setup/day-1)
