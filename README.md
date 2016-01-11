# Production-simulation Kafka VM

## What's included?

This is a Vagrant file and a provisioning script to create a VM that includes:
* 3 Kafka brokers with broker IDs 0, 1 and 2 running on ports 9090, 9091 and 9092
* 1 Zookeeper running on port 2181
* Graphite, running decidedly non-production (sqllite, unsafe, etc). 
* Gunicorn running the graphite web-server on port 8000 (exported to host machine as 4567)
* JMXTrans sending Kafka metrics to graphite. Pre-configured with my favorite metrics

All packages from Confluent Platform 2.0 are installed, except librdkafka.

## How to use this?

After installing vagrant and virtualbox...
* Start with "vagrant up", ssh to the machine with "vagrant ssh"
* Kafka is already running, so you can create few topics and produce and consume messages:

kafka-topics --zookeeper localhost:2181 --create --topic t1 --partitions 3 --replication-factor 3

kafka-producer-perf-test --broker-list localhost:9091 --topic t1 --messages 1000

kafka-consumer-perf-test --zookeeper localhost:2181 --topic t1

* You can create graphs and dashboards on graphite web interface: http://localhost:4567/dashboard
* You can use the graphite web api to generate graphs directly:

http://localhost:4567/render?target=jmx.kafka*.sys.OpenFileDescriptorCount&from=-1hours

http://localhost:4567/render?target=jmx.kafka*.brokertopicmetrics.BytesInPerSec.OneMinuteRate&from=-1hours

## Packing
To pack, install packer (if using Mac OS X, homebrew is recommended). Then run:

 packer build -only=virtualbox-iso packer.json

Note that after it reboots after finishing "kickstart", it doesn't start on its own and packer is left waiting for SSH
Just start it manually and packer will continue.
Patches to fix this issue are welcome :)
