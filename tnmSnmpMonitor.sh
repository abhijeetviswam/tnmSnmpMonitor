#! /bin/bash
#TNM Assignment "GROUP CA"
#Exercise #3: Development of a simple network management application
#start

finish() {
	# Your cleanup code here
	showTitle
	echo
	COLUMNS=$(tput cols)
	credits="*************************************"
	printf "%*s\n" $(((${#credits}+$COLUMNS)/2)) "$credits"
	credits="* Thanks for using TNM SNMP MONITOR *"
	printf "%*s\n" $(((${#credits}+$COLUMNS)/2)) "$credits"
	credits="*************************************"
	printf "%*s\n" $(((${#credits}+$COLUMNS)/2)) "$credits"
	credits="*           Developed By            *"
	printf "%*s\n" $(((${#credits}+$COLUMNS)/2)) "$credits"
	credits="*   Abhijeet Viswam - 2019HT12228   *"
	printf "%*s\n" $(((${#credits}+$COLUMNS)/2)) "$credits"
	credits="*   Vella Venkaesh  - 2019HT12186   *"
	printf "%*s\n" $(((${#credits}+$COLUMNS)/2)) "$credits"
	credits="*   Rahul Kushwaha  - 2019HT66508   *"
	printf "%*s\n" $(((${#credits}+$COLUMNS)/2)) "$credits"
	credits="*************************************"
	printf "%*s\n" $(((${#credits}+$COLUMNS)/2)) "$credits"

	sleep 5
	pkill -s 0
}

#Cleanup on exit
trap finish EXIT

showTitle(){
	#clear screen and prevent scrollback
	clear && printf '\e[3J'
	echo; echo
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

	ifTotalNum=`snmpget -v 2c -Oqv -c public localhost 1.3.6.1.2.1.2.1.0`
	echo -e "\nAvailable interfaces :"
	for (( i=1; i<=$ifTotalNum; i++ ))
	do
		ifDescr=`snmpget -v 2c -Oqv -c public localhost 1.3.6.1.2.1.2.2.1.2.$i`
		echo "$i. $ifDescr"
	done
	echo -en "\nSelect interface to query : "
	read ifIndex
	re='^[0-9]+$'
	if [[ $ifIndex == "" ]] ; then
		echo -e "No input provided. Selecting interface numbered 1 by default\n"
		ifIndex=1
	elif ! [[ $ifIndex =~ $re ]] ; then
		echo "error: Not a number"; 
		read -n1
		return
	elif [[ $ifIndex -gt $ifTotalNum ]] ; then
		echo selected index out of range
		read -n1 
		return
	fi
	echo -n "Enter refresh interval in seconds (default 10 seconds) : "
	read period
	if [[ $period == "" ]] ; then 
		period=10
	fi
	toggleStats=0
	while [ 1 ]
	do
		showTitle
		echo -e "Values are refreshed every $period seconds\n"
		if [[ $toggleStats == 1 ]] ; then
			echo "Full Interface Statistics"
			echo "-------------------------"
			snmpwalk -v 2c -c public localhost 1.3.6.1.2.1.2
		else
			echo "Essential Interface Statistics"
			echo "------------------------------"
			ifDescr=`snmpget -v 2c -Oqv -c public localhost 1.3.6.1.2.1.2.2.1.2.$ifIndex`
			echo -e "Description              (OID : 1.3.6.1.2.1.2.2.1.2.$ifIndex)\t: $ifDescr"
			ifType=`snmpget -v 2c -Oqv -c public localhost 1.3.6.1.2.1.2.2.1.3.$ifIndex`
			echo -e "Type                     (OID : 1.3.6.1.2.1.2.2.1.3.$ifIndex)\t: $ifType"
			ifOperStatus=`snmpget -v 2c -Ovq -c public localhost 1.3.6.1.2.1.2.2.1.8.$ifIndex`
			echo -e "Operation status         (OID : 1.3.6.1.2.1.2.2.1.8.$ifIndex)\t: $ifOperStatus"
			echo
			ifInUcastPkts=`snmpget -v 2c -Ovq -c public localhost 1.3.6.1.2.1.2.2.1.11.$ifIndex`
			echo -e "Unicast packets - IN     (OID : 1.3.6.1.2.1.2.2.1.11.$ifIndex)\t: $ifInUcastPkts"
			ifInNUcastPkts=`snmpget -v 2c -Ovq -c public localhost 1.3.6.1.2.1.2.2.1.12.$ifIndex`
			echo -e "NonUnicast packets - IN  (OID : 1.3.6.1.2.1.2.2.1.12.$ifIndex)\t: $ifInNUcastPkts"
			ifInDiscards=`snmpget -v 2c -Ovq -c public localhost 1.3.6.1.2.1.2.2.1.13.$ifIndex`
			echo -e "Discarded packets - IN   (OID : 1.3.6.1.2.1.2.2.1.13.$ifIndex)\t: $ifInDiscards"
			ifInErrors=`snmpget -v 2c -Ovq -c public localhost 1.3.6.1.2.1.2.2.1.14.$ifIndex`
			echo -e "Error packets - IN       (OID : 1.3.6.1.2.1.2.2.1.14.$ifIndex)\t: $ifInErrors"
			echo
			ifOutUcastPkts=`snmpget -v 2c -Ovq -c public localhost 1.3.6.1.2.1.2.2.1.17.$ifIndex`
			echo -e "Unicast packets - OUT    (OID : 1.3.6.1.2.1.2.2.1.17.$ifIndex)\t: $ifOutUcastPkts"
			ifOutNUcastPkts=`snmpget -v 2c -Ovq -c public localhost 1.3.6.1.2.1.2.2.1.18.$ifIndex`
			echo -e "NonUnicast packets - OUT (OID : 1.3.6.1.2.1.2.2.1.18.$ifIndex)\t: $ifOutNUcastPkts"
			ifOutDiscards=`snmpget -v 2c -Ovq -c public localhost 1.3.6.1.2.1.2.2.1.19.$ifIndex`
			echo -e "Discarded packets - OUT  (OID : 1.3.6.1.2.1.2.2.1.19.$ifIndex)\t: $ifOutDiscards"
			ifOutErrors=`snmpget -v 2c -Ovq -c public localhost 1.3.6.1.2.1.2.2.1.20.$ifIndex`
			echo -e "Error packets - OUT      (OID : 1.3.6.1.2.1.2.2.1.20.$ifIndex)\t: $ifOutErrors"

		fi
		echo
		echo "Press 'T' to toggle between essential interface statistics and full interface statistics"
		echo Press any other key to go back to menu
		read -t $period -n1 isTpressed
		if [[ $? == 0  ]] ; then 
			if [[ $isTpressed == 't' || $isTpressed == 'T' ]] ; then
				if [[ $toggleStats == '0' ]] ; then
					toggleStats=1
				else
					toggleStats=0
				fi
			else
				break
			fi
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
