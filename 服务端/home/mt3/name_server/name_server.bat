@echo off
title=name_server
del nsdb\mkdb.inuse
java -cp ./lib/jio.jar;./lib/monkeyking.jar;ns.jar com.locojoy.ns.Main nsdb.xml
pause

