sudo service iptables stop
sudo chkconfig iptables off

sudo zookeeper-server-stop
sudo zookeeper-server-start -daemon /etc/kafka/zookeeper.properties

sleep 5

sudo JMX_PORT=9990 LOG_DIR=/var/log/kafka0 kafka-server-start -daemon /vagrant/configfiles/server0.properties
sudo JMX_PORT=9991 LOG_DIR=/var/log/kafka1 kafka-server-start -daemon /vagrant/configfiles/server1.properties
sudo JMX_PORT=9992 LOG_DIR=/var/log/kafka2 kafka-server-start -daemon /vagrant/configfiles/server2.properties
# the startup scripts here don't properly daemonize, so I need to do it here
sudo nohup schema-registry-start /etc/schema-registry/schema-registry.properties </dev/null &>/dev/null &
sudo nohup kafka-rest-start /etc/kafka-rest/kafka-rest.properties </dev/null &>/dev/null &

sudo service carbon-cache start
sudo chkconfig carbon-cache on

sudo nohup gunicorn_django --bind=0.0.0.0:8000 --log-file=/var/log/gunicorn-graphite/gunicorn.log --preload --pythonpath=/usr/lib/python2.6/site-packages/graphite --settings=settings --workers=3 --pid=/var/run/gunicorn-graphite/gunicorn-graphite.pid </dev/null &>/dev/null &

yaml2jmxtrans /vagrant/configfiles/kafka.yaml
sudo service jmxtrans start
