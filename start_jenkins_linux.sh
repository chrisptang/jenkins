#!/bin/bash

jenkins_war="jenkins.war"
if [ -n "$1" ]; then
    jenkins_war=$1
fi

echo "starting jenkins with war:/opt/$jenkins_war"

pid_local=`cat /logs/jenkins/jenkins.pid`
pid_file="/logs/jenkins/jenkins.pid"

cat $pid_file | xargs kill -9

kill_wiat_time=60
kill_status=0
for i in $(seq 1 1 $kill_wiat_time); do
    sleep 1
    if [ -z "`ls /proc/ |grep $pid_local`" ]; then
        kill_status=1
        break
    else
        echo "--- waiting pid:$pid_local to been killed ---"
    fi
done

if [[ $kill_status == 0 ]]; then
    printf "unable to kill jenkins, pid:$pid\n"
    printf "\n\n=====\t please have a check on latest app log:\n\n"
    tail -200 /logs/jenkins/gc.log
    stop
    exit -1
else
    echo "--- pid:$pid_local has been killed properly ---"
fi

/opt/jdk1.8.0_201/bin/java -server -Xmx2g -Xms2g -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m \
	-XX:SurvivorRatio=8 -XX:+UseConcMarkSweepGC -XX:+ExplicitGCInvokesConcurrentAndUnloadsClasses \
	-XX:+CMSScavengeBeforeRemark -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 \
	-XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintGCDetails -XX:+HeapDumpOnOutOfMemoryError \
	-XX:HeapDumpPath=/logs/jenkins/heap_dump -Xloggc:/logs/jenkins/gc.log -jar /opt/$jenkins_war &>>/logs/jenkins/jenkins.log &

pid_local=$!

echo "$pid_local" > $pid_file

echo "jenkins is starting..."

ps aux|grep $pid_local

sleep 5

tail /logs/jenkins/jenkins.log