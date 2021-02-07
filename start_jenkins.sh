#!/bin/bash

jvm_opt="-server -Xmx1g -Xms1g -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m"
jvm_opt="${jvm_opt} -XX:SurvivorRatio=8"
jvm_opt="${jvm_opt} -Xlog:gc+region=trace -Xlog:gc* -Xlog:ergo*=info -XX:+HeapDumpOnOutOfMemoryError"
jvm_opt="${jvm_opt} -XX:HeapDumpPath=/jenkins/logs/heap_dump -Xloggc:/jenkins/logs/gc.log"
jvm_opt="${jvm_opt} ${JVM_OPTS}"

echo "starting jenkins with options:${jvm_opt}"

mkdir -p /jenkins/logs

java ${jvm_opt} -jar /usr/share/jenkins/jenkins.war >> /jenkins/logs/jenkins.log