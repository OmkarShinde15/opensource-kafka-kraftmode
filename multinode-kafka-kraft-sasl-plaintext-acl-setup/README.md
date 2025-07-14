## Pre-Requisite : 3 node PLAINTEXT Kakfa Kraft Cluster

Document for the same - [Install 3 node Apache Kafka Kraft Cluster](https://github.com/OmkarShinde15/opensource-kafka-kraftmode/tree/main/multimode-kafka-kraftsetup)


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
listeners=SASL_PLAINTEXT://hostname1.com:9092,CONTROLLER://hostname1.com:9093
advertised.listeners=SASL_PLAINTEXT://hostname1.com:9092
controller.listener.names=CONTROLLER
listener.security.protocol.map=CONTROLLER:SASL_PLAINTEXT,PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL

security.inter.broker.protocol=SASL_PLAINTEXT
sasl.enabled.mechanisms=PLAIN
sasl.mechanism.controller.protocol=PLAIN
sasl.mechanism.inter.broker.protocol=PLAIN
```

#### Below parameters are regarding ACL authorization

We are using "PlainLoginModule" for which "StandardAuthorizer" is used. We can also use keytab based authentication which needs different "Authorizer"

```
######### ACL #######

authorizer.class.name=org.apache.kafka.metadata.authorizer.StandardAuthorizer
super.users=User:admin
allow.everyone.if.no.acl.found=false
```

📄 Note: Refer to the [server.properties](https://github.com/OmkarShinde15/opensource-kafka-kraftmode/blob/main/multinode-kafka-kraft-sasl-plaintext-acl-setup/server.properties) file version-controlled in this repository to align configurations across environments.

## Step to use SASL and ACL in kafka

#### Lets create users

Create file named "pathto/kafka/config/kraft/jaas.config" and write below entry, here we have create 3 user admin, usera, userb
```
KafkaServer {
 org.apache.kafka.common.security.plain.PlainLoginModule required
 username="admin"
 password="admin"
 user_admin="admin"
 user_usera="usera"    //username="password"
 user_userb="userb";
};
```

#### Pass this file as a KAFKA_OPT variable inside kafka.service file

vi /etc/systemd/system/kafka.service
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


#### Lets create config file for each user as well and store it here "pathto/kafka/config/kraft"

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


## Create rules for usera and userb to access "newtopicusera" & "newtopicuserb" topics

Below rule will provide Read(consume), Write(produce), Describe(list/describe) privilege on respective topic

```
/opt/kafka/bin/kafka-acls.sh --bootstrap-server hostname1.com:9092   --add --allow-principal User:usera   --operation Read --operation Describe --operation Write   --allow-host '*'   --topic 'newtopicusera'   --command-config /opt/kafka/config/kraft/admin.config

/opt/kafka/bin/kafka-acls.sh --bootstrap-server hostname1.com:9092   --add --allow-principal User:userb   --operation Read --operation Describe --operation Write   --allow-host '*'   --topic 'newtopicuserb'   --command-config /opt/kafka/config/kraft/admin.config
```

Additionally you need one more rule for consuming topic

```
/opt/kafka/bin/kafka-acls.sh --bootstrap-server hostname1.com:9092   --add --allow-principal User:usera   --operation READ   --group usera-consumer-group   --command-config /opt/kafka/config/kraft/admin.config
```


## List ACL using admin user config file

```
/opt/kafka/bin/kafka-acls.sh --bootstrap-server hostname1.com:9092 --list --command-config /opt/kafka/config/kraft/admin.config
Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=newtopicusera, patternType=LITERAL)`:
        (principal=User:usera, host=*, operation=READ, permissionType=ALLOW)
        (principal=User:usera, host=*, operation=DESCRIBE, permissionType=ALLOW)
        (principal=User:usera, host=*, operation=WRITE, permissionType=ALLOW)

Current ACLs for resource `ResourcePattern(resourceType=TOPIC, name=newtopicuserb, patternType=LITERAL)`:
        (principal=User:userb, host=*, operation=READ, permissionType=ALLOW)
        (principal=User:userb, host=*, operation=DESCRIBE, permissionType=ALLOW)
        (principal=User:userb, host=*, operation=WRITE, permissionType=ALLOW)

Current ACLs for resource `ResourcePattern(resourceType=GROUP, name=usera-consumer-group, patternType=LITERAL)`:
        (principal=User:usera, host=*, operation=READ, permissionType=ALLOW)
```

## Lets list, produce & consumer the topic

List topic using usera & userb

```
/opt/kafka/bin/kafka-topics.sh --bootstrap-server hostname1.com:9092 --list  --command-config /opt/kafka/config/kraft/usera.config
newtopicusera

/opt/kafka/bin/kafka-topics.sh --bootstrap-server hostname1.com:9092 --list  --command-config /opt/kafka/config/kraft/userb.config
newtopicuserb
```

Produce Data into "newtopicusera" topic with usera config - Success
```
/opt/kafka/bin/kafka-console-producer.sh --bootstrap-server hostname1.com:9092   --topic newtopicusera   --producer.config /opt/kafka/config/kraft/usera.config
>HI, I am usera writing
>
>
```

Produce Data into "newtopicusera" topic with userb config - Failed

```
/opt/kafka/bin/kafka-console-producer.sh --bootstrap-server hostname1.com:9092   --topic newtopicusera   --producer.config /opt/kafka/config/kraft/userb.config
>sc
[2025-04-04 13:07:31,858] WARN [Producer clientId=console-producer] The metadata response from the cluster reported a recoverable issue with correlation id 5 : {newtopicusera=TOPIC_AUTHORIZATION_FAILED} (org.apache.kafka.clients.NetworkClient)
[2025-04-04 13:07:31,862] ERROR [Producer clientId=console-producer] Topic authorization failed for topics [newtopicusera] (org.apache.kafka.clients.Metadata)
[2025-04-04 13:07:31,863] ERROR Error when sending message to topic newtopicusera with key: null, value: 2 bytes with error: (org.apache.kafka.clients.producer.internals.ErrorLoggingCallback)
org.apache.kafka.common.errors.TopicAuthorizationException: Not authorized to access topics: [newtopicusera]
```

Consume Data from "newtopicusera" topic with usera config with "usera-consumer-group" group - Success

```
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server hostname1.com:9092   --topic newtopicusera   --consumer.config /opt/kafka/config/kraft/usera.config   --from-beginning --group usera-consumer-group
HI, I am usera writing
```

Consume Data from "newtopicusera" topic with usera config without "usera-consumer-group" group - Failed

```
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server hostname1.com:9092   --topic newtopicusera   --consumer.config /opt/kafka/config/kraft/usera.config   --from-beginning
[2025-04-04 13:13:04,073] ERROR Error processing message, terminating consumer process:  (org.apache.kafka.tools.consumer.ConsoleConsumer)
org.apache.kafka.common.errors.GroupAuthorizationException: Not authorized to access group: console-consumer-15101
Processed a total of 0 messages
```
