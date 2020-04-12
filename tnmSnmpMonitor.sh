#!/bin/bash
#TNM Assignment "GROUP CA"
#Exercise #3: Development of a simple network management application
#start

finish() {
	# Your cleanup code here
	echo
	echo "Thanks for using TNM SNMP MONITOR"
	killall tnmSnmpMonitor.sh
}
trap finish EXIT

showTitle(){
	clear
	echo; echo; echo
	COLUMNS=$(tput cols) 
	title="TNM SNMP MONITOR"
	printf "%*s\n" $(((${#title}+$COLUMNS)/2)) "$title"
	title="================"
	printf "%*s\n" $(((${#title}+$COLUMNS)/2)) "$title"
}


selectOption(){
	case $option in
		1)
			Q_D_SystemDetails
			;;
		2)
			QP_D_statistics
			;;
		3)
			setThreshold
			;;
		*)
			echo "!!invalid option!!"
			;;
	esac
}


Q_D_SystemDetails(){
	showTitle
	echo "Querying and displaying systems details."
	uptime=`snmpget -v 1 -c public localhost 1.3.6.1.2.1.1.3.0 | cut -d')' -f2`
	echo "Uptime = $uptime"
	cpuIdle=`snmpget -v 1 -On -c public localhost 1.3.6.1.4.1.2021.11.11.0 | cut -d':' -f2`
	cpuSys=`snmpget -v 1 -On -c public localhost 1.3.6.1.4.1.2021.11.10.0 | cut -d':' -f2`
	cpuUser=`snmpget -v 1 -On -c public localhost 1.3.6.1.4.1.2021.11.9.0 | cut -d':' -f2`
	echo "CPU User = $cpuUser%"
	echo "CPU System = $cpuSys%"
	echo "CPU Idle = $cpuIdle%"

	echo
	echo "Press any key to go back to menu" 
	read -n1
}

QP_D_statistics(){
	showTitle
	echo "Querying periodically and displaying the statistics of the interfaces on your system."
	echo "Enter refresh interval in seconds : "
	read period
	while [ 1 ]
	do
		showTitle
		snmpwalk -v 2c -c public localhost 1.3.6.1.2.1.2
		echo
		echo Press any key to go back to menu
		read -t $period -n1 
		if [[ $? == 0  ]] ; then 
			break
		fi
	done
}

monitorOID(){
	parameter=$1
	threshold=$2
	while [ 1 ] 
	do
		if [[ $parameter != "" ]] ; then
			paramVal=`snmpget -v 1 -Oqv -c public localhost $parameter`
			if [[ $paramVal -ge $threshold ]] ; then
				echo ALERT!!
				echo "Value of $parameter exceeded the threshold $threshold"
			fi
		else 
			echo Please enter OID to monitor
			break
		fi
		sleep 3
	done
}

setThreshold(){
	showTitle
	echo -n "Set thresholds for any statistical parameter.
	
Enter the statistical parameter : "
	read parameter
	echo -n "Enter threshold for Alert : "
	read threshold
	monitorOID $parameter $threshold &
	echo "Parameter $parameter is being monitored. Press any key to return to main menu"
	read -n1
}

while [ 1 ]
do
	showTitle
	echo "
	Choose the options from the list and enter the respective number:
		1. Show system details
		2. Monitor interface statistics
		3. Setup threshold alert

		Press 'Q' to quit application"

	read -n1 option
	echo
	if [[ $option == 1 || $option == 2 || $option == 3 ]] ; then
		selectOption
	elif [[ $option == 'q' || $option == 'Q'  ]] ; then
		break
	else
		echo "!!Invalid Option!!..Choose the right option:"
	fi
done
