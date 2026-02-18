# proxmox-prod / k3s

> **Work in progress.** This stack is an experimental alternative placement of the AI stack containers, intended for eventual migration to a k3s-managed environment.

Currently provisions the same three containers as `ai-stack` (Open WebUI, SearXNG, n8n) but deployed to different Proxmox nodes. The inventory is written to the shared `ai-stack` inventory path.

For the stable, production-ready AI stack see [`../ai-stack/`](../ai-stack/).
