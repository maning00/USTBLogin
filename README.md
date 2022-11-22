# USTBLogin

北京科技大学校园网自动登录及IPv6 DDNS自动设置脚本<br>
支持掉线自动重连，IPv6 DDNS自动更新<br>

## 脚本说明

脚本主要在Openwrt进行使用，其他系统请自行测试。<br>

- login.sh: 一个简单的`手动`登录脚本，需要根据提示手动输入用户名和密码进行登录。<br>
- auto_login.sh: 自动登录脚本，需要修改脚本填写自己的用户名和密码等信息，然后配合定时自动执行使用。<br>
- ipv6_ddns.sh: 基于Cloudflare的IPv6 DDNS更新脚本，可以搭配auto_login.sh使用。<br>

## 使用方法

- 手动登录（login.sh）: `sh login.sh` 然后根据提示进行登录<br>
- 自动登录（auto_login.sh）: 自行在脚本中填写登录信息，使用chmod +x对两个脚本增加执行权限。然后在`crontab`中添加条目定时执行，或者使用`Watchcat`监测掉线自动执行脚本进行重连。

### 例如，使用crontab定时执行

执行命令

```bash
crontab -e
```

编辑crontab文件，添加如下条目：

```bash
*/5 * * * * /etc/auto_login_ddns.sh # 每5分钟执行一次
```

使用crontab，请参考[Openwrt官方文档](https://openwrt.org/docs/guide-user/base-system/cron)<br>

### 例如，使用Watchcat监测掉线自动执行

安装Watchcat

```bash
opkg update
opkg install watchcat luci-app-watchcat
```

然后在web页面添加自动执行脚本的条目。<br>
或者使用命令行添加条目：

```bash
config watchcat
        option mode 'run_script' # 模式：执行脚本
        option script '/etc/auto_login.sh'  # 脚本路径
        option addressfamily 'ipv6'
        option pingperiod '30s' # 每30秒ping一次
        option pingsize 'standard'
        option pinghosts '2001:da8:d800:95::110' # ping的地址
        option period '5s' # 要检查主机的回复时间
```

使用Watchcat，请参考[Openwrt官方文档](https://openwrt.org/docs/guide-user/services/watchcat)<br>
