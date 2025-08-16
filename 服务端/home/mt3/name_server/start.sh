#!/bin/sh
rm -rf nsdb/mkdb.inuse
java -cp ./lib/jio.jar:./lib/monkeyking.jar:ns.jar com.locojoy.ns.Main nsdb.xml

