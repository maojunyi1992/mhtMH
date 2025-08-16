#!/bin/bash
cd /home/mt3/game_server
export ZJ_HOME=/home/mt3/game_server/gs_lib
java -server -Dlog4j.configurationFile="log4j2.xml" -Xms2096m -Xmx2096m -Xmn750m -jar gsxdb.jar -rmiport 10980 2>&1 >gs.log