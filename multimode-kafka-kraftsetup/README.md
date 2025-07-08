## Install and Setup Kafka with KRaft on three Nodes

To install and setup Kafka, follow our guide below:

Easy Steps: [singlenode-kafka-kraft-setup](https://github.com/OmkarShinde15/opensource-kafka-kraftmode/tree/main/singlenode-kafka-kraft-setup)

You need to install and setup Kafka on three Nodes, Once installation done on all nodes follow below steps


## Setting up Three-Node Kafka KRaft Cluster

Assuming you have installed and Kafka with KRaft is running on three nodes, proceed to configure three-node KRaft Kafka cluster.

In our setup, we have three nodes:

| node.id | Node Hostname                | Node IP address | Node Role         |
|---------|------------------------------|------------------|--------------------|
| 1       | hostname1.com | 10.xxx.xx.101   | controller/broker |
| 2       | hostname2.com | 10.xxx.xx.102   | controller/broker |
| 3       | hostname3.com | 10.xxx.xx.103   | controller/broker |


Kafka KRaft Cluster Nodes
#### Define the role of Each Node in the cluster
In Kafka KRaft cluster, a node can either be a controller, a broker or can perform both roles.

 - A **controller** node coordinates the Kafka cluster and manages tracking of the event metadata. It also monitors the health and status of brokers, partitions, and replicas, leader election, partition reassignment, and handling broker failures.
 - A **broker** node acts as a data plane. It hosts and manages Kafka topics and partitions. It is responsible for storing and serving the messages published to Kafka topics. Brokers handle the actual data replication, storage, and retrieval in a distributed manner. Each broker in the cluster may have multiple partitions of different topics assigned to it.

In our setup, we will configure our cluster nodes to function both as controller and broker. You may want to separate them!

Thus, open the KRaft server.properties configuration file and navigate to Server Basics section on each node.
```
vim /opt/kafka/config/kraft/server.properties
```
By default, a node is assigned both roles:

<img width="884" alt="image" src="https://github.com/user-attachments/assets/00194391-bc03-4d9d-a64b-031c564b06e9" />


