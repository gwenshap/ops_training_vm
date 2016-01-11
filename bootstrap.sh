#!/usr/bin/env bash

sudo rpm --import http://packages.confluent.io/rpm/2.0/archive.key
sudo cp /vagrant/configfiles/confluent.repo /etc/yum.repos.d/

sudo yum -y install http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
sudo yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel graphite-web python-carbon python-pip python-yaml wget emacs


# TODO: each package is installed separately to avoid installing librdkafka, which has yum dependency issues
#       librdkafka should be installed from a tar.
sudo yum -y install confluent-kafka-2.10.5 confluent-camus confluent-kafka-connect-hdfs confluent-kafka-connect-jdbc confluent-kafka-rest confluent-schema-registry

sudo service iptables stop
sudo chkconfig iptables off

# patch a small bug that prevented us from getting logs:
sed "s/^\s*KAFKA_LOG4J_OPTS/export KAFKA_LOG4J_OPTS/" </usr/bin/kafka-server-start > temp_start_script
sudo cp temp_start_script /usr/bin/kafka-server-start

sudo zookeeper-server-start -daemon /etc/kafka/zookeeper.properties 
sudo JMX_PORT=9990 LOG_DIR=/var/log/kafka0 kafka-server-start -daemon /vagrant/configfiles/server0.properties
sudo JMX_PORT=9991 LOG_DIR=/var/log/kafka1 kafka-server-start -daemon /vagrant/configfiles/server1.properties
sudo JMX_PORT=9992 LOG_DIR=/var/log/kafka2 kafka-server-start -daemon /vagrant/configfiles/server2.properties
# the startup scripts here don't properly daemonize, so I need to do it here
sudo nohup schema-registry-start /etc/schema-registry/schema-registry.properties </dev/null &>/dev/null &
sudo nohup kafka-rest-start /etc/kafka-rest/kafka-rest.properties </dev/null &>/dev/null &

sudo /usr/lib/python2.6/site-packages/graphite/manage.py syncdb --noinput
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'myemail@example.com', 'hunter2')" | sudo /usr/lib/python2.6/site-packages/graphite/manage.py shell
sudo service carbon-cache start
sudo chkconfig carbon-cache on

sudo pip install gunicorn
sudo mkdir /var/run/gunicorn-graphite
sudo mkdir /var/log/gunicorn-graphite
sudo nohup gunicorn_django --bind=0.0.0.0:8000 --log-file=/var/log/gunicorn-graphite/gunicorn.log --preload --pythonpath=/usr/lib/python2.6/site-packages/graphite --settings=settings --workers=3 --pid=/var/run/gunicorn-graphite/gunicorn-graphite.pid </dev/null &>/dev/null &

wget http://central.maven.org/maven2/org/jmxtrans/jmxtrans/251/jmxtrans-251.rpm
sudo yum -y install jmxtrans-251.rpm
yaml2jmxtrans /vagrant/configfiles/kafka.yaml
sudo cp kafka_prod.json /var/lib/jmxtrans/
sudo service jmxtrans start
