#!/bin/bash

####################################################
# NCSA Browndog : Deploy Clowder in unattended mode
#
# Description: To deploy Clowder in unattended mode
# Author:
#	Ceasar Sun <ceasar_at_nchc_org_tw>
#
#	Free Software Lab, NCHC, Taiwan
#	License: GPL
####################################################
export PATH=$PATH:/usr/sbin:/bin:/sbin:/sbin


# Load Browndog setting and functions
_BROWNDOG_ROOT_DIR=$(cd $(dirname $0) ;pwd)

[ -f "$_BD_ROOT_DIR/conf/browndog.conf" ] && [ -z "$_LOAD_BROWNDOG_CONF" ] && . $_BROWNDOG_ROOT_DIR/conf/browndog.conf

_CLOWDER_SERVICE_USER="clowder"
_CLOWDER_SERVICE_GROUP="ncsa"

[ ! -e /etc/debian_version ] && ( $SETCOLOR_FAILURE; echo "Installer only support Debian-liked Linux currently !!"; $SETCOLOR_NORMAL) &&	exit 1;

# check privilege
[ "$UID" != "0" ] && ( $SETCOLOR_FAILURE; echo "Please use root privilege, ex: 'sudo $0'"; $SETCOLOR_NORMAL) &&	exit 1;

# Step 1: create needed accout/group and insatll system package
$SETCOLOR_WARNING ; echo " Step 1: create needed accout/group and insatll system package ..." ; $SETCOLOR_NORMAL;

groupadd $_CLOWDER_SERVICE_GROUP
adduser  --disabled-password  --gecos "Clowder service runner" --ingroup $_CLOWDER_SERVICE_GROUP $_CLOWDER_SERVICE_USER

apt-get install openjdk-7-jdk mongodb　rabbitmq-server　curl scala python-setuptools
systemctl status mongodb.service 

# Step 2: config rabbitmq
$SETCOLOR_WARNING ; echo "Step 2: config rabbitmq..." ; $SETCOLOR_NORMAL
# enable rabbitmq_management
rabbitmq-plugins enable rabbitmq_management

# restart rabbitmq 
systemctl restart rabbitmq-server.service
systemctl status rabbitmq-server.service

# Step 3: Install Elasticsearch
$SETCOLOR_WARNING ; echo "Step 3: Install Elasticsearch..."; $SETCOLOR_NORMAL
echo "Install Elasticsearch ... "
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
apt-get update && sudo apt-get install elasticsearch
$SETCOLOR_WARNING ; echo "Enable and start service"; $SETCOLOR_NORMAL
systemctl enable elasticsearch.service
systemctl start elasticsearch.service
systemctl status elasticsearch.service

echo " Install a Elasticsearch plugin ..."
/usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head

