#!/bin/bash

set -e

echo "==== Updating system ===="
apt update -y

echo "==== Creating users ===="
useradd --no-create-home --shell /bin/false prometheus || true
useradd --no-create-home --shell /bin/false node_exporter || true

echo "==== Creating directories ===="
mkdir -p /etc/prometheus
mkdir -p /var/lib/prometheus

chown prometheus:prometheus /var/lib/prometheus

echo "==== Installing Prometheus ===="
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.31.1/prometheus-2.31.1.linux-amd64.tar.gz
tar -xvf prometheus-*.tar.gz

cd prometheus-*.linux-amd64

mv console* /etc/prometheus
mv prometheus.yml /etc/prometheus

chown -R prometheus:prometheus /etc/prometheus

mv prometheus /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus

echo "==== Creating Prometheus service ===="
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file /etc/prometheus/prometheus.yml \
  --storage.tsdb.path /var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

echo "==== Installing Node Exporter ===="
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz
tar -xvf node_exporter-*.tar.gz

mv node_exporter-*.linux-amd64/node_exporter /usr/local/bin/

cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

echo "==== Installing Grafana ===="
apt install -y apt-transport-https software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

apt update
apt install -y grafana

systemctl enable grafana-server
systemctl start grafana-server

echo "==== Opening ports (UFW) ===="
ufw allow 9090/tcp || true
ufw allow 9100/tcp || true
ufw allow 3000/tcp || true

echo "==== DONE ===="
echo "Prometheus: http://<server-ip>:9090"
echo "Grafana: http://<server-ip>:3000 (admin/admin)"
