#!/usr/bin/env python3
#
#	饥荒独立服自动更新脚本 by kurandomoe
#	功能:	自动更新服务器,或者在服务器的screen挂掉时重启服务器
#
import sys
import re
import os
from urllib.request import urlopen


#	饥荒服务器的安装路径
dstDir = "~/Steam/steamapps/common/Don't Starve Together Dedicated Server"
#	饥荒服务器启动脚本的路径,
dstStartScriptPath = "~/dst_start.sh"
#	饥荒服务器关闭脚本的路径
dstShutdownScriptPath = "~/dst_shutdown.sh"
#	强制关闭脚本,此项可以为空
dstForceShutdownScriptPath = ""
#	日志文件的路径,用于记录这个脚本自动更新和重启服务器,此项可不填
scriptLogPath = ""


def main(argv:list):
	"""
	自动更新脚本入口点
	"""
	#	检查参数
	global dstDir
	global dstStartScriptPath
	global dstShutdownScriptPath
	global dstForceShutdownScriptPath
	dstDir = os.path.expanduser(dstDir)
	dstStartScriptPath = os.path.expanduser(dstStartScriptPath)
	dstShutdownScriptPath = os.path.expanduser(dstShutdownScriptPath)
	dstForceShutdownScriptPath = os.path.expanduser(dstForceShutdownScriptPath)
	verFilePath = os.path.join(dstDir, 'version.txt')
	if not os.path.exists(verFilePath):
		print('未在目录' + dstDir + '下找到version.txt文件,请确认目录和文件是否存在')
		Pause()
		os._exit(1)
	if not os.path.exists(dstStartScriptPath):
		print('未找到启动脚本文件,请确认路径是否填写正确:' + dstStartScriptPath)
		Pause()
		os._exit(1)
	if not os.path.exists(dstShutdownScriptPath):
		print('未找到关闭脚本文件,请确认路径是否填写正确:' + dstStartScriptPath)
		Pause()
		os._exit(1)
	
	#	开始检查版本和饥荒独立服状态
	while True:

		latestVer = GetLatestVerstion()
		curVer = 0
		with open(verFilePath,'r') as verFile:
			curVer = int(verFile.readline())
		print(latestVer,curVer)

	Pause()

	
def GetLatestVerstion():
    """
    获取饥荒最新版本号
    """
    result = 0
    with urlopen('https://forums.kleientertainment.com/game-updates/dst/') as response:
        for line in response:
            line = line.decode('utf-8')
            match = re.search('https://forums.kleientertainment.com/game-updates/dst/(\d{6,})-',line)
            if match != None:
                version = int(match.group(1))
                if result < version:
                    result = version
    return result
	
	
def Pause():
	"""
	暂停
	"""
	input('Press enter key to continue...')


main(sys.argv)