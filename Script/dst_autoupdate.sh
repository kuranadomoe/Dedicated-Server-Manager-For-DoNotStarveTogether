#!/bin/bash

#**********************************************************#
#                  dst_autoupdate.sh                       #
#              written by kuranadomoe                      #
#                       2018/7/20                          #
#                                                          #
#                   自动更新饥荒服务器                     #
#**********************************************************#




#**********************************************************#
#                     在这里自定义你的配置                 #


#    检测更新时间间隔: s表示秒,m表示分钟,h表示小时,d表示day
#    例如:    1h2m3s表示1小时2分钟3秒
interval=4m

#    在检测到可用更新后,过多少时间再关闭服务器进行更新
#    规则和上面差不多
announceTime=4m

#    你的steam路径,多数教程是这个,如果你的不是,自己改
steamPath=$HOME/steamcmd

#    你的饥荒安装的路径,默认就是这个路径...$HOME表示用户目录
#    路径最后面不要加/
dstPath="$HOME/Steam/steamapps/common/Don't Starve Together Dedicated Server"

#    额外的安装参数,如果不需要就不必填
#    例如:    联机旧神测试服填的是    -beta returnofthembeta
installArgs=''

#    地上/地下,enable表示需要启动
#    如果是两台服务器组成的饥荒服,每台就只需要启动一个了
#    把enable改成disable就不启动
master='enable'
caves='enable'

#    screen名字,地上世界和地下世界的
masterName='dst_master'
cavesName='dst_caves'

#    你存档的目录名称,如果是一台服务器上运行地上地下,那么这两个是相同的
masterDir='Cluster_1'
cavesDir='Cluster_1'

#    更新日志:    这个脚本的更新日志的路径
#    可以把它改成自己喜欢的路径,如果不想记录,就把它改成''
#    用法:    在单引号内填入文件名(可以指定目录)
updateLog='./dst_autoupdate.log'

#    存放服务器控制台日志的目录
#    如果不想记录日志,就把他改成''
#    例如填了$/HOME/dst/logs的话,
#    将会在用户目录的dst/logs这个目录下生成screen的日志
screenLog=$HOME/dst/logs


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

            echo
            echo
            echo
            echo

        fi;

        sleep $interval

    done

    return 0;
}

#    对用户的设置进行预处理
screenLogMaster=''
screenLogCaves=''
function preProc()
{
    if [ "$updateLog" != "" ]; then
        updateLog=" >> "$updateLog
        echo "setting updateLog =  $updateLog"
    fi;
    if [ "$screenLog" != "" ]; then
        screenLogMaster=" > "$screenLog"/$(date +%F_%T)_master.log"
        screenLogCaves=" > "$screenLog"/$(date +%F_%T)_caves.log"
        echo "setting screenLog = $screenLog"
        echo "setting screenLogMaster = $screenLogMaster"
        echo "setting screenLogCaves = $screenLogCaves"
    fi;
}

#    获取当前饥荒的版本号
function getCurVerNO()
{
    dstVerPath=$dstPath/version.txt;
    let curVer=`cat $dstVerPath`;
    curVersion=$curVer;
}

#    从klei网站爬取最新版本号
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

#    启动服务器
function start()
{
    echo
    echo 'starting...';
    echo $(date +%F_%T)

    cd $dstPath/bin;
    if [ "$master" = "enable" ]; then
        screenLogMaster=" > "$screenLog"/$(date +%F_%T)_master.log"
        echo 'starting master...';
        screen -mdS $masterName bash -c "./dontstarve_dedicated_server_nullrenderer -cluster $masterDir -shard Master $screenLogMaster";
        echo "started~ argument:    screen -mdS $masterName bash -c \"./dontstarve_dedicated_server_nullrenderer -cluster $masterDir -shard Master $screenLogMaster\"";
    fi;
    if [ "$caves" = "enable" ]; then
        screenLogCaves=" > "$screenLog"/$(date +%F_%T)_caves.log"
        echo 'starting caves';
        screen -mdS $cavesName bash -c "./dontstarve_dedicated_server_nullrenderer -cluster $cavesDir -shard Caves $screenLogCaves";
        echo "started~ argument:    screen -mdS $cavesName bash -c \"./dontstarve_dedicated_server_nullrenderer -cluster $cavesDir -shard Caves $screenLogCaves\"";
    fi;
    echo 'all started...'
    return 0;
}

#    关闭服务器之前进行的公告
function shutdownPreparation()
{
    echo
    echo 'preparation for shutdown ...';
    if [ "$master" = "enable" ]; then
        screen -X -S $masterName stuff 'c_announce("服务器将于'$announceTime'后关机进行更新,请做好准备~")\n';
    fi;
    if [ "$caves" = "enable" ]; then
        screen -X -S $cavesName stuff 'c_announce(服务器将于'$announceTime'后关机进行更新,请做好准备~)\n';
    fi;
    sleep $announceTime;
    echo 'preparation OK...'
    return 0;
}

#    关闭服务器
function shutdown()
{
    echo
    echo 'shutting down...';
    echo $(date +%F_%T)

    if [ "$master" = "enable" ]; then
        screen -X -S $masterName stuff 'c_shutdown()\n';
    fi;
    if [ "$caves" = "enable" ]; then
        screen -X -S $cavesName stuff 'c_shutdown()\n';
    fi;
    echo 'shutdown OK...'
    return 0;
}

#    更新饥荒
function update()
{
    echo
    echo 'updating...';
    cd $steamPath;
    ./steamcmd.sh +login anonymous +force_install_dir $dstPath +app_update 343050 $installArgs validate +quit;
    echo 'update OK...'
    echo $(date +%F_%T)
    return 0;
}

main "$@";
