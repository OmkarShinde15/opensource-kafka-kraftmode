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


### 2.3 Set Unique Node ID and Hostname

Edit the file: /opt/kafka/config/kraft/server.properties

Replace/add:
```
# The node id associated with this instance's roles
node.id=1

# The connect string for the controller quorum
controller.quorum.voters=1@hostname:9093
listeners=PLAINTEXT://hostname:9092,CONTROLLER://hostname:9093
log.dirs=/data/kafkadata/logs
```
Take reference from server.properties stored in repository folder 


## 🔐 Step 3: Generate and Format Cluster ID
Kafka in KRaft mode requires a Cluster ID to initialize the log directory for metadata storage.

### 3.1 Generate a Cluster ID
```bash
/opt/kafka/bin/kafka-storage.sh random-uuid
```

Sample output:
```
URaeRekUQAyy8wLMNX2Q-w
```

Save this UUID — you will use the same cluster ID on all nodes in a multi-node setup.

### 3.2 Format the Storage Directory

Now format the Kafka storage directory with the generated Cluster ID:
```
/opt/kafka/bin/kafka-storage.sh format -t URaeRekUQAyy8wLMNX2Q-w -c /opt/kafka/config/kraft/server.properties
```
Expected output:
```
Formatting /data/kafkadata/logs with metadata.version X.Y-Z
```

After this step, Kafka metadata files will be initialized under the logs directory:
```
ls -1 /data/kafkadata/logs/
```

You should see:
```
bootstrap.checkpoint
meta.properties
```

