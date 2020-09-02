#!/bin/sh
UserName=root
DbName=alldb
DbConn="sudo mysql -u${UserName}"
DbDumpConn="sudo mysqldump -u${UserName}"
DbDumpOpions="--add-drop-database --add-drop-table --add-drop-trigger --default-character-set=utf8 --single-transaction --routines --events"
DbDumpFlag="--all-databases"
LogPath="${HOME}/admlogs"
LogFile="${LogPath}/DB_Backup_$(date "+%F").log"
TimeFormat="%d/%b/%Y:%H:%M:%S %z"

getTimestamp() {
    echo "[$(date +"${TimeFormat}")]"
}

umask 022

if [ ! -d "${LogPath}" ]; then
    mkdir ${LogPath}
fi

if ! pgrep mysqld > /dev/null; then
    echo $(getTimestamp) MySQL is down! >> ${LogFile}
    exit 1
fi

if !(grep -q password ${HOME}/.my.cnf); then
    DbConn="sudo mysql -u${UserName} -p"
    DbDumpConn="sudo mysqldump -u${UserName} -p"
fi

echo $(getTimestamp) starting backup. >> ${LogFile}

if [ -n "$1" ]; then
    DbName=$1
    DbCheck=$(${DbConn} -B -N -e "select Db from mysql.db where Db='${DbName}';")

    if [ -n "${DbCheck}" ]; then
        DbDumpFlag="--databases ${DbName}"
    else
        echo $(getTimestamp) Database ${DbName} is not exist! >> ${LogFile}
        exit 1
    fi
fi

DbDumpFile="db_${DbName}_$(date "+%F_%s").sql"
${DbDumpConn} ${DbDumpFlag} ${DbDumpOpions}> ${DbDumpFile}

if [ ! $? ]; then
    echo $(getTimestamp) Database ${DbName} backup is failed. >> ${LogFile}
else
    echo $(getTimestamp) Database ${DbName} backup is completed. >> ${LogFile}
fi
