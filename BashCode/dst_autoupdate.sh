#!/bin/bash

#**********************************************************#
#                  dst_autoupdate.sh                       #
#              written by kuranadomoe                      #
#                       2018/7/20                          #
#                                                          #
#                   自动更新饥荒服务器                     #
#**********************************************************#

declare -f getCurVerNO,getLatestVerNO,start,shutdownPreparation,shutdown,stop,update;
let curVersion=0;
let latestVersion=0;

function main()
{
    #获取参数
    argv=($0 $@)
    argc=$#

    echo 'running...';
    echo
    for((;;))
    do

        getCurVerNO;
        getLatestVerNO;
        echo
        echo 'current version:'$curVersion
        echo 'latest version :'$latestVersion
        echo

        if [ $latestVersion -gt $curVersion ] ;then
            shutdownPreparation;
            shutdown;
            update;
            start;
        fi

        #10分钟检测一次
        echo 'sleeping...';
        sleep 10m

    done

    return 0;
}

function getCurVerNO()
{
    echo 'getting current version...';
    dstVerPath='/home/steam/dstserver/version.txt';
    let curVer=`cat $dstVerPath`;
    curVersion=$curVer;
}

function getLatestVerNO()
{
    echo 'getting latest version...';
    versions=(`curl -s https://forums.kleientertainment.com/game-updates/dst | awk '/com\/game-updates\/dst\/[0-9].*?data-currentRelease/{print}' | grep -oE '[0-9]{6,}'`);
    let maxVer=0;
    for ver in ${versions[@]};
    do
        let temp=$ver;
        if [ $temp -gt $maxVer ];then
            maxVer=$temp;
        fi
    done
    latestVersion=$maxVer;
}

function start()
{
    echo 'starting...';
    cd /home/steam/dstserver/bin;
    screen -d -m -S dst_hikarimimamorusakamichide_overworld ./dontstarve_dedicated_server_nullrenderer -cluster HikariMimamoruSakamichide -shard Master;
    screen -d -m -S dst_hikarimimamorusakamichide_caves ./dontstarve_dedicated_server_nullrenderer -cluster HikariMimamoruSakamichide -shard Caves;
    return 0;
}

function shutdownPreparation()
{
    echo 'preparation for shutdown ...';
    screen -X -S dst_hikarimimamorusakamichide_caves stuff 'c_announce("服务器将于5分钟后关机进行更新,请做好准备~")\n';
    screen -X -S dst_hikarimimamorusakamichide_overworld stuff 'c_announce(服务器将于5分钟后关机进行更新,请做好准备~)\n';
    sleep 5m;
    return 0;
}

function shutdown()
{
    echo 'shutting down...';
    screen -X -S dst_hikarimimamorusakamichide_caves stuff 'c_shutdown()\n';
    screen -X -S dst_hikarimimamorusakamichide_overworld stuff 'c_shutdown()\n';
    return 0;
}

function stop()
{
    echo 'forced shutdown...';
    screen -ls | grep -o "[0-9]\{5\}" | xargs kill;
    return 0;
}

function update()
{
    echo 'updating...';
    cd /home/steam/steamcmd;
    ./steamcmd.sh +login anonymous +force_install_dir /home/steam/dstserver +app_update 343050 validate +quit;
    return 0;
}

main "$@";