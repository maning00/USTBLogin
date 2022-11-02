#!/bin/sh
#

my_ip=$(wget -qO - http://cippv6.ustb.edu.cn/get_ip.php | sed "s/^gIpV6Addr = '//g" | sed "s/';//g" | sed "s/\r//g" | sed "s/\n//g")

printf "Your IPv6 Address: %s\n" "${my_ip}"
sid=""
if [ $# -ne 1 ]; then
  read -p "      ID: " sid  
else 
  sid=$1
fi
stty -echo
read -p "Passowrd: " pwd
stty echo
printf "\n"

curl -L --data-urlencode "callback=dr1004" --data-urlencode "DDDDD=${sid}" --data-urlencode "upass=${pwd}" --data-urlencode "0MKKey=123456" --data-urlencode "R1=0R2" --data-urlencode "R3=0" --data-urlencode "R6=0" --data-urlencode "para=00" --data-urlencode "v6ip=${my_ip}" --data-urlencode "terminal_type=1" --data-urlencode "lang=zh-cn" --data-urlencode "jsVersion=4.1" --data-urlencode "v=9517" --data-urlencode "lang=zh" http://202.204.48.66/drcom/login