#!/bin/bash


sudo sed -i s/INFO/DEBUG/ $HADOOP_CONF_DIR/log4j.properties

# Get hostname/ip config
MY_HOSTNAME=`hostname`
HDFS_NAMENODE_HOSTNAME=$MY_HOSTNAME

echo "Current Hostname:" $MY_HOSTNAME
echo "Current Namenode Hostname:" $HDFS_NAMENODE_HOSTNAME
echo "Current Secondary Namenode Hostname:" $HDFS_SECONDARYNAMENODE_HOSTNAME

echo "Changing hostnames in core-site.xml"

echo "Configure core-site.xml"
# From run environment
sudo sed -i s~HDFS_NAMENODE_HOSTNAME~$HDFS_NAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/core-site.xml
sudo sed -i s~HDFS_SECONDARYNAMENODE_HOSTNAME~$HDFS_SECONDARYNAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/core-site.xml

# From dockerfile configuration
sudo sed -i s~HDFS_NAMENODE_CHECKPOINT_DIR~$FS_CHECKPOINT_DIR~g $HADOOP_CONF_DIR/core-site.xml
sudo sed -i s~HDFS_NAMENODE_EDITS_DIR~$FS_CHECKPOINT_DIR~g $HADOOP_CONF_DIR/core-site.xml

echo "Configure hdfs-site.xml"
# From run environment
sudo sed -i s~HDFS_NAMENODE_HOSTNAME~$HDFS_NAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/hdfs-site.xml
sudo sed -i s~HDFS_SECONDARYNAMENODE_HOSTNAME~$HDFS_SECONDARYNAMENODE_HOSTNAME~g $HADOOP_CONF_DIR/hdfs-site.xml

# From dockerfile configuration
sudo sed -i s~HDFS_NAMENODE_NAME_DIR~$DFS_NAME_DIR~g $HADOOP_CONF_DIR/hdfs-site.xml
sudo sed -i s~HDFS_NAMENODE_CHECKPOINT_DIR~$FS_CHECKPOINT_DIR~g $HADOOP_CONF_DIR/hdfs-site.xml
sudo sed -i s~HDFS_DATANODE_DATA_DIR~$DFS_DATA_DIR~g $HADOOP_CONF_DIR/hdfs-site.xml

# format namenode...need to check this
if [ ! -d $HDFS_NAMENODE_NAME_DIR/current ]; then
	echo "Formatting namenode"
	su - $HDFS_USER -c "/usr/hdp/current/hadoop-hdfs-namenode/../hadoop/bin/hdfs namenode -format"
else
	echo "It seems that namenode is ready. Skipping format."
fi

echo "Starting namenode"
su - $HDFS_USER -c "/usr/hdp/current/hadoop-hdfs-namenode/../hadoop/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR start namenode"