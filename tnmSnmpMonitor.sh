#!/bin/bash
#TNM Assignment "GROUP CA"
#Exercise #3: Development of a simple network management application
#start

while [ 1 ]
	do
		echo "Choose the options from the list and enter the respective number:
	1. Queries the SNMP agent running on your system and display your systems' details.
	2. Queries the SNMP agent running on your system periodically and display the statistics of the interfaces on your system.
	3. Allows the user to set thresholds for any statistical parameter"

		read option
		if [[ $option == 1 || $option == 2 || $option == 3 ]] ; then
			break
		else
			echo "!!Invalid Options!!..Choose the right option:"
		fi
	done

Q_D_SystemDetails(){
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
}

QP_D_statistics(){
	echo "Querying periodically and displaying the statistics of the interfaces on your system."
	echo "Enter the periodicity in seconds:"
	read period
	while [ 1 ]
	do
		uptime=`snmpget -v 1 -c public localhost 1.3.6.1.2.1.1.3.0 | cut -d')' -f2`
		echo "Uptime = $uptime"
		cpuIdle=`snmpget -v 1 -On -c public localhost 1.3.6.1.4.1.2021.11.11.0 | cut -d':' -f2`
		cpuSys=`snmpget -v 1 -On -c public localhost 1.3.6.1.4.1.2021.11.10.0 | cut -d':' -f2`
		cpuUser=`snmpget -v 1 -On -c public localhost 1.3.6.1.4.1.2021.11.9.0 | cut -d':' -f2`
		echo "CPU User = $cpuUser%"
		echo "CPU System = $cpuSys%"
		echo "CPU Idle = $cpuIdle%"
		echo
  		sleep $period;
	done
}

setThreshold(){
	echo "set thresholds for any statistical parameter.
	
Enter the statistical parameter:"
	read parameter
	echo "Entered statistical parameter is: $parameter"
	echo "Enter threshold:"
	read threshold
	echo "Entered threshold is :$threshold"
	while [ 1 ]
	do
		uptime=`snmpget -v 1 -c public localhost 1.3.6.1.2.1.1.3.0 | cut -d')' -f2`
		cpuIdle=`snmpget -v 1 -On -c public localhost 1.3.6.1.4.1.2021.11.11.0 | cut -d':' -f2`
		cpuSys=`snmpget -v 1 -On -c public localhost 1.3.6.1.4.1.2021.11.10.0 | cut -d':' -f2`
		cpuUser=`snmpget -v 1 -On -c public localhost 1.3.6.1.4.1.2021.11.9.0 | cut -d':' -f2`
		
		if [[ $parameter != "" ]] ; then
			paramVal=`snmpget -v 1 -On -c public localhost $parameter | cut -d':' -f2`
			if [[ $paramVal -ge $threshold ]] ; then
				echo "ALERT!! ALERT!! ALERT!!
				Uptime = $uptime
				CPU User = $cpuUser%
				CPU System = $cpuSys%
				CPU Idle = $cpuIdle%
				
				"
			fi
		fi
		sleep 3;
	done
}

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
