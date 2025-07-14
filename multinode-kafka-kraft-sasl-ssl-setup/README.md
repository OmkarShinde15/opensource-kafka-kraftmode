## Enabling SSL on SASL_PLAINTEXT or PLAINTEXT cluster

Assuming you have installed and Kafka with KRaft is running on three nodes, proceed to configure SSL on three-node KRaft Kafka cluster.

This document provides configuration properties to help you enable SSL.

In our setup, we have three nodes:


| node.id | Node Hostname                | Node IP address | Node Role         |
|---------|------------------------------|------------------|--------------------|
| 1       | hostname1.com | 10.xxx.xx.101   | controller/broker |
| 2       | hostname2.com | 10.xxx.xx.102   | controller/broker |
| 3       | hostname3.com | 10.xxx.xx.103   | controller/broker |

## Create and Verify your certificate 

> **⚠️ Note:** Make sure to add 3 nodes hostname in SAN entry

```
openssl x509 -in oskafka.cer -text -noout
```
make sure to have below line in your certificate

```
X509v3 Subject Alternative Name:
    DNS:hostname1.com, DNS:hostname2.com, DNS:hostname3.com
```

## Create keystore and truststore of your certificate

convert cert to pkcs12 format

```openssl pkcs12 -inkey oskafka.key -in oskafka.cer -export -out oskafka.pkcs12```

create keystore

```keytool -importkeystore -srckeystore oskafka.pkcs12 -srcstoretype pkcs12 -deststoretype JKS -destkeystore kafka.keystore.jks -deststorepass your_password```

create truststore

```keytool -import -trustcacerts -alias os3nodekafka -file oskafka.cer -keystore kafka.truststore.jks```

see content of both keystore and truststore
```
keytool -list -v -keystore kafka.keystore.jks -storepass your_password

keytool -list -v -keystore kafka.truststore.jks -storepass your_password
```

it should contain SAN entries as below
```
SubjectAlternativeName [
  DNSName: hostname1.com
  DNSName: hostname2.com
  DNSName: hostname3.com
]
```

## Make below changes into kafka kraft server property

Place keystore and truststore at "/pathto/kafka/config/kraft/ssl" on all 3 nodes

<img width="968" alt="image" src="https://github.com/user-attachments/assets/2f1e7938-8a23-4532-8dbf-db1b68692720" />


In my case I have created additional subdirectory but not mandatory

## Make/Add below changes into server.properties file

Changes related to change mode from SASL_PLAINTEXT to SASL_SSL
```
security.inter.broker.protocol=SASL_SSL
advertised.listeners=SASL_SSL://hostname1.com:9092
listeners=SASL_SSL://hostname1.com:9092,CONTROLLER://hostname1.com:9093
```

## Adding configuration wrt SSL

```
######### SSL ##########

ssl.truststore.location=/opt/kafka/config/kraft/ssl/oskafkassl/kafka.truststore.jks
ssl.truststore.password=password
ssl.keystore.location=/opt/kafka/config/kraft/ssl/oskafkassl/kafka.keystore.jks
ssl.keystore.password=password
ssl.key.password=password
ssl.client.auth=required
```

📄 Note: Refer to the [server.properties](https://github.com/OmkarShinde15/opensource-kafka-kraftmode/blob/main/multinode-kafka-kraft-sasl-ssl-setup/service.properties) file version-controlled in this repository to align configurations across environments.

## Update your admin.config and user.config file with below entries

Do below changes if you were using SASL_PLAINTEXT 

adminssl.config
```
security.protocol=SASL_SSL
ssl.truststore.location=/opt/kafka/config/kraft/ssl/oskafkassl/kafka.truststore.jks
ssl.truststore.password=password
ssl.keystore.location=/opt/kafka/config/kraft/ssl/oskafkassl/kafka.keystore.jks
ssl.keystore.password=password

sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="your_password";
sasl.mechanism=PLAIN
```
userassl.config

```
security.protocol=SASL_SSL
ssl.truststore.location=/opt/kafka/config/kraft/ssl/oskafkassl/kafka.truststore.jks
ssl.truststore.password=password
ssl.keystore.location=/opt/kafka/config/kraft/ssl/oskafkassl/kafka.keystore.jks
ssl.keystore.password=password
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="usera" password="your_password";
sasl.mechanism=PLAIN
```

Check whether you are able to list, produce & consumer kafka topic

## Now you can create,list,produce,consumer from any node
```
/opt/kafka/bin/kafka-topics.sh --bootstrap-server hostname1.com:9092,hostname2.com:9092,hostname3.com:9092 --list --command-config /opt/kafka/config/kraft/adminssl.config

/opt/kafka/bin/kafka-console-producer.sh --bootstrap-server hostname1.com:9092,hostname2.com:9092,hostname3.com:9092 --topic kafka-topic-test --producer.config /opt/kafka/config/kraft/userassl.config

/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server hostname1.com:9092,hostname2.com:9092,hostname3.com:9092 --topic kafka-topic-test --consumer-config /opt/kafka/config/kraft/userassl.config --from-beginning


```

