#!/bin/bash
echo $(tput setaf 7)'##################################################################'$(tput sgr 0)
echo $(tput setaf 4)'                     Rancher Health Check for v1.6                '$(tput sgr 0)
echo $(tput setaf 4)'                By Matthew Mattox mmattox@rancher.com             '$(tput sgr 0)
echo $(tput setaf 7)'##################################################################'$(tput sgr 0)
echo $(tput setaf 4)"::Hardware Info::"$(tput sgr 0)
hostname="$(docker info 2>/dev/null | grep ^'Name:' | awk -F ': ' '{print $2}' | grep -v ^'WARNING: No swap limit support')"
hwsystem="$(lshw -quiet | grep 'product:' | head -n1 | awk -F ': ' '{print $2}')"
hwserial="$(lshw -quiet | grep 'serial:' | head -n1 | awk -F ': ' '{print $2}')"
cpuinfo="$(lshw -c CPU -quiet | grep 'product:' | head -n1 | awk -F ': ' '{print $2}' | tr -s " ")"
corecount="$(cat /proc/cpuinfo | grep ^processor | wc -l)"
meminfo="$(lshw -c memory -short -quiet | grep 'System Memory' | awk '{print $3}')"
echo $(tput setaf 2)"Hostname: $hostname"$(tput sgr 0)
echo $(tput setaf 2)"Hardware platform: $hwsystem"$(tput sgr 0)
echo $(tput setaf 2)"Serial Number: $hwserial"$(tput sgr 0)
echo $(tput setaf 2)"CPU info: $cpuinfo"$(tput sgr 0)
echo $(tput setaf 2)"Core count: $corecount"$(tput sgr 0)
echo $(tput setaf 2)"Memory: $meminfo"$(tput sgr 0)
echo $(tput setaf 7)"#################################################################"$(tput sgr 0)
echo $(tput setaf 4)"::OS Info::"$(tput sgr 0)
echo $(tput setaf 2)"$(docker info 2>/dev/null | grep ^'Operating System:')"$(tput sgr 0)
echo $(tput setaf 2)"$(docker info 2>/dev/null | grep ^'OSType:')"$(tput sgr 0)
echo $(tput setaf 2)"$(docker info 2>/dev/null | grep ^'Architecture:')"$(tput sgr 0)
echo $(tput setaf 2)"$(docker info 2>/dev/null | grep ^'Kernel Version:')"$(tput sgr 0)
echo $(tput setaf 7)"#################################################################"$(tput sgr 0)
echo $(tput setaf 4)"Checking CPU usage..."$(tput sgr 0)
cpuuser="$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F "." '{print $1}')"
cpunice="$(top -bn1 | grep "Cpu(s)" | awk '{print $4}' | awk -F "." '{print $1}')"
cpusys="$(top -bn1 | grep "Cpu(s)" | awk '{print $6}' | awk -F "." '{print $1}')"
cpuidle="$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | awk -F "." '{print $1}')"
cpuwait="$(top -bn1 | grep "Cpu(s)" | awk '{print $10}' | awk -F "." '{print $1}')"
echo $(tput setaf 2)":Current CPU usage:"$(tput sgr 0)
echo $(tput setaf 2)"Normal processes executing in user mode:" $cpuuser $(tput sgr 0)
echo $(tput setaf 2)"Niced processes executing in user mode:" $cpunice $(tput sgr 0)
echo $(tput setaf 2)"Processes executing in kernel mode:" $cpusys $(tput sgr 0)
echo $(tput setaf 2)"Idle:" $cpuidle $(tput sgr 0)
echo $(tput setaf 2)"Waiting for I/O to complete:" $cpuwait $(tput sgr 0)
echo $(tput setaf 4)":CPU Health Report:" $(tput sgr 0)
if [[ $cpuuser -ge 75 ]]
then
        echo $(tput setaf 1)"CRITICAL: Detected High CPU user time, this mean the CPU is being used up by an Application."$(tput sgr 0)
        echo $(tput setaf 1)"Top 5 processes by CPU"$(tput sgr 0)
        echo $(tput setaf 1)"$(ps aux | sort -nrk 3,3 | head -n 5)"$(tput sgr 0)
fi
if [[ $cpuuser -ge 25 ]] && [[ $cpuuser -le 75 ]]
then
        echo $(tput setaf 3)"WARNING: Detected High CPU user time, this mean the CPU is being used up by an Application."$(tput sgr 0)
        echo $(tput setaf 3)"Top 5 processes by CPU"$(tput sgr 0)
        echo $(tput setaf 3)"$(ps aux | sort -nrk 3,3 | head -n 5)"$(tput sgr 0)
fi
if [[ $cpuuser -lt 25 ]]
then
        echo $(tput setaf 2)"OK: CPU user times are ok"$(tput sgr 0)
fi

if [[ $cpusys -ge 75 ]]
then
        echo $(tput setaf 1)"CRITICAL: Detected High CPU sys time, this mean the CPU is being used up by the OS."$(tput sgr 0)
        echo $(tput setaf 1)"Top 5 processes by CPU"$(tput sgr 0)
        echo $(tput setaf 1)"$(ps aux | sort -nrk 3,3 | head -n 5)"$(tput sgr 0)
fi
if [[ $cpusys -ge 25 ]] && [[ $cpusys -le 75 ]]
then
        echo $(tput setaf 3)"WARNING: Detected High CPU sys time, this mean the CPU is being used up by the OS."$(tput sgr 0)
        echo $(tput setaf 3)"Top 5 processes by CPU"$(tput sgr 0)
        echo $(tput setaf 3)"$(ps aux | sort -nrk 3,3 | head -n 5)"$(tput sgr 0)
fi
if [[ $cpusys -lt 25 ]]
then
        echo $(tput setaf 2)"OK: CPU sys times are ok"$(tput sgr 0)
fi


if [[ $cpuwait -ge 20 ]] && [[ $cpuidle -le 20 ]]
then
        echo $(tput setaf 1)"CRITICAL: Detected High CPU wait time, this means the CPU is wasting times waiting on I/O ie Network or Storage"$(tput sgr 0)
        echo $(tput setaf 1)"Top 5 processes by CPU"$(tput sgr 0)
        echo $(tput setaf 1)"$(ps aux | sort -nrk 3,3 | head -n 5)"$(tput sgr 0)
fi
if [[ $cpuwait -ge 20 ]] && [[ $cpuidle -gt 20 ]]
then
        echo $(tput setaf 3)"WARNING: Detected High CPU wait time, this means the CPU is wasting times waiting on I/O ie Network or Storage"$(tput sgr 0)
        echo $(tput setaf 3)"Top 5 processes by CPU"$(tput sgr 0)
        echo $(tput setaf 3)"$(ps aux | sort -nrk 3,3 | head -n 5)"$(tput sgr 0)
fi
if [[ $cpuwait -lt 20 ]]
then
        echo $(tput setaf 2)"OK: CPU wait times are ok."$(tput sgr 0)
fi

echo $(tput setaf 7)"#################################################################"$(tput sgr 0)
echo $(tput setaf 4)"Checking MEM usage..."$(tput sgr 0)
memtotal="$(free -m | grep ^Mem: | awk '{print $2}')"
memused="$(free -m | grep ^Mem: | awk '{print $3}')"
memfree="$(free -m | grep ^Mem: | awk '{print $4}')"
memshared="$(free -m | grep ^Mem: | awk '{print $5}')"
membuff="$(free -m | grep ^Mem: | awk '{print $6}')"
memavail="$(free -m | grep ^Mem: | awk '{print $7}')"
memusedpert="$(echo "scale=2; $memused / $memtotal * 100" | bc | awk -F "." '{print $1}')"
memavailpert="$(echo "scale=2; $memavail / $memtotal * 100" | bc | awk -F "." '{print $1}')"
swaptotal="$(free -m | grep ^Swap: | awk '{print $2}')"
swapused="$(free -m | grep ^Swap: | awk '{print $3}')"
swapfree="$(free -m | grep ^Swap: | awk '{print $4}')"
swapusedpert="$(echo "scale=2; $swapused / $swaptotal * 100" | bc | awk -F "." '{print $1}')"
swapfreepert="$(echo "scale=2; $swapfree / $swaptotal * 100" | bc | awk -F "." '{print $1}')"
echo $(tput setaf 2)":Current MEM usage:"$(tput sgr 0)
echo $(tput setaf 2)"Total Memory:" $memtotal $(tput sgr 0)
echo $(tput setaf 2)"Used Memory:" $memused $(tput sgr 0)
echo $(tput setaf 2)"Free Memory:" $memfree $(tput sgr 0)
echo $(tput setaf 2)"Shared Memory:" $memshared $(tput sgr 0)
echo $(tput setaf 2)"Buff/Cache Memory:" $membuff $(tput sgr 0)
echo $(tput setaf 2)"Available Memory:" $memavail $(tput sgr 0)
echo $(tput setaf 2)"Used Memory %:" $memusedpert $(tput sgr 0)
echo $(tput setaf 2)"Available Memory %:" $memavailpert $(tput sgr 0)
echo $(tput setaf 2)"SWAP Total:" $swaptotal $(tput sgr 0)
echo $(tput setaf 2)"SWAP Used:" $swapused $(tput sgr 0)
echo $(tput setaf 2)"SWAP Free:" $swapfree $(tput sgr 0)
echo $(tput setaf 2)"SWAP Used %:" $swapusedpert $(tput sgr 0)
echo $(tput setaf 2)"SWAP Free %:" $swapfreepert $(tput sgr 0)
echo $(tput setaf 4)":MEM Health Report:" $(tput sgr 0)

if [[ $memavailpert -le 20 ]]
then
        echo $(tput setaf 1)"CRITICAL: Detected Low Available Memory"$(tput sgr 0)
        echo $(tput setaf 1)"Top 5 process by Memory usage"$(tput sgr 0)
        echo $(tput setaf 1)"$(ps -eo pmem,pcpu,vsize,pid,cmd | sort -k 1 -nr | head -5)"$(tput sgr 0)
fi
if [[ $memavailpert -le 40 ]] && [[ $memavailpert -gt 20 ]]
then
        echo $(tput setaf 3)"WARNING: Detected Low Available Memory"$(tput sgr 0)
        echo $(tput setaf 1)"Top 5 process by Memory usage"$(tput sgr 0)
        echo $(tput setaf 1)"$(ps -eo pmem,pcpu,vsize,pid,cmd | sort -k 1 -nr | head -5)"$(tput sgr 0)
fi
if [[ $memavailpert -gt 40 ]]
then
        echo $(tput setaf 2)"OK: Available Memory is ok."$(tput sgr 0)
fi

if [[ $swapfreepert -le 50 ]]
then
        echo $(tput setaf 1)"CRITICAL: Detected High SWAP usage"$(tput sgr 0)
        echo $(tput setaf 1)"Top 5 process by Memory usage"$(tput sgr 0)
        echo $(tput setaf 1)"$(ps -eo pmem,pcpu,vsize,pid,cmd | sort -k 1 -nr | head -5)"$(tput sgr 0)
fi
if [[ $swapfreepert -le 90 ]] && [[ $swapfreepert -gt 50 ]]
then
        echo $(tput setaf 3)"WARNING: Detected High SWAP usage"$(tput sgr 0)
        echo $(tput setaf 1)"Top 5 process by Memory usage"$(tput sgr 0)
        echo $(tput setaf 1)"$(ps -eo pmem,pcpu,vsize,pid,cmd | sort -k 1 -nr | head -5)"$(tput sgr 0)
fi
if [[ $swapfreepert -gt 90 ]]
then
        echo $(tput setaf 2)"OK: SWAP is ok."$(tput sgr 0)
fi
echo $(tput setaf 7)"#################################################################"$(tput sgr 0)
echo $(tput setaf 4)"Checking FileSystems Free Space..."$(tput sgr 0)
i='/'
filesystemtotal="$(df -m $i | awk '{print $2}' | tail -n1 | tr -d '%')"
filesystemused="$(df -m $i | awk '{print $3}' | tail -n1 | tr -d '%')"
filesystemfree="$(df -m $i | awk '{print $4}' | tail -n1 | tr -d '%')"
filesystemusedpert="$(df -m $i | awk '{print $5}' | tail -n1 | tr -d '%')"
if [[ $filesystemusedpert -gt 90 ]]
then
	echo $(tput setaf 1)"CRITICAL: Detected low free space on $i"$(tput sgr 0)
        df -H $i
else
	if [[ $filesystemusedpert -gt 75 ]]
        then
        	echo $(tput setaf 3)"WARNING: Detected low free space on $i"$(tput sgr 0)
                df -H $i
        else
                echo $(tput setaf 2)"OK: $i is ok for space."$(tput sgr 0)
        fi
fi
echo $(tput setaf 7)"#################################################################"$(tput sgr 0)
echo $(tput setaf 4)"Checking FileSystems for ReadOnly..."$(tput sgr 0)
i='/'
rootfs="$(df -i | awk '{print $6}' | tail -n1)"
if [[ "$i" == "/" ]]  && [[ "$os" == "CentOS" ]]
then
	filesystemrw="$(cat /etc/mtab | grep rootfs | awk '{print $4}' | awk -F ',' '{print $1}')"
else
        filesystemrw="$(cat /etc/mtab | grep $i' ' | awk '{print $4}' | awk -F ',' '{print $1}')"
fi
if [[ ! $filesystemrw == 'rw' ]]
then
	echo $(tput setaf 1)"CRITICAL: Detected ReadOnly FileSystem on $i"$(tput sgr 0)
else
        echo $(tput setaf 2)"OK: $i is ReadWrite."$(tput sgr 0)
fi
echo $(tput setaf 7)"#################################################################"$(tput sgr 0)
echo $(tput setaf 4)"::Rancher Server Info::"$(tput sgr 0)
rancherserverid="$(docker ps | grep -e 'rancher/server' -e 'rancher/enterprise' | awk '{print $1}')"
rancherservername="$(docker inspect -f '{{.Name}}' $rancherserverid | cut -c 2-)"
rancherserverip="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $rancherserverid)"
echo $(tput setaf 4)"Rancher Server ID: $rancherserverid"$(tput sgr 0)
echo $(tput setaf 4)"Rancher Server Name: $rancherservername"$(tput sgr 0)
echo $(tput setaf 4)"Rancher Server IP: $rancherserverip"$(tput sgr 0)
echo $(tput setaf 7)"#################################################################"$(tput sgr 0)
echo $(tput setaf 4)"Checking Rancher Server..."$(tput sgr 0)
rancherserverstatus="$(docker inspect -f "{{.State.Status}}" $rancherserverid)"
if [[ "$rancherserverstatus" == "running" ]]
then
	echo $(tput setaf 2)"OK: Rancher is running."$(tput sgr 0)
else
	echo $(tput setaf 1)"CRITICAL: Rancher is not running."$(tput sgr 0)
	exit 2
fi
rancherresponcecode="$(curl -s -o /dev/null -w '%{http_code}' 'http://'$rancherserverip':8080')"
if [[ "$rancherresponcecode" == "200" ]]
then
	echo $(tput setaf 2)"OK: Rancher is responding."$(tput sgr 0)
else
	echo $(tput setaf 1)"CRITICAL: Rancher is not responding."$(tput sgr 0)
fi
rancherresponcetime="$(curl -s -o /dev/null -w '%{time_total}' 'http://'$rancherserverip':8080')"
rancherresponcetimems="$(echo "$rancherresponcetime * 1000" | bc | awk -F "." '{print $1}')"
if [[ $rancherresponcetimems -gt 1000 ]]
then
	echo $(tput setaf 1)"CRITICAL: Rancher has responce of $rancherresponcetimems milliseconds."$(tput sgr 0)
fi
if [[ $rancherresponcetimems -le 1000 ]] && [[ $rancherresponcetimems -gt 100 ]]
then
	echo $(tput setaf 3)"WARNING: Rancher has responce of $rancherresponcetimems milliseconds."$(tput sgr 0)
fi
if [[ $rancherresponcetimems -le 100 ]]
then
        echo $(tput setaf 2)"OK: Rancher has responce of $rancherresponcetimems milliseconds."$(tput sgr 0)
fi
echo $(tput setaf 7)"#################################################################"$(tput sgr 0)
echo $(tput setaf 4)"Checking Rancher Database..."$(tput sgr 0)
DBConfig="$(docker inspect -f '{{.Config.Cmd}}' $rancherserverid)"
if [[ -z $DBConfig ]]
then
	echo $(tput setaf 4)"Rancher is using the internal database..."$(tput sgr 0)
	DBHOST="localhost"
	DBPORT="3306"
	DBUSER="cattle"
	DBPASS="cattle"
else
	echo $(tput setaf 4)"Rancher is using an External database..."$(tput sgr 0)
	DBHOST="$(docker inspect $rancherserverid | grep -A 1 '\-\-db-host' | tail -n1 | tr -d '", ')"
	DBPORT="$(docker inspect $rancherserverid | grep -A 1 '\-\-db-port' | tail -n1 | tr -d '", ')"
	if [[ -z $DBPORT ]]
	then
		DBPORT="3306"
	fi
	DBUSER="$(docker inspect $rancherserverid | grep -A 1 '\-\-db-user' | tail -n1 | tr -d '", ')"
	if [[ -z $DBUSER ]]
	then
		DBUSER="cattle"
	fi
	DBPASS="$(docker inspect $rancherserverid | grep -A 1 '\-\-db-pass' | tail -n1 | tr -d '", ')"
        if [[ -z $DBPASS ]]
        then
                DBPASS="cattle"
        fi
        DBNAME="$(docker inspect $rancherserverid | grep -A 1 '\-\-db-name' | tail -n1 | tr -d '", ')"
        if [[ -z $DBNAME ]]
        then
                DBNAME="cattle"
        fi
fi
if mysql -h $DBHOST -P $DBPORT -u $DBUSER -p"$DBPASS" $DBNAME -e "show tables" > /dev/null 2>&1
then
	echo $(tput setaf 2)"OK: Successfully connected to database"$(tput sgr 0)
else
	echo $(tput setaf 1)"CRITICAL: Can not connect to database"$(tput sgr 0)
fi
mysqlresponcetime="$({ time mysql -h $DBHOST -P $DBPORT -u $DBUSER -p"$DBPASS" $DBNAME -e "show tables" > /dev/null ; } |& grep real | sed -E 's/[^0-9\.]+//g' | tr -d '\n' | (cat && echo " * 1000") | bc | awk -F '.' '{print $1}')"
if [[ $mysqlresponcetime -gt 1000 ]]
then
	echo $(tput setaf 1)"CRITICAL: MySQL has responce of $mysqlresponcetime milliseconds."$(tput sgr 0)
fi
if [[ $mysqlresponcetime -le 1000 ]] && [[ $mysqlresponcetime -gt 100 ]]
then
        echo $(tput setaf 3)"WARNING: MySQL has responce of $mysqlresponcetime milliseconds."$(tput sgr 0)
fi
if [[ $mysqlresponcetime -le 100 ]]
then
	echo $(tput setaf 2)"OK: MySQL has responce of $mysqlresponcetime milliseconds."$(tput sgr 0)
fi
echo $(tput setaf 7)"#################################################################"$(tput sgr 0)
#echo $(tput setaf 4)"Please review the Docker logs listed below."$(tput sgr 0)
#docker logs --tail 100 $rancherserverid
