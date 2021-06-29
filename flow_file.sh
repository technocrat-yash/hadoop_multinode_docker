#!/bin/bash

log_date=`date "+%Y-%m-%d"`
log_time=`date "+%T"`
log_path=logs/$log_date/
sudo mkdir -p $log_path
chmod 777 $log_path
touch $log_path/$log_time.log
echo " "
echo "###########################################"
echo "#                                         #"
echo "#  @@@     @@@     @@@  @  @  @@@@  @@@@  #"
echo "#  @  @   @   @   @     @ @   @     @  @  #"
echo "#  @   @ @     @ @      @@    @@@   @ @   #"
echo "#  @  @   @   @   @     @ @   @     @  @  #"
echo "#  @@@     @@@     @@@  @  @  @@@@  @   @ #"
echo "#                                         #"
echo "###########################################"
echo " "
echo "This is an automated Hadoop installation on Docker Script."
echo "When this scripts completes, you will be having a working hadoop cluster on top of Docker Containers."
echo "Enjoy the process!!"
echo " "
echo ":::::::::::::::::::::::::::::::::::::::::: Prompt Alert :::::::::::::::::::::::::::::::::::::::::::::::::"
echo " "

echo "Enter a name for your Docker Network :"
read net_name
echo " "
echo "Your Docker Network name will be set as ${net_name}"

echo " "
echo "Enter the IPv4 subnet address in the form 255.255.255.0/24 (Example - 172.30.0.2/24) : "
read net_subnet
echo " "

echo "###############################################################"
echo " "
echo "CREATING A DOCKER NETWORK with Name as ${net_name} and Subnet Address as ${net_subnet}"
echo " "

docker network create --subnet=$net_subnet $net_name

echo "Docker network Created Successfully. Now you can use the network name to initialize containers in the subnet."
echo " "

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Please Enter the IP's of nodes separated by space with first input as Namenode and rest will be datanodes"

read -a  IP_TABLE

len=${#IP_TABLE[@]}
counter_len=`expr $len - 1`
counter=0
while [ $counter -le $counter_len ]
do
    if [ $counter -eq 0 ]
    then 
        echo " "
        echo "Namenode will be : ${IP_TABLE[$counter]}"
        echo ${IP_TABLE[$counter]} >> server_list
        counter=`expr $counter + 1`
        echo " "
        echo "Datanodes will be :"
    else
        echo ${IP_TABLE[$counter]}
        echo ${IP_TABLE[$counter]} >> server_list
        counter=`expr $counter + 1`
    fi
done
echo " "
echo "Your Server List file has been created."
echo " "

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "
echo "Building Image for Hadoop Docker"
echo " "

echo "Enter name for Image and tag to be associated with it as <image name>:<tag> (Example - hadoop_image:latest )"
read img_name

echo " "
docker build -f Dockerfile . -t $img_name &
rc=$?
PID=$!
i=1
sp="/-\|"
echo -n 'Creating Docker Image '
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done

echo " "
if [ $rc -eq 0 ]
then
    echo "Docker Image Created successfully as ${img_name}"
else
    echo "Docker Image Creation Failed!!"
    exit $rc
fi

echo " "
echo "****************************************************************"
echo " "
echo "${len} Containers will be created for the Hadoop Deployment."
echo "Initializing Containers"
echo " "

counter=0
while [ $counter -le $counter_len ]
do
    if [ $counter -eq 0 ]
    then 
        echo " "
        echo "Namenode initializing at : ${IP_TABLE[$counter]}"
        docker run -itd --network $net_name --env-file env --name=namenode --ip ${IP_TABLE[$counter]} -p 50070:50070 -p 50010:50010 -p 8088:8088 -p 8032:8032 -p 10000:10000 -p 7077:7077 -p 9000:9000 -p 19888:19888 -p 8080:8080 -p 18080:18080  $img_name bash
        rc=$?
        if [ $rc -eq 0 ]
        then
            echo "Namenode Created successfully !!"
            echo " "
        else
            echo "Namenode Creation Failed!!"
            exit $rc
        fi
        counter=`expr $counter + 1`
        echo " "
    else
        echo "Datanode ${counter} initializing at : ${IP_TABLE[$counter]}"
        cnt_name=datanode$counter
        docker run -itd --network $net_name --ip ${IP_TABLE[$counter]} --env-file env --name=$cnt_name $img_name bash
        rc=$?
        if [ $rc -eq 0 ]
        then
            echo "Datanode${counter} Created successfully !!"
            echo " "
        else
            echo "Datanode${counter} Creation Failed!!"
            exit $rc
        fi
        echo " "
        counter=`expr $counter + 1`
    fi
done

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "
echo "Enabling Passwordless Login..."
echo " "
echo "Hold on, while the process is getting done!"
echo " "

sudo chmod +x create_passwordless.sh keygen_authorize.sh kg_pass.sh copy_to_slaves.sh
./create_passwordless.sh
rc=$?
if [ $rc -eq 0 ]
then
    echo "Passwordless Login Successfully Set up!"
    echo " "
else
    echo "Enabling Passwordless login on Hosts failed!!"
    exit $rc
fi

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "
echo "Adding Hosts information to the hosts file on the Containers"
echo " "

sudo chmod +x copyhost_to_hostfile.sh
./copyhost_to_hostfile.sh
rc=$?
if [ $rc -eq 0 ]
then
    echo "Hosts Information updated on Hosts!"
    echo " "
else
    echo "Updating Hosts Information failed!!"
    exit $rc
fi

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "
echo "Changing configuration files on the Hosts to update NameNode Information"
echo " "

sudo chmod +x change_config.sh conf_chng.sh sed_configs.sh
./change_config.sh 
rc=$?
if [ $rc -eq 0 ]
then
    echo "Configuration Information updated on Hosts!"
    echo " "
else
    echo "Configuration Information updation failed!!"
    exit $rc
fi

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "
echo "Copying Workers File to Hosts"
echo " "

sudo chmod +x add_workers.sh copy_workers.sh
./add_workers.sh
rc=$?
if [ $rc -eq 0 ]
then
    echo "Workers Information updated on Hosts!"
    echo " "
else
    echo "Workers Information updation failed!!"
    exit $rc
fi

echo " "
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo " "
echo "Setting up Environment Variables for Hadoop"
echo " "

sudo chmod +x add_env.sh copy_env.sh ssh_env_copy.sh
./add_env.sh
rc=$?

if [ $rc -eq 0 ]
then
    echo "Environment Variables Set successfully!"
    echo " "
else
    echo "Environment Variables not set! Please check the logs!"
    exit $rc
fi
echo " "
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo " "
echo "All the things are set !!"
echo "Starting up the services of the cluster"
echo " "

sleep 7
PID=$!
i=1
sp="/-\|"
echo -n ' '
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
done

sudo chmod +x start_services.sh hdfs_format.sh start_hdfs.sh start_yarn.sh
./start_services.sh
rc=$?
if [ $rc -eq 0 ]
then
    echo "HDFS and YARN services started successfully !!"
    echo " "
else
    echo "Service Boot failed!!"
    exit $rc
fi

echo " "
echo "Your Cluster is now ready to use ! Happy Coding <>"