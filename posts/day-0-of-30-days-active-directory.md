---
title: Setting up a new Home Lab - Day 0
date: 2025-11-01
permalink: /homelab-setup/day-0
---

# Day 0

This is the day zero of **TheFlightSims Challenge** - A 14-day challenge to set up a full-stack enterprise network at home, with Microsoft Active Directory, DevOps, and so on.

## What am I having?

To be honest, I only have

- A Raspberry Pi 5 (8GB of RAM, 256GB of SSD, and 64GB of SD Card)
- A Dell OptiPlex 7050 (16GB of RAM, 256GB of SSD, and 256GB of HDD)

Additionally, I also have the following equipment:

- Two safety sockets (3x sockets and 8x sockets) - as extension and for electronic safety
- A Wifi router (TP-Link WR820N) - as a network router and wireless modem
- A non-configurable switch (TP-Link) - for network physical segmentation
- 2 external cooling fans (one for my Raspberry Pi, another to make the air cycle better for OptiPlex 7050)

## Hosting method

Firstly, two servers may be good enough for a local home network. However, as I want to make sure it is also a replication of standard networking in most enterprises, I think it is better to either:

- Buy new devices, sockets, and invest in a new cooling system; or...
- Force both servers to run a bare metal hypervisor

And, as you expected, I chose the second option.

Why? Because:

1. It is cheaper
2. Manageability. Instead of managing each physical server with different roles, services, and applications individually, we can manage all server as VMs on a single physical hypervisor host.
3. Scalability. Running a hypervisor means your servers as virtual machines (VMs) able to scale based on demand.

## Planning Hypervisor host and VMs

### Planning on services and where to host

Since all servers are running bare metal hypervisors, I decided to run those servers with hypervisor software

- Raspberry Pi 5 will run LXD as the management layer (I know LXD is not a bare metal hypervisor, but it has features as most bare metal hypervisors do), running on top of Ubuntu Server 24.04 LTS.
- Dell OptiPlex 7050 will run Windows Server 2022 with Hyper-V role enabled. It will host Windows Server VMs, since Active Directory is the core service of my home network, and it runs best on Windows Server VMs hosted on Hyper-V.

> *Note that the Windows Server edition must be Datacenter, because the Standard Edition only supports up to 5 VMs running*

Moreover, some roles and services must be installed for manageability, security, or backup.

- File Server with SMB enabled for backup over the network. **On Windows Server**, it also needs data deduplication, enhanced storage, storage migration services, and storage replicas. **On Ubuntu Server**, it is configured with Samba.
- Shell service: **On Windows Server**, it is Windows Remote Management (WinRM) over PowerShell and Windows Management Instrumentation (WMI). However, I prefer using WinRM with PowerShell over WMI, since WMI is better for complex scripting, with built-in .NET Framework 4.8. **On Ubuntu Server**, it is Secure Shell (`sshd`). It may need to disable access using a password and only authenticate with a certificate.
- Manage via web interface: **On Windows Server**, it is Windows Admin Center. **On Ubuntu Server**, it is Cockpit
- Additionally, Windows Server will have to install those features for further system investigation and backup: Microsoft Defender Antivirus, Setup and Boot Event Collection, System Data Archiver, System Insights, and Windows Server Backup

### Roles and Services running on VMs

For servers as VMs running on Windows Server Hyper-V:

1. Two domain controllers: Active Directory Domain Services (AD DS), Active Directory Certificate Services (AD CS), and DNS Server
2. Authentication server: Active Directory Federation Services (AD FS), Network Policy and Access Services (NPS), and all RSAT features
3. Database server: SQL Server 2022
4. Web Server: Web Service (IIS)

For the server as VMs running on LXD:

1. The exit relay DNS server: Pi-Hole Ad-blocker
2. DevOps server: GitLab EE
3. DevOps Runner: GitLab Runner, Docker CE

## Networking

### Local Domain Names

Since this is only for home network, it is recommended but not required that the TLDs of the domain must not be published or used publicly to avoid conflict between local network and the rest of the Internet. For example, avoid using `.com` or `.net` domains. Also, avoid using the `.local` domain for local network (mDNS problem).

To prevent conflicts, best practice is look up for [registered TLD on IANA](https://data.iana.org/TLD/tlds-alpha-by-domain.txt)

In this case, I will use the domain `workshop.neko`, since no one has ever registered it.

Alternatively, `web.neko` is used for web deployments. (e.g. IIS host or GitLab Pages)

### Private IPv4 address map

I expect that there are under 100 clients will join into my network, I will use the `192.168.1.0/24` - which has in total of 254 IP addresses

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
