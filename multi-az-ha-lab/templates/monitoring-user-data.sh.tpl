#!/bin/bash
set -euxo pipefail

apt-get update -y
apt-get install -y docker.io
systemctl enable --now docker

mkdir -p /opt/prom /opt/grafana-data
chown -R 472:472 /opt/grafana-data

cat > /opt/prom/prometheus.yml <<'PROM'
${prometheus_config}
PROM

docker run -d --name prometheus --restart always \
  --network host \
  -v /opt/prom/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus:v2.54.1

docker run -d --name grafana --restart always \
  -p 3000:3000 \
  -v /opt/grafana-data:/var/lib/grafana \
  -e GF_SECURITY_ADMIN_PASSWORD='${grafana_password}' \
  -e GF_USERS_ALLOW_SIGN_UP=false \
  grafana/grafana:11.2.0
