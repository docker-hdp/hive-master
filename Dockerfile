FROM docker-hdp/centos-base:1.0
MAINTAINER Arturo Bayo <arturo.bayo@gmail.com>
USER root

ENV HADOOP_CONF_DIR /etc/hadoop/conf

# Configure environment variables for hive
ENV HIVE_USER hive
ENV HIVE_CONF_DIR /etc/hive/conf
ENV HIVE_LOG_DIR /var/log/hadoop/$HDFS_USER

# Install software
RUN yum clean all
RUN yum -y install hive-hcatalog

# Configure hive directories

# Hive
RUN mkdir -p $HIVE_LOG_DIR && chown -R $HIVE_USER:$HADOOP_GROUP $HIVE_LOG_DIR && chmod -R 755 $HIVE_LOG_DIR

# Copy configuration files
RUN mkdir -p $HIVE_CONF_DIR
COPY tmp/conf/ $HIVE_CONF_DIR/
RUN chown -R $HIVE_USER:$HADOOP_GROUP $HIVE_CONF_DIR/../ && chmod -R 755 $HIVE_CONF_DIR/../

RUN echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
RUN echo "export HADOOP_CONF_DIR=$HADOOP_CONF_DIR" >> /etc/profile
RUN echo "export PATH=$PATH:$JAVA_HOME:$HADOOP_CONF_DIR" >> /etc/profile

# Expose volumes
VOLUME $HDFS_LOG_DIR
VOLUME $YARN_LOG_DIR
VOLUME $MAPRED_LOG_DIR

# Expose ports
EXPOSE 9000
EXPOSE 14000
EXPOSE 50070
# Secondary
EXPOSE 50090

# Deploy entrypoint
COPY files/configure-namenode.sh /opt/run/00_hadoop-namenode.sh
COPY files/configure-resourcemanager.sh /opt/run/01_hadoop-resourcemanager.sh
COPY files/configure-secondarynamenode.sh /opt/run/02_hadoop-secondarynamenode.sh
RUN chmod +x /opt/run/*.sh

# Determine running user
#USER $ZOO_USER

# Execute entrypoint
ENTRYPOINT ["/opt/bin/run_all.sh"]

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --retries=5 \
  CMD curl -f http://localhost:50070/ || exit 1