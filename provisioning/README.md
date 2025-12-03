# Provisioning

This directory contains Grafana provisioning configurations used by Kubernetes deployments.

## Structure

```
provisioning/
├── dashboards/          # Grafana dashboard JSON files
│   ├── jvm-micrometer.json       # JVM metrics dashboard
│   └── postgres-dashboard.json   # PostgreSQL database dashboard
└── datasources/         # Grafana datasource configurations
    └── datasource.yml            # Prometheus & PostgreSQL datasources
```

## Usage

These files are mounted into Grafana pods via Kubernetes ConfigMaps:

- **Dashboards**: Created as ConfigMap `grafana-dashboards` in `run.sh`
- **Datasources**: Embedded in `k8s/grafana.yaml` ConfigMap

## Editing

1. **To modify dashboards**: Edit the JSON files in `dashboards/`
2. **To modify datasources**: Edit `datasource.yml` (for reference) or `k8s/grafana.yaml` (actual K8s config)
3. **Apply changes**: Run `./run.sh` to recreate ConfigMaps and restart Grafana
