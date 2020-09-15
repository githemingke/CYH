#!/usr/bin/env python
#-*- coding: utf-8 -*-
#author: hmk
#date: 2019-10-15
#comment: zabbix接入微信报警脚本

import requests
import sys
import os
import json
import logging

# 设置记录日志
logging.basicConfig(level = logging.DEBUG, format = '%(asctime)s, %(filename)s, %(levelname)s, %(message)s',
                datefmt = '%a, %d %b %Y %H:%M:%S',
                filename = os.path.join('/usr/local/zabbix/share/zabbix/alertscripts','weixin.log'),
                filemode = 'a')

# 必须修改1:企业ID
corpid='wwf97ae3aec2a1c6cd'

# 必须修改2：Secret
appsecret='c9y_uaeXMsjnmyMZKS1kpBo0sS7Eh_HcSBzuA7BUon0'

# 必须修改3:AgentId
agentid=1000002
#获取accesstoken
token_url='https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=' + corpid + '&corpsecret=' + appsecret
req=requests.get(token_url)
accesstoken=req.json()['access_token']

#发送消息
msgsend_url='https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=' + accesstoken

touser=sys.argv[1]
subject=sys.argv[2]
#toparty='3|4|5|6'
message=sys.argv[3]

params={
        "touser": touser,
#       "toparty": toparty,
        "msgtype": "text",
        "agentid": agentid,
        "text": {
                "content": message
        },
        "safe":0
}

req=requests.post(msgsend_url, data=json.dumps(params))
logging.info('sendto:' + touser + ';;subject:' + subject + ';;message:' + message)
