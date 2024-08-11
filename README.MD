# clash-for-pfSense
pfSense上运行的命令行代理工具，在pfSense plus 24.03上测试成功。

本项目也可以在OPNsense上正常运行。

# 项目来源
源代码来自：
https://github.com/junyu33/clash-for-freebsd

clash程序来自：
https://github.com/MetaCubeX/mihomo/releases，
可以下载最新的版本替换bin目录下的clash程序。

# 使用须知

1、 运行脚本建议使用root用户，或者使用sudo提权。

2、 项目基于 [clash（mihomo）](https://github.com/MetaCubeX/mihomo/releases) 、[yacd](https://github.com/haishanh/yacd) 进行整合。

3、 脚本不提供任何订阅信息，请自行准备Clash订阅地址。

4、 当前只支持x86_64平台。

# 使用教程

## 下载项目

使用管理员账号登录pfSense的shell环境。

1、安装依赖
```bash
pkg install sudo
pkg install git
pkg install bash
pkg add https://pkg.freebsd.org/FreeBSD:13:amd64/latest/All/zsh-5.9_4.pkg
pkg add https://pkg.freebsd.org/FreeBSD:14:amd64/latest/All/zsh-5.9_4.pkg
pkg add https://pkg.freebsd.org/FreeBSD:15:amd64/latest/All/zsh-5.9_4.pkg
```
> **注意：** `zsh`应安装对应防火墙FreeBSD平台系统的版本。

2、下载项目
```bash
git clone https://github.com/fxn2020/clash-for-pfSense.git
```
3、重命名文件夹
```bash
mv /root/clash-for-pfSense /root/clash
```
4、修改安全密钥
```bash
vi /root/clash/.env
```
> `.env`文件中的变量`CLASH_SECRET`值为空时，脚本将自动生成随机字符串。

5、修改配置文件
```bash
vi /root/clash/conf/config.yaml
```
> 可以使用从支持Clash Meta核心的客户端程序（如[Clash Verge](https://github.com/Clash-Verge-rev/clash-verge-rev/releases) ）导出的配置文件。

> `allow-lan`参数必须设置为`true`，以允许防火墙的客户端使用代理。

> 为了使用Clash面板，需要设置面板访问地址、安全密钥和路径。

> DNS监听端口修改为53以外的其他可用端口，避免与防火墙DNS解析器或转发器使用的默认端口冲突。

## 启动程序

1、启动脚本
```bash
cd clash
sudo bash start.sh
```
将会出现以下运行信息：

```bash
添加运行参数...
clash_enable: YES -> YES

启动Clash代理服务...
Starting clash.
代理启动成功！   OK  

Clash仪表盘访问地址：
http://<LAN ip>:9090/ui 
访问密钥: 123456 

命令说明：
开启代理: service clash start 
关闭代理: service clash stop 
重启代理: service clash restart 
查看状态: service clash status 
```
2、检查端口
```bash
netstat -f inet -na | grep -i LISTEN
tcp46      0      0 *.7891                 *.*                    LISTEN     
tcp46      0      0 *.7890                 *.*                    LISTEN     
tcp46      0      0 *.9090                 *.*                    LISTEN     
tcp4       0      0 127.0.0.1.953          *.*                    LISTEN     
tcp4       0      0 *.53                   *.*                    LISTEN     
tcp4       0      0 127.0.0.1.3129         *.*                    LISTEN     
tcp4       0      0 127.0.0.1.3128         *.*                    LISTEN     
tcp4       0      0 192.168.101.4.3128     *.*                    LISTEN 
```
如果7890和9090端口被占用，说明clash程序启动成功，现在客户端就可以通过代理上网了。

3、透明代理

透明代理设置，请参阅[pfSense设置Clash透明代理](https://pfchina.org/?p=10526)。

## 控制面板

1、 通过地址`http://LAN IP:9090/ui`访问Clash控制面板。

2、 在`API Base URL`一栏中输入：http://\<ip\>:9090 ，在`Secret(optional)`一栏中输入访问安全密钥。

3、 点击`Add`，并单击刚刚输入的管理地址，之后便可以通过Web界面对clash进行一些配置。


