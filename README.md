<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/d0670c3f-130a-450f-bf0c-c15206af8bbb" />Odoo 17 on Kubernetes — Self-Hosted Reference
A production-style reference for self-hosting Odoo 17 on a small,
self-managed Kubernetes cluster (built and tested on MicroK8s), with TLS,
an external PostgreSQL, NFS-backed shared filestore, and a full
Prometheus/Loki/Grafana observability stack.
This is a sanitized template, not a turnkey install. Every value that is
environment-specific is a placeholder you must replace. Search the tree for
REPLACE, example.com, and 10.0.0. to find them all.

Companion write-up (the lessons behind these manifests):
Self-Hosting Odoo on Kubernetes: The Hard Parts Nobody Documents.

Architecture

<img width="1536" height="1024" alt="odoo-setup" src="https://github.com/user-attachments/assets/8b202440-e6a3-4a4d-b077-a36cd39d4e78" />


Layout
PathWhat it isk8s/namespace.yamlodoo namespacek8s/cluster-issuer.yamlcert-manager Let's Encrypt issuer (set your email)k8s/configmap.yamlOdoo config template — list_db=False, hardened limitsk8s/deployment.yamlOdoo Deployment + init-container that renders config from Secretsk8s/service.yamlClusterIP service (8069 http, 8072 longpolling)k8s/ingress.yamlIngress + TLS (set your domain)k8s/pv.yaml / pvc.yamlNFS filestore (set your NFS server)k8s/pdb.yaml, quota.yamlPodDisruptionBudget, ResourceQuota/LimitRangek8s/networkpolicy.yamlStarting point only — see warning in the filek8s/monitoring.yamlLoki + Promtail + Prometheus + Grafana + exportersk8s/grafana-dashboard.yamlProvisioned Grafana dashboardDockerfileOdoo image with your custom addons (Community only by default).github/workflows/deploy-prod.ymlBuild → push to GHCR → deploy via self-hosted runnersecrets/*.example.yamlSecret shapes — real secrets are created with kubectl, never committed
Quick start

Replace all placeholders (REPLACE..., *.example.com, 10.0.0.*,
YOUR_GITHUB_USERNAME).
Create the secrets (see secrets/README.md).
Apply:

bash   kubectl apply -f k8s/namespace.yaml
   kubectl apply -f k8s/            # the rest

Point DNS at your ingress and wait for cert-manager to issue the cert.

Hard-won notes (why things are the way they are)

Secrets are rendered by an init container into an in-memory volume and
never passed as command-line args. Rotate the database and the K8s secret
together, then rollout restart.
The database manager is locked down at the app layer (list_db=False +
dbfilter), NOT via an ingress server-snippet. On ingress-nginx ≥ v1.12
the default annotations-risk-level: High silently rejects snippets and
prevents the whole ingress from rendering.
Grafana datasources carry explicit uids so the provisioned dashboard
resolves them; without that every panel shows "No data".
Prometheus scrapes the kubelet /metrics endpoint (not just cadvisor),
which is required for kubelet_volume_stats_* / PVC usage panels.
Loki runs as root on NFS because fsGroup is not honored over NFS.
Odoo is stateful and not inherently concurrency-safe. The rollout uses
maxSurge: 0 to avoid running two pods at once during a deploy. Raising
replicas/workers requires addons that are safe under concurrent writes.

Licensing
This template targets Odoo Community. Odoo Enterprise addons are
proprietary and must not be committed here. If you have an Enterprise
license, add them in your own private build (see the comment in Dockerfile).
Disclaimer
Provided as-is, for educational reference. Review and adapt before any
production use. No warranty.
