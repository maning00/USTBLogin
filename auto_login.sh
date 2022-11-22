#!/bin/sh

my_ip=$(wget -qO - 'http://cippv6.ustb.edu.cn/get_ip.php' | sed "s/^gIpV6Addr = '//g" | sed "s/';//g" | sed "s/\r//g" | sed "s/\n//g")
# 某些代理运行时候可能会导致以上的方法失效，可以尝试使用下面的方法
# ips=$(/sbin/ip -6 addr | grep inet6 | awk -F '[ \t]+|/' '{print $3}' | grep -v ^::1 | grep -v ^fe80 | grep -v ^dd00:)

SID="xxx" # 你的上网账号
PWD="xxx" # 你的上网账号的密码

V6_TESTIP="2001:da8:d800:95::110" # 用于测试ipv6连通性的IP，此处为USTC的IP
DDNS_FILE="/etc/ipv6_ddns.sh"     # DDNS脚本的路径，留空则不启用DDNS

public_ip=""

login() {
  printf "Your IPv6 Address: %s\n" "${my_ip}"
  public_ip=$my_ip
  curl -L --data-urlencode "callback=dr1004" --data-urlencode "DDDDD=${SID}" --data-urlencode "upass=${PWD}" --data-urlencode "0MKKey=123456" --data-urlencode "R1=0R2" --data-urlencode "R3=0" --data-urlencode "R6=0" --data-urlencode "para=00" --data-urlencode "v6ip=${my_ip}" --data-urlencode "terminal_type=1" --data-urlencode "lang=zh-cn" --data-urlencode "jsVersion=4.1" --data-urlencode "v=9517" --data-urlencode "lang=zh" http://202.204.48.66/drcom/login >&/dev/null
}

logout() {
  curl http://202.204.48.66/F.htm >&/dev/null
}

trylog() {
  if ping -W 1 -c 2 $V6_TESTIP &>/dev/null; then
    if [[ "$public_ip" != "" ]] && [[ -e $DDNS_FILE ]]; then
      echo "IP changed, executing ddns script..."
      /etc/ipv6_ddns.sh $public_ip
    fi
    echo -e "\033[32mOnline\033[0m"
    exit
  else
    echo -e "\033[31mOffline, trying to log in\033[0m"
    logout
    login
  fi
}

# 失败重试
n=1
while [ $n -le 10 ]; do
  trylog
  let n++
done
