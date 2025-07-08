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

<img width="542" alt="image" src="https://github.com/user-attachments/assets/b3bb17a9-d23a-43e0-bc7d-2211cc1a6bb6" />

📄 Note: Refer to the [server.properties](https://github.com/OmkarShinde15/opensource-kafka-kraftmode/blob/main/multimode-kafka-kraftsetup/node1-server.properties) file version-controlled in this repository to align configurations across environments.

## Set the Node ID for Each Node in the cluster
To uniquely identify each other, each Node in the cluster must have a unique ID.

Edit the file: /opt/kafka/config/kraft/server.properties

Node 1: hostname1.com
```
The node id associated with this instance's roles
node.id=1
```

Node 2: hostname2.com
```
The node id associated with this instance's roles
node.id=2
```
Node 3: hostname3.com
```
The node id associated with this instance's roles
node.id=3
```
<img width="459" alt="image" src="https://github.com/user-attachments/assets/a77dcc98-f937-432b-aaf8-fa86db716902" />

📄 Note: Refer to the [server.properties](https://github.com/OmkarShinde15/opensource-kafka-kraftmode/blob/main/multimode-kafka-kraftsetup/node1-server.properties) file version-controlled in this repository to align configurations across environments.
## Specify a list of Controller Nodes in the Cluster

Next, you need to tell Kafka which nodes to use as controllers. This can be done by updating the value of the controller.quorum.voters parameter.

The controller is defined as **ID@ADDRESS:PORT**. If you have multiple controllers, define them in comma separate. The address could be resolvable hostname or IP address.

By default, Kafka expects to run as a single node cluster hence, the setting, controller.quorum.voters=1@localhost:9093.

Update this setting with the list of your nodes (Do this on all the nodes);

```
controller.quorum.voters=1@hostname1.com:9093,2@hostname2.com:9093,3@hostname3.com:9093
```
<img width="687" alt="image" src="https://github.com/user-attachments/assets/b5666171-d4dd-4652-9229-7b322d836110" />



Ensure the port used is not used by any other application/service already.

📄 Note: Refer to the [server.properties](https://github.com/OmkarShinde15/opensource-kafka-kraftmode/blob/main/multimode-kafka-kraftsetup/node1-server.properties) file version-controlled in this repository to align configurations across environments.

## Set the Name of the Brokers and Controllers Listener

Under the Socket Server Settings, you need to define the name of listener used for communication between brokers and used by the controllers. This is set to PLAINTEXT and CONTROLLER (respectively) by default;
```
inter.broker.listener.name=PLAINTEXT
...
controller.listener.names=CONTROLLER
```

<img width="774" alt="image" src="https://github.com/user-attachments/assets/d75d5e67-ebc2-4e4f-83c5-2aece870ab48" />


We will leave it with the default names! If you want, you can update it. These names will be used in other config settings.

📄 Note: Refer to the [server.properties](https://github.com/OmkarShinde15/opensource-kafka-kraftmode/blob/main/multimode-kafka-kraftsetup/node1-server.properties) file version-controlled in this repository to align configurations across environments.
