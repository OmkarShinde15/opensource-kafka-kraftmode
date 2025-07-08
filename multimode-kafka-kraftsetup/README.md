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

## Set the Socket Server Address

Next, you need to define address the socket server listens on.

By default, it is set to listen on all interfaces on port 9092/tcp (Broker listener) and port 9093/tcp (controller listener), listeners=PLAINTEXT://:9092,CONTROLLER://:9093

We will update this to set specific interface:

Node 1:
```
#listeners=PLAINTEXT://:9092,CONTROLLER://:9093
listeners=PLAINTEXT://hostname1.com:9092,CONTROLLER://hostname1.com:9093
```
Node 2:
```
#listeners=PLAINTEXT://:9092,CONTROLLER://:9093
listeners=PLAINTEXT://hostname2.com:9092,CONTROLLER://hostname2.com:9093
```
Node 3:
```
#listeners=PLAINTEXT://:9092,CONTROLLER://:9093
listeners=PLAINTEXT://hostname3.com:9092,CONTROLLER://hostname3.com:9093
```

<img width="963" alt="image" src="https://github.com/user-attachments/assets/0f6b6cf7-f878-4489-99a3-a5ef1703efe4" />


📄 Note: Refer to the [server.properties](https://github.com/OmkarShinde15/opensource-kafka-kraftmode/blob/main/multimode-kafka-kraftsetup/node1-server.properties) file version-controlled in this repository to align configurations across environments.


## Update the Broker Advertised Listener Address

If you didn’t do this already, you need to update the broker listener address that is advised to the clients.

By default set to localhost.

Node 1
```
#advertised.listeners=PLAINTEXT://localhost:9092
advertised.listeners=PLAINTEXT://hostname1.com:9092
```
Node 2;
```
#advertised.listeners=PLAINTEXT://localhost:9092
advertised.listeners=PLAINTEXT://hostname2.com:9092
```
Node 3
```
#advertised.listeners=PLAINTEXT://localhost:9092
advertised.listeners=PLAINTEXT://hostname3.com:9092
```
<img width="690" alt="image" src="https://github.com/user-attachments/assets/d92bd1d7-1e3b-4b0a-853d-973ec23b510a" />

📄 Note: Refer to the [server.properties](https://github.com/OmkarShinde15/opensource-kafka-kraftmode/blob/main/multimode-kafka-kraftsetup/node1-server.properties) file version-controlled in this repository to align configurations across environments.


## Define the Number of Log Partitions per Topic

More partitions allow greater parallelism for consumption, but this will also result in more files across the brokers.

The default is set to 1. Ensure that you use a number that is at least divisible by the number of nodes in the cluster. Let’s use 6 in our case.
```
#num.partitions=1
num.partitions=6
```
In the very basic setup, those are just the only configs we can make. Save and exit the file.

## Open Controller/Broker Ports on Firewall

Ensure that these ports, 9093/tcp ( between controller nodes) and 9092/tcp (between brokers and clients) are opened on firewall.

## Update the Cluster ID

When you setup KRaft Kafka, there is a step that you had to format Kafka logs directory to KRaft format. In the process, a random cluster ID (**cluster.id**) is generated. This information, is stored in the meta.properties in the logs directory. In order to avoid unexpected error due to INCONSISTENT_CLUSTER_ID in VOTE response, you need to edit the meta.properties file and change the ID to be same across all nodes.


Node 1:
```
cluster.id=URaeRekUQAyy8wLMNX2Q-w
version=1
directory.id=AclUncZ3rKYYP5eqwmZSTg
node.id=1
```

Node 2:
```
cluster.id=URaeRekUQAyy8wLMNX2Q-w
version=1
directory.id=BxtVp9D7nLReX6QsjdWRLg
node.id=2
```

Node 3:
```
cluster.id=CqzRmHD2uNGeT1MfkeAJHg
version=1
directory.id=CqzRmHD2uNGeT1MfkeAJHg
node.id=3
```

```
Notes: 
 - **cluster.id** should be same on all 3 nodes, which is the UUID we generated and used for formatting "log.dir=/data/kafkadata/logs" on all 3 nodes.
 - **node.id** inside log.dir/meta.properties  should be similar to **node.id** /opt/kafka/config/kraft/server.properties.
 - **directory.id** should be different on all 3 nodes, which is generated during formatting
```

## Restart Kafka Service

Restart Kafka service from node 1 -> node 2 -> node 3 to apply the changes.
```
systemctl restart kafka
```
## Check the service:
```
systemctl status kafka
```

## Check the Kafka KRaft cluster ports

ss -altnp | grep :90

<img width="1329" alt="image" src="https://github.com/user-attachments/assets/14e19046-1fca-4740-976e-801029f7bcec" />

## Now you can create,list,produce,consumer from any node
```
/opt/kafka/bin/kafka-topics.sh --bootstrap-server hostname1.com:9092,hostname2.com:9092,hostname3.com:9092 --list


/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server hostname1.com:9092,hostname2.com:9092,hostname3.com:9092 --topic kafka-topic-test --from-beginning
```
