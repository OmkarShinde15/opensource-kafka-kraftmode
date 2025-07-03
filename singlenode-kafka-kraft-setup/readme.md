# 🧭 Kafka KRaft (No Zookeeper) Single Node Setup Guide

Apache Kafka has introduced **KRaft mode** (Kafka Raft Metadata mode) as a replacement for Zookeeper since version 2.8.0. As of version 3.3.0, it's production-ready for new clusters.

This guide walks you through installing and running **Kafka in KRaft mode** on a single node, ideal for testing or minimal production setups.

---

## 🚀 Prerequisites

- Linux-based system (Tested on CentOS/Ubuntu)
- Java 8 or higher installed
- Sudo/root access
- 2+ GB RAM
- Good internet access or internal repo if offline
- Static IP or resolvable hostname

---

## 🧱 Step 1: Prepare the Environment

```bash

# Create installation directory
sudo mkdir -p /opt/kafka
cd /opt/kafka

# Download Kafka binary
wget https://dlcdn.apache.org/kafka/3.9.0/kafka_2.13-3.9.0.tgz

# Extract Kafka
tar -xzf kafka_2.13-3.9.0.tgz --strip-components=1

```

## ⚙️ Step 2: Configure Kafka for KRaft

### 2.1 Update Default Log Directory

Kafka by default stores logs under `/tmp/kraft-combined-logs`. Update this to a persistent path like `/data/kafkadata/logs`.

```bash
sudo mkdir -p /data/kafkadata/logs

# Update the log directory in the configuration
sed -i 's|/tmp/kraft-combined-logs|/data/kafkadata/logs|' /opt/kafka/config/kraft/server.properties

```

### 2.2 Format Kafka Storage Directory with Cluster ID
Kafka in KRaft mode requires a Cluster ID to initialize the log directory for metadata storage.

Step 1: Generate a Cluster ID
```bash
/opt/kafka/bin/kafka-storage.sh random-uuid
```

Sample output:
```
URaeRekUQAyy8wLMNX2Q-w
```
