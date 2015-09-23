#!/usr/bin/env bash

mkdir -p /vagrant/configfiles
cp /tmp/configfiles/* /vagrant/configfiles
echo vagrant | passwd vagrant --stdin
