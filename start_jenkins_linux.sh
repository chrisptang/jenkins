#!/bin/bash

ROOT_PATH="/opt"

mkdir -p ${ROOT_PATH}/logs/jenkins

jenkins_war="jenkins.war"
if [ -n "$1" ]; then
    jenkins_war=$1
fi


export JDK11_FULLNAME="jdk-11.0.9_linux-x64_bin"
export JDK11_DOWNLOAD_LINK="https://code.aliyun.com/kar/ojdk11-11.0.9/raw/master/${JDK11_FULLNAME}.tar.gz"
export JDK8_FULLNAME="jdk-8u271-linux-x64"
export JDK8_DOWNLOAD_LINK="https://code.aliyun.com/kar/ojdk8-8u271/raw/master/${JDK8_FULLNAME}.tar.gz"

echo "current user:`whoami`"
echo "have a check on current user's ENVs:"
printenv

is_jdk_install=1
make_sure_jdk_installed()
{
    # test if java is installed
    export JAVA_VER=$(java -version 2>&1 >/dev/null | egrep "\S+\s+version" | awk '{print $3}' | tr -d '"')
    if test -n "${JAVA_VER}"
    then
        echo "java version:$JAVA_VER"
        is_jdk_install=0
        return $is_jdk_install
    fi

    if [ -f /opt/${JDK8_FULLNAME}/bin/java ]
    then
        export JAVA_HOME=/opt/${JDK8_FULLNAME}
        export PATH=$JAVA_HOME/bin:$PATH
        echo "${JDK8_FULLNAME} has been downloaded before, just initial the envs."
        echo "JAVA_HOME:${JAVA_HOME}, PATH:${PATH}"
        is_jdk_install=0
        return $is_jdk_install
    fi

    printf "\n\n\n========\t java is not installed yet, about to download and install it.\n"

    rm -fr /opt/${JDK8_FULLNAME} && mkdir -p /opt/${JDK8_FULLNAME} && cd /opt/${JDK8_FULLNAME}

    wget ${JDK8_DOWNLOAD_LINK}

    tar -xvf ${JDK8_FULLNAME}.tar.gz

    mv /opt/${JDK8_FULLNAME}/jdk1.8.0_271/* /opt/${JDK8_FULLNAME}

    export JAVA_HOME=/opt/${JDK8_FULLNAME}
    echo "export JAVA_HOME=/opt/${JDK8_FULLNAME}" >> ~/.bash_profile
    echo "export JAVA_HOME=/opt/${JDK8_FULLNAME}" >> ~/.bashrc
    export PATH=$JAVA_HOME/bin:$PATH
    echo "export PATH=$JAVA_HOME/bin:$PATH" >> ~/.bash_profile
    echo "export PATH=$JAVA_HOME/bin:$PATH" >> ~/.bashrc

    echo "please check java version:`java -version`"

    is_jdk_install=0
    return $is_jdk_install
}

make_sure_jdk_installed

if [ "$is_jdk_install" != "0" ]
then
    printf "\n=============\tunable to check JDK installed\n"
    exit 13
fi

echo "starting jenkins with war:${ROOT_PATH}/$jenkins_war"

pid_local=`cat ${ROOT_PATH}/logs/jenkins/jenkins.pid`
pid_file="${ROOT_PATH}/logs/jenkins/jenkins.pid"

cat $pid_file | xargs kill -9

kill_wait_time=60
kill_status=0
for i in $(seq 1 1 $kill_wait_time); do
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
    tail -200 ${ROOT_PATH}/logs/jenkins/gc.log
    stop
    exit 100
else
    echo "--- pid:$pid_local has been killed properly ---"
fi

jdk_full_name=`ls /opt |grep jdk-8`

${ROOT_PATH}/${jdk_full_name}/bin/java -server -Xmx2g -Xms2g -Xss256k -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m \
	-XX:SurvivorRatio=8 -XX:+UseConcMarkSweepGC -XX:+ExplicitGCInvokesConcurrentAndUnloadsClasses \
	-XX:+CMSScavengeBeforeRemark -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 \
	-XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintGCDetails -XX:+HeapDumpOnOutOfMemoryError \
	-XX:HeapDumpPath=${ROOT_PATH}/logs/jenkins/heap_dump -Xloggc:${ROOT_PATH}/logs/jenkins/gc.log -jar \
	${ROOT_PATH}/$jenkins_war &>>${ROOT_PATH}/logs/jenkins/jenkins.log &

pid_local=$!

echo "$pid_local" > $pid_file

echo "jenkins is starting..."

ps aux|grep $pid_local

sleep 5

tail ${ROOT_PATH}/logs/jenkins/jenkins.log