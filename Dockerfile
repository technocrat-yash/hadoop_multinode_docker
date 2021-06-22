FROM ubuntu:18.04

MAINTAINER yashpatil516@gmail.com

USER root

# Update Repositories and add dependencies
RUN apt-get update
RUN apt update && apt-get install -y openssh-server ssh sudo
RUN apt-get install -y openjdk-8-jdk openjdk-8-jre vim expect

# Allow root to login without password
RUN mkdir -p configs
RUN ssh-keygen -t rsa -P "" -f configs/id_rsa
RUN echo "PermitRootLogin prohibit-password" >> /etc/ssh/sshd_config

# For SSH from outside Container Purposes
COPY ssh_start.sh /ssh_start.sh
RUN chmod +x /ssh_start.sh
ENTRYPOINT ["sh","/ssh_start.sh"]

# Create Hadoop user for Hadoop operations
RUN useradd -m -d /home/hadoop/ -p $(perl -e 'print crypt($ARGV[0], "password")' '123') hadoop
RUN chage -M 99999 hadoop
RUN echo "hadoop    ALL=(ALL)       NOPASSWD:ALL" >> /etc/sudoers

# Create directory for hadoop user and download and extract hadoop
RUN mkdir -p /home/hadoop/
#RUN wget https://downloads.apache.org/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz -P /home/hadoop/
ADD /hadoop-3.2.1.tar.gz /home/hadoop
#RUN tar xzf /home/hadoop/hadoop-3.2.1.tar.gz -C /home/hadoop/
RUN mv /home/hadoop/hadoop-3.2.1 /home/hadoop/hadoop
RUN chown hadoop -R /home/hadoop/

# Set the Environment variables in hadoop-env.sh file
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh
RUN echo "export HADOOP_HOME=/home/hadoop/hadoop" >> /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh
RUN echo "export HADOOP_CONF_DIR=/home/hadoop/hadoop/etc/hadoop" >> /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh
RUN echo "export HDFS_NAMENODE_USER=hadoop" >> /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh
RUN echo "export HDFS_DATANODE_USER=hadoop" >> /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh
RUN echo "export HDFS_SECONDARYNAMENODE_USER=hadoop" >> /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh

# Create directories for namenode, datanode, logs and tmp
RUN mkdir -p /home/hadoop/data/nameNode /home/hadoop/data/dataNode /home/hadoop/data/nameNodeSecondary /home/hadoop/data/tmp /home/hadoop/hadoop/logs