# 🐳 HomeLab Server & Services

![Status](https://img.shields.io/badge/Status-Production-success)
![OS](<https://img.shields.io/badge/OS-CachyOS_(Arch)-blue>)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![Security](https://img.shields.io/badge/Security-CrowdSec_%2B_VoidAuth-red)

> **"A modular, automated homelab, running a media server on Arch Linux (CachyOS)"**

> **📚 FULL DOCUMENTATION:** Detailed deployment guides, network architecture and security policies are hosted on the live wiki at **[docs.sfhomelab.com](https://docs.sfhomelab.com)**.

This repository houses the Docker Compose stacks, environment templates and some config files, where it will be relatively easy for me to clone/pull when deploying similar stacks to a new machine.

This is put together in Feb 2026, for the future me when I am ready to move what I have to an `always-on` homelab/server that I am putting together. And if it somehow helps others on their own journey, its awesome too!

---

## Architecture Setup

### Node 1: Home Server (Internal App & Vault)

Located in my home. Handles heavy compute, media storage, media server transcoding and the automated P2P download stack.

| Component | Detail | 
| :--- | :--- | 
| **OS** | CachyOS (Arch Linux) | 
| **CPU / RAM** | AMD Ryzen 5 7600X / 32GB DDR5 | 
| **GPU** | Radeon RX 5600 XT | 
| **Storage** | 2x 1TB NVMe + 2 x 2TB HDDs MergerFS Vault + 500GB Crucial SSD as "Scratch" Disk | 
| **Network** | Marvell 10GbE + Firewalld VLAN Isolation + Tailscale | 

### Node 2: VPS (The Edge Gateway)

OVH SG Datacentre. Handles public ingress, identity, notifications and container management/orchestration.

| Component | Detail | 
| :--- | :--- | 
| **OS** | Ubuntu 24.04 (VPS) | 
| **CPU / RAM** | 4 vCPU / 8GB RAM | 
| **Network** | High-Bandwidth Public Edge + Tailscale | 
| **Core Services** | Caddy (Proxy), VoidAuth (SSO), Komodo (Orchestration), MkDocs, Gotify |

## Architecture Highlights for Media Server

### The "Two-Zone" Security Model
We bypass the default Docker bridge to enforce isolation.

* **Zone 1:** `172.20.0.0/24`. Static Docker IPs/Internal apps talk here.
* **Zone 2 (VPN Bubble):** P2P clients (qBit/Transmission) have **zero** IP address. They utilize `network_mode: service:gluetun`, routing 100% of traffic through AirVPN (WireGuard)

### Scratch Disk to Vault
* **Concept:** Downloads and unpacks hit a dedicated 500GB SSD to absorb heavy random I/O and prevent mechanical drive thrashing.
* **Result:** Finalized media is sequentially migrated to the unified 4TB MergerFS HDD Vault for long-term, buffer-free storage.

### Zero-Touch Automation
* **Pipeline:** Seerr (Request) → Radarr (Monitored) → Prowlarr (Search) → Gluetun-Qbit (Download) → Radarr (Import) | Bazaarr (Substitle) → Jellyfin (Stream) → Gotify (Notify)
* **Result:** A fully automated experience where content appears automatically after requesting.

### Defense-in-Depth
1.  **Kernel:** `Firewalld` drops all Docker-to-LAN traffic (Software VLAN).
2.  **Ingress:** Caddy handles SSL & GeoIP blocking (Singapore Only).
3.  **Behavior:** CrowdSec bans IPs showing aggressive behavior (brute force, scanners).
4.  **Identity:** VoidAuth enforces authentication for selected publicly exposed services/containers

---

## Tech Stack / Tools

| Logo | Name | Description |
| :--- | :--- | :--- |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/cachyos-linux.png" alt="CachyOS" width='30'/> | **[CachyOS](https://cachyos.org/)** | **Base OS.** An Arch Linux-based distribution |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/docker.png" alt="Docker" width='30'/> | **[Docker](https://www.docker.com/)** | **Runtime.** Containerization engine for isolating application services. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/caddy.png" alt="Caddy" width='30'/> | **[Caddy](https://caddyserver.com/)** | **Ingress.** Secure reverse proxy with automatic HTTPS and GeoIP filtering. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/crowdsec.png" alt="CrowdSec" width='30'/> | **[CrowdSec](https://www.crowdsec.net/)** | **Security.** Collaborative IPS detecting and blocking aggressive IP behaviors. |
| <img src="https://raw.githubusercontent.com/voidauth/voidauth/refs/heads/main/docs/logo.svg" alt="VoidAuth" width='30'/> | **[VoidAuth](https://github.com/void-auth/void)** | **Identity.** Lightweight OIDC provider handling Single Sign-On (SSO). |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/gluetun.png" alt="Gluetun" width='30'/> | **[Gluetun](https://github.com/qdm12/gluetun)** | **VPN Tunnel.** AirVPN (WireGuard) client acting as a sidecar for secure downloads. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/tailscale.png" alt="Tailscale" width='30'/> | **[Tailscale](https://tailscale.com/)** | **Mesh Network.** Remote access and Intra-Server Mesh Management. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/jellyfin.png" alt="Jellyfin" width='30'/> | **[Jellyfin](https://jellyfin.org/)** | **Media Server.** Streaming server. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/seerr.png" alt="Seerr" width='30'/> | **[Seerr](https://github.com/seerr-team/seerr)** | **Requests.** Frontend for automated content discovery. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/radarr.png" alt="Radarr" width='30'/> | **[Radarr](https://radarr.video/)** | **Automation.** Movie collection manager and downloader integration. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/sonarr.png" alt="Sonarr" width='30'/> | **[Sonarr](https://sonarr.tv/)** | **Automation.** TV Series management and calendar automation. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/profilarr.png" alt="Profilarr" width='30'/> | **[Profilarr](https://github.com/Dictionarry-Hub/profilarr)** | **Management.** Synchronizes quality profiles across *Arr applications. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/prowlarr.png" alt="Prowlarr" width='30'/> | **[Prowlarr](https://prowlarr.com/)** | **Indexers.** Centralized management for Torrent trackers. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/flaresolverr.png" alt="FlareSolverr" width='30'/> | **[FlareSolverr](https://github.com/FlareSolverr/FlareSolverr)** | **Proxy.** Solves Cloudflare challenges to allow Prowlarr indexer access. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/qbittorrent.png" alt="qBittorrent" width='30'/> | **[qBittorrent](https://www.qbittorrent.org/)** | **Downloader.** BitTorrent client routed through VPN. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/transmission.png" alt="transmission" width='30'/> | **[Transmission](https://transmissionbt.com/)** | **Downloader.** BitTorrent client routed through VPN. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/beszel.png" alt="Beszel" width='20'/> | **[Beszel](https://github.com/henrygd/beszel)** | **Monitoring.** Lightweight agent tracking LVM, CPU, and Docker metrics. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/dozzle.png" alt="Dozzle" width='30'/> | **[Dozzle](https://github.com/amir20/dozzle)** | **Monitoring.** WebUI to monitor Docker logs. |> | **[Speedtest](https://github.com/alexjustesen/speedtest-tracker)** | **Monitoring.** Automated internet bandwidth and latency tracking. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/homepage.png" alt="Homepage" width='30'/> | **[Homepage](https://gethomepage.dev/)** | **Dashboard.** Central start page with live service widgets. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/kopia.png" alt="Kopia" width='30'/> | **[Kopia](https://kopia.io/)** | **Backup.** Dedup backups to Cloudflare R2. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/goaccess.png" alt="GoAccess" width='30'/> | **[GoAccess](https://goaccess.io/)** | **Analytics.** Real-time visual web log analyzer for Caddy. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/gotify.png" alt="Gotify" width='30'/> | **[Gotify](https://github.com/gotify)** | **Notifications** WebUI and Backend Server Notification tool. |
| <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/cloudflare.png" alt="Cloudflare" width='30'/> | **[Cloudflare](https://www.cloudflare.com/)** | **Network.** DNS management, DDNS updates, and Object Storage (R2). |

</br>

**📚 FULL DOCUMENTATION:** Detailed deployment guides, network architecture, and security policies are hosted on the live wiki at **[docs.sfhomelab.com](https://docs.sfhomelab.com)**.

## 📸 Gallery

![Homepage Screenshot](./assets/homepage-dashboard1.png)

![GoAccess Screenshot](./assets/goaccess-dashboard.png)

![VoidAuth Screenshot](./assets/voidauth-landingpage.png)

![Jellyfin Screenshot](./assets/jellyfin1.png)

![Seerr Screenshot](./assets/seerr1.png)

![Beszel Screenshot](./assets/beszel1.png)

