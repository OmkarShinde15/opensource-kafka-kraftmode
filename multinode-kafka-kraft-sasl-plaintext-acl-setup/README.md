## Pre-Requisite : 3 node PLAINTEXT Kakfa Kraft Cluster

Document for the same - [Install 3 node Apache Kafka Kraft Cluster] (https://github.com/OmkarShinde15/opensource-kafka-kraftmode/tree/main/multimode-kafka-kraftsetup)


## Setting up Three-Node Kafka KRaft Cluster

Assuming you have installed and Kafka with KRaft is running on three nodes, proceed to configure three-node KRaft Kafka cluster.

In our setup, we have three nodes:

| node.id | Node Hostname                | Node IP address | Node Role         |
|---------|------------------------------|------------------|--------------------|
| 1       | hostname1.com | 10.xxx.xx.101   | controller/broker |
| 2       | hostname2.com | 10.xxx.xx.102   | controller/broker |
| 3       | hostname3.com | 10.xxx.xx.103   | controller/broker |


## Add below parameters in your "/pathto/kafka/config/kraft/server.properties" on all nodes

#### Below parameters are regarding SASL authentication , replace PLAINTEXT with SASL_PLAINTEXT

```
listeners=SASL_PLAINTEXT://nvmbddvv008845.bss.dev.jio.com:9092,CONTROLLER://nvmbddvv008845.bss.dev.jio.com:9093
advertised.listeners=SASL_PLAINTEXT://nvmbddvv008845.bss.dev.jio.com:9092
controller.listener.names=CONTROLLER
listener.security.protocol.map=CONTROLLER:SASL_PLAINTEXT,PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL

security.inter.broker.protocol=SASL_PLAINTEXT
sasl.enabled.mechanisms=PLAIN
sasl.mechanism.controller.protocol=PLAIN
sasl.mechanism.inter.broker.protocol=PLAIN
```

#### Below parameters are regarding ACL authorization


```
######### ACL #######

authorizer.class.name=org.apache.kafka.metadata.authorizer.StandardAuthorizer
super.users=User:admin
allow.everyone.if.no.acl.found=false
```

📄 Note: Refer to the [server.properties](https://github.com/OmkarShinde15/opensource-kafka-kraftmode/blob/main/multinode-kafka-kraft-sasl-plaintext-acl-setup/server.properties) file version-controlled in this repository to align configurations across environments.

## Step to use SASL and ACL in kafka

## Lets create users

Create file named "pathto/kafka/config/kraft/jaas.config" and write below entry, here we have create 3 user admin, usera, userb
```
KafkaServer {
 org.apache.kafka.common.security.plain.PlainLoginModule required
 username="admin"
 password="admin"
 user_admin="admin"
 user_usera="usera"
 user_userb="userb";
};
```

### Pass this file as a KAFKA_OPT variable inside kafka.service file

vi cat /etc/systemd/system/kafka.service
```
[Unit]
Description=Apache Kafka
Requires=network.target
After=network.target

[Service]
Type=simple
User=kafka
Group=kafka
Environment="KAFKA_OPTS=-Djava.security.auth.login.config=/opt/kafka/config/kraft/jaas.config"
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
Restart=on-failure

[Install]
WantedBy=default.target
```


### Lets create config file for each user as well and store it here "pathto/kafka/config/kraft"

```
vi admin.config
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="admin";
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN

vi usera.config
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="usera" password="usera";
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN

vi userb.config
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="userb" password="userb";
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
```

Store above configuration files in all nodes and restart kafka service


## Check whether SASL and ACL are enabled or not

Try to list kafka topics using admin user config file
```  
/opt/kafka/bin/kafka-topics.sh --bootstrap-server hostname1.com:9092 --list  --command-config /opt/kafka/config/kraft/admin.config
__consumer_offsets
kafka-topic-test
kafka-topic-test-user
newtopicadmin
newtopicusera
newtopicuserb
```
