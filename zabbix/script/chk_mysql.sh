#!/bin/sh

MYSQL_SOCK="/data/mysql/datadir/3306/data/mysql.sock"

MYSQL_USER='zabbix'

MYSQL_PWD='123456'

MYSQL_HOST='10.60.10.71'

MYSQL_PORT='3306'

ARGS=1

if [ $# -ne "$ARGS" ];then

    echo "Please input one arguement:"

fi

case $1 in

    Uptime)

        result=`/data/mysql/installdir/bin/mysqladmin -u$MYSQL_USER -h$MYSQL_HOST -p${MYSQL_PWD} -S $MYSQL_SOCK status  2>/dev/null|cut -f2 -d":"|cut -f1 -d"T"`

            echo $result

            ;;

        Com_update)

            result=`/data/mysql/installdir/bin/mysqladmin -u$MYSQL_USER -h$MYSQL_HOST -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status  2>/dev/null|grep -w "Com_update"|cut -d"|" -f3`

            echo $result

            ;;

        Slow_queries)

        result=`/data/mysql/installdir/bin/mysqladmin -u$MYSQL_USER -h$MYSQL_HOST -p${MYSQL_PWD} -S $MYSQL_SOCK status  2>/dev/null |cut -f5 -d":"|cut -f1 -d"O"`

                echo $result

                ;;

    Com_select)

        result=`/data/mysql/installdir/bin/mysqladmin -u$MYSQL_USER -h$MYSQL_HOST -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status  2>/dev/null |grep -w "Com_select"|cut -d"|" -f3`

                echo $result

                ;;

    Com_rollback)

        result=`/data/mysql/installdir/bin/mysqladmin -u$MYSQL_USER -h$MYSQL_HOST -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status  2>/dev/null |grep -w "Com_rollback"|cut -d"|" -f3`

                echo $result

                ;;

    Questions)

        result=`/data/mysql/installdir/bin/mysqladmin -u$MYSQL_USER -h$MYSQL_HOST -p${MYSQL_PWD} -S $MYSQL_SOCK status  2>/dev/null|cut -f4 -d":"|cut -f1 -d"S"`

                echo $result

                ;;

    Com_insert)

        result=`/data/mysql/installdir/bin/mysqladmin -u$MYSQL_USER -h$MYSQL_HOST -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status  2>/dev/null |grep -w "Com_insert"|cut -d"|" -f3`

                echo $result

                ;;

    Com_delete)

        result=`/data/mysql/installdir/bin/mysqladmin -u$MYSQL_USER -h$MYSQL_HOST -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status  2>/dev/null |grep -w "Com_delete"|cut -d"|" -f3`

                echo $result

                ;;

    Com_commit)

        result=`/data/mysql/installdir/bin/mysqladmin -u$MYSQL_USER -h$MYSQL_HOST -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status  2>/dev/null |grep -w "Com_commit"|cut -d"|" -f3`

                echo $result

                ;;

    Bytes_sent)

        result=`/data/mysql/installdir/bin/mysqladmin -u$MYSQL_USER -h$MYSQL_HOST -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status  2>/dev/null |grep -w "Bytes_sent" |cut -d"|" -f3`

                echo $result

                ;;

    Bytes_received)

        result=`/data/mysql/installdir/bin/mysqladmin -u$MYSQL_USER -h$MYSQL_HOST -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status  2>/dev/null|grep -w "Bytes_received" |cut -d"|" -f3`

                echo $result

                ;;

    Com_begin)

        result=`/data/mysql/installdir/bin/mysqladmin -u$MYSQL_USER -h$MYSQL_HOST -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status  2>/dev/null|grep -w "Com_begin"|cut -d"|" -f3`

                echo $result

                ;;        

        *)

        echo "Usage:$0(Uptime|Com_update|Slow_queries|Com_select|Com_rollback|Questions)"

        ;;

esac
