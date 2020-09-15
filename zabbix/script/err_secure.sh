#!/bin/bash 
tail -100 /var/log/secure | grep "Failed password" | awk '{ip[$(NF-3)]++} END{for (i in ip) {print i ,ip[i]}}'
