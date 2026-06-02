Odoo 17 on Kubernetes — Self-Hosted Reference
A production-style reference for self-hosting Odoo 17 on a small, self-managed Kubernetes cluster (built and tested on MicroK8s) — complete with TLS, external PostgreSQL, NFS-backed shared filestore, and a full Prometheus/Loki/Grafana observability stack.

✨ This is a sanitized template, not a turnkey install. Every environment-specific value is a placeholder you must replace. Search the tree for REPLACE, example.com, and 10.0.0. to find them all.

📖 Companion write-up: Self-Hosting Odoo on Kubernetes: The Hard Parts Nobody Documents

🏗️ Architecture

<img width="1536" height="1024" alt="odoo-setup" src="https://github.com/user-attachments/assets/8b202440-e6a3-4a4d-b077-a36cd39d4e78" />

## 📂 Layout  

| Path                                | What it is                                                                 |
|-------------------------------------|----------------------------------------------------------------------------|
| `k8s/namespace.yaml`                | Odoo namespace                                                             |
| `k8s/cluster-issuer.yaml`           | cert-manager Let's Encrypt issuer (set your email)                         |
| `k8s/configmap.yaml`                | Odoo config template — `list_db=False`, hardened limits                    |
| `k8s/deployment.yaml`               | Odoo Deployment + init-container that renders config from Secrets          |
| `k8s/service.yaml`                  | ClusterIP service (8069 http, 8072 longpolling)                            |
| `k8s/ingress.yaml`                  | Ingress + TLS (set your domain)                                            |
| `k8s/pv.yaml` / `pvc.yaml`          | NFS filestore (set your NFS server)                                        |
| `k8s/pdb.yaml`, `quota.yaml`        | PodDisruptionBudget, ResourceQuota/LimitRange                              |
| `k8s/networkpolicy.yaml`            | Starting point only — ⚠️ see warning in the file                           |
| `k8s/monitoring.yaml`               | Loki + Promtail + Prometheus + Grafana + exporters                         |
| `k8s/grafana-dashboard.yaml`        | Provisioned Grafana dashboard                                              |
| `Dockerfile`                        | Odoo image with your custom addons (Community only by default)             |
| `.github/workflows/deploy-prod.yml` | Build → push to GHCR → deploy via self-hosted runners              |
| `secrets/*.example.yaml`            | Secret shapes — real secrets created with kubectl, never committed         |



⚡ Quick Start
🔧 Replace all placeholders (REPLACE..., *.example.com, 10.0.0.*, YOUR_GITHUB_USERNAME).

🔑 Create the secrets (see secrets/README.md).

🚀 Apply:

bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/            # the rest
🌐 Point DNS at your ingress and wait for cert-manager to issue the cert.

📝 Hard-Won Notes (a.k.a. battle scars)
🔒 Secrets are rendered by an init container into an in-memory volume — never passed as command-line args. Rotate DB + K8s secret together, then rollout restart.

🛡️ Database manager locked at app layer (list_db=False + dbfilter), not via ingress snippets.

📊 Grafana datasources carry explicit UIDs so dashboards resolve correctly.

📈 Prometheus scrapes kubelet /metrics (not just cadvisor) — needed for PVC usage panels.

🗄️ Loki runs as root on NFS (fsGroup not honored).

⚠️ Odoo is stateful & not concurrency-safe. Rollout uses maxSurge: 0 to avoid double pods. Scaling requires concurrency-safe addons.

📜 Licensing
This template targets Odoo Community.
Odoo Enterprise addons are proprietary — do not commit them here. If you have an Enterprise license, add them in your own private build (see Dockerfile comment).

⚠️ Disclaimer
Provided as-is, for educational reference.
Review and adapt before any production use.
No warranty.
