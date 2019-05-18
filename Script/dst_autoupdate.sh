#!/bin/bash

#**********************************************************#
#                  dst_autoupdate.sh                       #
#              written by kuranadomoe                      #
#                       2018/7/20                          #
#                                                          #
#                   自动更新饥荒服务器                        #
#**********************************************************#




#**********************************************************#
#                     在这里自定义你的配置                    #


#	检测更新时间间隔: s表示秒,m表示分钟,h表示小时,d表示day
#	例如:	1h2m3s表示1小时2分钟3秒
interval=4m

#	在检测到可用更新后,过多少时间再关闭服务器进行更新
#	规则和上面差不多
announceTime=4m

#	你的steam路径,多数教程是这个,如果你的不是,自己改
steamPath=$HOME/steamcmd

#	你的饥荒安装的路径,默认就是这个路径...$HOME表示用户目录
#	路径最后面不要加/
dstPath="$HOME/Steam/steamapps/common/Don't Starve Together Dedicated Server"

#	额外的安装参数,如果不需要就不必填
#	例如:	联机月岛测试服填的是	-beta returnofthembeta
installArgs=''

#	地上/地下,enable表示需要启动
#	如果是两台服务器组成的饥荒服,每台就只需要启动一个了
#	把enable改成disable就不启动
master='enable'
caves='enable'

#	screen名字,地上世界和地下世界的
masterName='dst_master'
cavesName='dst_caves'

#	你存档的目录名称,如果是一台服务器上运行地上地下,那么这两个是相同的
masterDir='Cluster_1'
cavesDir='Cluster_1'

#	更新日志:	如果希望记录这个脚本的更新日志,可以修改这个值
#	用法:	在单引号内填入文件名(可以指定路径),
#	例如:	'QwQ.log'表示将日志记录到QwQ.log这个文件内
updateLog=''

#	服务器控制台日志路径
screenLog=''


#                                                          #
#**********************************************************#




declare -f preProc;
declare -f getCurVerNO,getLatestVerNO,start,shutdownPreparation,shutdown,update;
let curVersion=0;
let latestVersion=0;

function main()
{
    #获取参数
    argv=($0 $@)
    argc=$#

	preProc "$@";
	if [ "$1" != "foreground" ]; then
        screen -mdS dst_autoupdate bash -c "$0 foreground $updateLog"
		exit 0
	fi;
	
    echo 'running...';
    echo
    for((;;))
    do

        getCurVerNO;
        getLatestVerNO;

        if [ $latestVersion -gt $curVersion ] ;then
			echo $(date +%F/%T)
			echo
			echo 'current version:'$curVersion
			echo 'latest version :'$latestVersion
			echo
            shutdownPreparation;
            shutdown;
            update;
            start;
        fi;

        #	检测
        echo 'sleeping...';
        sleep interval

    done

    return 0;
}

#	对用户的设置进行预处理
function preProc()
{
	if [ "$updateLog" != "" ]; then
		updateLog=" >> "$updateLog
	fi;
	if [ "$screenLog" != "" ]; then
		screenLog=" > "$screenLog"$(date +%F/%T)"
	fi;
}

#	获取当前饥荒的版本号
function getCurVerNO()
{
    dstVerPath=$dstPath/version.txt;
    let curVer=`cat $dstVerPath`;
    curVersion=$curVer;
}

#	从klei网站爬取最新版本号
function getLatestVerNO()
{
    versions=(`curl -s https://forums.kleientertainment.com/game-updates/dst | awk '/com\/game-updates\/dst\/[0-9].*?data-currentRelease/{print}' | grep -oE '[0-9]{6,}'`);
    let maxVer=0;
    for ver in ${versions[@]};
    do
        let temp=$ver;
        if [ $temp -gt $maxVer ];then
            maxVer=$temp;
        fi;
    done
    latestVersion=$maxVer;
}

#	启动服务器
function start()
{
    echo 'starting...';
    cd $dstPath/bin;
	if [ "$master" = "enable" ]; then
		screen -mdS $masterName bash -c "./dontstarve_dedicated_server_nullrenderer -cluster $masterDir -shard Master $screenLog_master.log"
	fi;
	if [ "$caves" = "enable" ]; then
		screen -mdS $cavesName bash -c "./dontstarve_dedicated_server_nullrenderer -cluster $cavesDir -shard Caves $screenLog_caves.log"
	fi;
    return 0;
}

#	关闭服务器之前进行的公告
function shutdownPreparation()
{
    echo 'preparation for shutdown ...';
	if [ "$master" = "enable" ]; then
		screen -X -S $masterName stuff 'c_announce("服务器将于'$announceTime'后关机进行更新,请做好准备~")\n';
	fi;
	if [ "$caves" = "enable" ]; then
		screen -X -S $cavesName stuff 'c_announce(服务器将于'$announceTime'后关机进行更新,请做好准备~)\n';
	fi;
    sleep announceTime;
    return 0;
}

#	关闭服务器
function shutdown()
{
    echo 'shutting down...';
	if [ "$master" = "enable" ]; then
		screen -X -S $masterName stuff 'c_shutdown()\n';
	fi;
	if [ "$caves" = "enable" ]; then
		screen -X -S $cavesName stuff 'c_shutdown()\n';
	fi;
    return 0;
}

#	更新饥荒
function update()
{
    echo 'updating...';
    cd $steamPath;
    ./steamcmd.sh +login anonymous +force_install_dir $dstPath +app_update 343050 $installArgs validate +quit;
    return 0;
}

main "$@";