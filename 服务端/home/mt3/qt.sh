#!/bin/bash


 
cd /home/mt3/sdk_server
nohup java -jar sdkserver.jar &
 
cd /home/mt3/name_server
nohup sh start.sh &