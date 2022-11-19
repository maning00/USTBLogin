# USTBLogin
北京科技大学校园网自动登录及IPv6 DDNS自动设置脚本<br>
支持掉线自动重连，IPv6 DDNS自动更新<br>

## 脚本说明
脚本主要在Openwrt进行使用，其他系统请自行测试。<br>
- login.sh: 简单的手动登录脚本，需要根据提示手动输入用户名和密码进行登录<br>
- login_auto.sh: 自动登录脚本，需要在脚本中填写用户名和密码，然后可以将脚本放入crontab中，定时执行<br>
- ipv6_ddns.sh: 基于Cloudflare的IPv6 DDNS更新脚本，使用方法：在脚本中填写好Cloudflare的授权信息并与auto_login_ddns.sh一同放入`/etc/`目录下。

## 使用方法
定时自动执行脚本，可以使用crontab，请参考[Openwrt官方文档](https://openwrt.org/docs/guide-user/base-system/cron)<br>