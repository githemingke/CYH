#!/bin/bash
mysql -urep1 -prep1 -e "select * from performance_schema.replication_group_members;" > /root/test/mgr.txt
awk '{print $NF}' /root/test/mgr.txt | sed -n 2p > /root/test/mgr.log


