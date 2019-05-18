#!/bin/bash


#	远程用户/远程主机/本地脚本名称/远程脚本名称
remoteUser='root'
remoteHost='129.204.193.110'
shutdownScript='shutdown_fangtang1.sh'

#	本地screen饥荒进程
pidList=(`screen -ls | awk '/[0-9]{3,}\./ {print strtonum($1)}'`)
for pid in ${pidList[@]};
do
	screen -X -S $pid stuff 'c_shutdown()\n'
done

#	如果此脚本未加参数调用,则关闭本地饥荒进程后关闭远程饥荒进程
if [ "$1" != "remote" ]; then
        echo '已成功关闭远程服务器~'
else
		echo '已成功关闭本地服务器,正在关闭远程服务器...'
        ssh remoteUser@remoteHost "'./$shutdownScript remote'"
fi