#!/bin/bash

#################### 脚本初始化 ####################

# 获取脚本工作目录绝对路径
export Server_Dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# 加载.env变量文件
source $Server_Dir/.env

# 给clash程序添加可执行权限
chmod +x $Server_Dir/bin/*


if [[ -f "/etc/os-release" ]]; then
     . /etc/os-release
     case "$ID" in
	 "freebsd"|"openbsd")
	     export isBSD=true
	 ;;
 	 *)
	     export isBSD=false
	 ;;
     esac
fi

#################### 变量设置 ####################

Conf_Dir="$Server_Dir/conf"
Log_Dir="$Server_Dir/conf"

# 获取CLASH面板访问的安全密钥值，如果不存在则生成一个随机数
Secret=${CLASH_SECRET:-$(openssl rand -hex 32)}

#################### 函数定义 ####################

# 自定义action函数，实现通用action功能
success() {
	echo -en "  OK  \r"
	return 0
}

failure() {
	local rc=$?
	echo -en "FAILED\r"
	[ -x /bin/plymouth ] && /bin/plymouth --details
	return $rc
}

action() {
	local STRING rc

	STRING=$1
	echo -n "$STRING "
	shift
	"$@" && success $"$STRING" || failure $"$STRING"
	rc=$?
	echo
	return $rc
}

# 判断命令是否正常执行 函数
if_success() {
	local ReturnStatus=$3
	if [ $ReturnStatus -eq 0 ]; then
		action "$1" /usr/bin/true
	else
		action "$2" /usr/bin/false
		exit 1
	fi
}
#################### 启动服务 ####################

# 添加运行参数到/etc/rc.conf
echo -e '\n添加运行参数到/etc/rc.conf'
sysrc clash_enable="YES"

# 配置Clash仪表盘，添加访问密钥
Work_Dir=$(cd $(dirname $0); pwd)
Dashboard_Dir="${Work_Dir}/dashboard/public"

if [[ $isBSD == false ]]; then
    sed -ri "s@^# external-ui:.*@external-ui: ${Dashboard_Dir}@g" $Conf_Dir/config.yaml
    sed -r -i '/^secret: /s@(secret: ).*@\1'${Secret}'@g' $Conf_Dir/config.yaml
else
    sed -i "" -e "s@^# external-ui:.*@external-ui: ${Dashboard_Dir}@g" "$Conf_Dir/config.yaml"
    sed -E -i "" -e '/^secret: /s@(secret: ).*@\1'"${Secret}"'@g' "$Conf_Dir/config.yaml"
fi

# 复制脚本文件并添加执行权限

cp $Conf_Dir/rc /usr/local/etc/rc.d/clash
chmod +x /usr/local/etc/rc.d/clash

## 启动Clash服务
echo -e '\n启动Clash代理服务...'
Text5="代理服务启动成功！"
Text6="代理服务启动失败！"
nohup $Server_Dir/bin/clash -d $Conf_Dir &> $Log_Dir/clash.log &
ReturnStatus=$?

if_success $Text5 $Text6 $ReturnStatus

# 输出clash仪表盘地址和安全密钥
echo -e '\nClash 仪表盘访问地址:'
echo -e "\033[32mhttp://<LAN ip>:9090/ui \033[0m"
echo -e "\033[32m访问密钥: ${Secret} \033[0m"

echo -e '\n命令说明：'
echo -e "\033[32m开启代理: service clash start\033[0m"
echo -e "\033[32m关闭代理: service clash stop\033[0m"
echo -e "\033[32m重启代理: service clash restart\033[0m"
echo -e "\033[32m查看状态: service clash status\033[0m"
echo -e "\033[32m手动调试: /root/clash/bin/clash -d /root/clash/conf\033[0m"
