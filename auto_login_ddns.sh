#!/bin/sh

# my_ip=$(wget -6 -qO - 'http://[2001:da8:208:100::115]:80/get_ip.php' | sed "s/^gIpV6Addr = '//g" | sed "s/';//g" | sed "s/\r//g" | sed "s/\n//g")
# 某些代理运行时候可能会导致以上的方法失效，故使用下面的方法更加robust
ips=$(/sbin/ip -6 addr | grep inet6 | awk -F '[ \t]+|/' '{print $3}' | grep -v ^::1 | grep -v ^fe80 | grep -v ^dd00:)
my_ip=""

sid="xxx"  # 你的上网账号
pwd="xxx"  # 你的上网账号的密码

public_ip=""

login() {
printf "Your IPv6 Address: %s\n" "${my_ip}"
public_ip=$my_ip
curl -L --data-urlencode "callback=dr1004" --data-urlencode "DDDDD=${sid}" --data-urlencode "upass=${pwd}" --data-urlencode "0MKKey=123456" --data-urlencode "R1=0R2" --data-urlencode "R3=0" --data-urlencode "R6=0" --data-urlencode "para=00" --data-urlencode "v6ip=${my_ip}" --data-urlencode "terminal_type=1" --data-urlencode "lang=zh-cn" --data-urlencode "jsVersion=4.1" --data-urlencode "v=9517" --data-urlencode "lang=zh" http://202.204.48.66/drcom/login >& /dev/null
}

logout() {
	curl http://202.204.48.66/F.htm >& /dev/null
}

trylog() {
for my_ip in $ips; do
if ping -W 1 -c 2 2403:18c0:1000:74:: &> /dev/null
then
  if [ "$public_ip" != "" ]; then
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
done
}

# 失败重试
n=1
while [ $n -le 10 ]
do
trylog
let n++
done
