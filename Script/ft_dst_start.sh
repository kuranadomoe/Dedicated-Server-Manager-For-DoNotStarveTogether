#!/bin/bash

#       远程用户/远程主机/本地脚本名称/远程脚本名称/本地服务器类型/远程服务器类型
remoteUser='root'
remoteHost='129.204.193.110'
localScript='startmaster.sh'
remoteScript='startcaves.sh'
localServerType='Master'
remoteServerType='Caves'

#       提示
echo "请输入存档目录名:"
ls -l ./.klei/DoNotStarveTogether |awk '/^d/ {print $NF}'
if [ ! -d "./.klei/DoNotStarveTogether/$filenumber" ]; then
        echo '目录不存在'
        exit
fi
read filenumber
echo "正在启动存档:"
echo $filenumber

#       启动
screen -mdS "DST_$localServerType $filenumber" "./.klei/DoNotStarveTogether/$filenumber/$localScript"
ssh $remoteUser@$remoteHost "screen -mdS 'DST_$remoteServerType $filenumber' './.klei/DoNotStarveTogether/$filenumber/$remoteScript'"

#       显示启动结果
echo 
echo '启动完成,结果如下:'
echo '此服务器screen列表:'
screen -ls
echo 
echo '远程服务器screen列表:'
ssh $remoteUser@$remoteHost "screen -ls"
