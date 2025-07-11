# 🧭 Kafka KRaft (No Zookeeper) Single Node Setup Guide

Apache Kafka has introduced **KRaft mode** (Kafka Raft Metadata mode) as a replacement for Zookeeper since version 2.8.0. As of version 3.3.0, it's production-ready for new clusters.

This guide walks you through installing and running **Kafka in KRaft mode** on a single node, ideal for testing or minimal production setups.

---

## 📚 Resources

 - [Kafka KRaft Overview](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html#kraft-overview)
 - [Kafka Downloads](https://kafka.apache.org/downloads)

## 🚀 Prerequisites

 - Ensure you assign each node enough disk space depending on the volume of the data you are expecting to store based on your data retention policies
 - Ensure you have a reliable network connection between your cluster nodes
 - Ensure that the CPU and RAM assigned to your cluster brokers can handle the load related to the data streaming.
 - Ensure you have an odd number of nodes in the cluster to avoid the split-brain scenario(incase of multinode setup).
 - Install Java 8+

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

#### Kafka Data Logs (i.e., actual Kafka topic data)

Kafka by default stores logs under `/tmp/kraft-combined-logs`. Update this to a persistent path like `/data/kafkadata`.

```bash
sudo mkdir -p /data/kafkadata

# Update the log directory in the configuration
sed -i 's|/tmp/kraft-combined-logs|/data/kafkadata|' /opt/kafka/config/kraft/server.properties

```

 - This is where Kafka stores messages (data) for topics and partitions.

 - The data here includes:

   - Topic partition directories (e.g., __consumer_offsets-12, mytopic-0)

So this is not the service log; it's the persistent message data Kafka serves to producers/consumers.

#### Kafka Service Logs (logging for broker activities)

These are logs generated by the Kafka server process (e.g., startup info, errors, GC activity).

Typically defined in the log4j.properties or log4j2.properties file: /opt/kafka/config/log4j.properties

```
log4j.appender.kafkaAppender.File=${kafka.logs.dir}/server.log
```

### 2.3 Set Unique Node ID and Hostname

Edit the file: /opt/kafka/config/kraft/server.properties

Replace/add:
```
# Unique node ID for this broker instance
node.id=1

# Controller quorum string (format: nodeId@hostname:port)
controller.quorum.voters=1@hostname:9093

# Listeners for client and controller communication
listeners=PLAINTEXT://hostname:9092,CONTROLLER://hostname:9093

# Directory where Kafka stores log data
log.dirs=/data/kafkadata

```
Kafka controls how long it retains topic log segments through several parameters. One key setting is:
```
log.retention.hours=168
```
This default value retains log data for 7 days.

You can adjust this based on your use case and available storage. Additional retention parameters you may consider:

 - log.retention.minutes
 - log.retention.ms
 - log.retention.bytes

These settings influence disk storage and, indirectly, memory consumption depending on topic size and broker activity.

To update retention settings, edit the same file: /opt/kafka/config/kraft/server.properties

📄 Note: Refer to the [server.properties](https://github.com/OmkarShinde15/opensource-kafka-kraftmode/blob/main/singlenode-kafka-kraft-setup/server.properties) file version-controlled in this repository to align configurations across environments.

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
Content of meta.properties looks like this

```
#Mon Mar 17 15:51:41 IST 2025
cluster.id=URaeRekUQAyy8wLMNX2Q-w
version=1
directory.id=AclUncZ3rKYYP5eqwmZSTg
node.id=1
```
Here's a quick summary of the contents of Kafka's meta.properties file:

Field	Description
 - cluster.id	Unique ID for the entire Kafka cluster (same across all brokers), You provide it during kafka-storage.sh format using the -t option.
 - node.id	Unique ID for this specific broker, defined in server.properties.
 - directory.id	Unique ID for this specific log directory (generated during formatting).
 - version	Metadata format version (typically 1 for Kafka KRaft mode).

📝 Purpose: Ensures that each broker is correctly linked to the cluster and its own log data. Essential for KRaft-based Kafka clusters.

## 📈 Step 4: Configure Kafka Heap Size (Optional)

To ensure optimal performance and stability of Kafka, you need to configure the heap size appropriately. This refers to the memory allocated to the Java Virtual Machine (JVM) running Kafka.

This is set to 1G by default:
```
grep KAFKA_HEAP_OPTS= /opt/kafka/bin/kafka-server-start.sh
```
Update the heap size as per your system resources and expected load.
In my case, I have set:
```
KAFKA_HEAP_OPTS="-Xmx8G -Xms6G"
```
 - -Xms6G: Initial JVM heap size is 6 GB

 - -Xmx8G: Maximum JVM heap size is 8 GB

Depending on the size of the RAM allocated to your server, update this accordingly. Ensure that the allocated heap size is sufficient to handle the expected message traffic and the size of the data being processed.

## 🖥️ Step 5: Create systemd Service

### 5.1 Set Permissions
```
useradd kafka
chown -R kafka:kafka /opt/kafka /data/kafkadata
```

### 5.2 Create systemd Unit File
```
vi /etc/systemd/system/kafka.service

Paste:
[Unit]
Description=Apache Kafka KRaft
After=network.target

[Service]
Type=simple
User=kafka
Group=kafka
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

### 5.3 Start Kafka
```
systemctl daemon-reload
systemctl start kafka
systemctl enable kafka
systemctl status kafka
```

## 🧪 Step 6: Test Kafka

### 6.1 Create a Topic
```
/opt/kafka/bin/kafka-topics.sh --create --topic kafka-topic-test --bootstrap-server hostname:9092
```

### 6.2 Produce Messages
```
/opt/kafka/bin/kafka-console-producer.sh --bootstrap-server hostname:9092 --topic kafka-topic-test
```

You’ll get a prompt. Type your message and hit ENTER:
```
>Hello Kafka, this is a test message
```
### 6.3 Consume Messages

To read all messages:
```
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server hostname:9092 --topic kafka-topic-test --from-beginning

```

### 6.4 Delete Kafka Topics
```
/opt/kafka/bin/kafka-topics.sh --bootstrap-server hostname:9092 --delete --topic kafka-topic-test
```

## ✅ Done!
You now have a single-node Kafka cluster using KRaft mode running without ZooKeeper.

To set up a multi-node Kafka KRaft cluster, follow next folder in this repository - [multinode-kafka-kraft-cluster](https://github.com/OmkarShinde15/opensource-kafka-kraftmode/tree/main/multimode-kafka-kraftsetup)





