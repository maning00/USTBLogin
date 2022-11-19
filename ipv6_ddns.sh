#!/bin/bash
###############  授权信息（需修改成你自己的） ################
# CloudFlare 注册邮箱
auth_email="xxx@email.com"
# CloudFlare Global API Key
auth_key="xxxxxx"
# 根域名
zone_name="mydomain.com"
# 做 DDNS 的域名，该域名将解析到你设置的IPv6地址
record_name="xxx.mydomain.com"
######################  修改配置信息 #######################
# 域名类型，IPv4 为 A，IPv6 则是 AAAA
record_type="AAAA"
# 获取输入的IPv6地址
ip=$1

if [ "$ip" == "" ]; then
    exit
fi

# 域名识别信息保存位置
id_file="/tmp/cloudflare.ids"
# 监测日志保存位置
log_file="/tmp/cloudflare.log"
######################  监测日志格式 ########################
log() {
    if [ "$1" ]; then
        echo -e "[$(date)] - $1" >> $log_file
    fi
}
######################  获取域名及授权 ######################
if [ -f $id_file ] && [ $(wc -l $id_file | cut -d " " -f 1) == 2 ]; then
    zone_identifier=$(head -1 $id_file)
    record_identifier=$(tail -1 $id_file)
else
    zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone_name" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )
    record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name&type=$record_type" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json"  | grep -Po '(?<="id":")[^"]*')
    echo "$zone_identifier" > $id_file
    echo "$record_identifier" >> $id_file
fi
######################  更新 DNS 记录 ######################
update=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier"\
    -H "X-Auth-Email: $auth_email" \
    -H "X-Auth-Key: $auth_key" \
    -H "Content-Type: application/json" \
    --data '{"type":"AAAA","name":"'"$record_name"'","content":"'"$ip"'","ttl":120,"proxied":false}')

#########################  更新反馈 #########################
if [[ $update == *"/"success/":false"* ]]; then
    message="API UPDATE FAILED. DUMPING RESULTS:/n$update"
    log "$message"
    echo -e "$message"
    exit 1
else
    message="IP changed to: $ip"
    log "$message"
    echo "$message"
fi
