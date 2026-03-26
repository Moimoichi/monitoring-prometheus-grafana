# Prometheus & Grafana System Monitoring

## Overview
This project demonstrates a full monitoring setup for Linux (Ubuntu) and Windows servers using Prometheus, Grafana, Node Exporter, and WMI Exporter.

## Features
- Prometheus server (port 9090)
- Node Exporter (Linux metrics, port 9100)
- WMI Exporter (Windows metrics, port 9182)
- Grafana dashboards (port 3000)
- Real-time system metrics collection
- Integration of multiple targets into Grafana


# System Monitoring with Prometheus & Grafana

This repository demonstrates how to set up system monitoring for **Linux** and **Windows** servers using **Prometheus**, **Grafana**, **Node Exporter**, and **WMI Exporter**.

---

## **Security Groups Configured on EC2 Instances**

| Port | Service |
|------|---------|
| 9090 | Prometheus Server |
| 9100 | Prometheus Node Exporter |
| 9182 | WMI Exporter |
| 3000 | Grafana |

---

## **1. Update System**

```bash
sudo apt update -y
sudo apt upgrade -y

#Create Prometheus System Users and Directories
sudo useradd --no-create-home --shell /bin/false prometheus
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus


#Download Prometheus and Navigate to /tmp and download Prometheus:

cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.31.1/prometheus-2.31.1.linux-amd64.tar.gz
tar -xvf prometheus-2.31.1.linux-amd64.tar.gz

#Install Prometheus

cd prometheus-2.31.1.linux-amd64
sudo mv console* /etc/prometheus
sudo mv prometheus.yml /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus
sudo mv prometheus /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
-- Check Verions prometheus --version


#Configure Prometheus

sudo nano /etc/prometheus/prometheus.yml

-> input the config and port
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]


#Create Prometheus Systemd Service

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

#Reload systemd and start service:

sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
sudo systemctl status prometheus



#Install grafana

wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
sudo apt update
sudo apt install grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server.service
sudo systemctl status grafana-server


#Add Prometheus as Grafana Data Source
Navigate: Settings → Data Sources → Add Data Source → Prometheus
URL: http://localhost:9090
Click Save & Test



























