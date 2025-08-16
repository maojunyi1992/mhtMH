#!/bin/bash
cd /home/mt3/gate_server
 nohup ./gateserver gate.conf > no.hut 2>&1 &
 
  cd /home/mt3/proxy_server
 nohup ./proxyserver proxy.conf > no.hut 2>&1 &


cd /home/mt3/sdk_server
nohup java -jar sdkserver.jar &
 
cd /home/mt3/name_server
nohup sh start.sh & 
cd /home/mt3/game_server
nohup java  -server -Dlog4j.configurationFile="log4j2.xml" -Xdebug -Xrunjdwp:transport=dt_socket,address=42998,server=y,suspend=n -Xms2096m -Xmx2096m -Xmn750m -jar gsxdb.jar -rmiport 10980 2>&1 >gs.log