read -p "Do you want to monitor any parameter? [Y/N] " monitor
if [[ $monitor == "Y" || $monitor == "y" ]] ; then
  read -p "Enter parameter to monitor : " parameter
  read -p "Enter threshold : " threshold
fi

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
  if [[ $parameter != "" ]] ; then
    paramVal=`snmpget -v 1 -On -c public localhost $parameter | cut -d':' -f2`
    if [[ $paramVal -ge $threshold ]] ; then
      echo "ALERT!! ALERT!! ALERT!!"
      echo
    fi
  fi
  sleep 5;
done
