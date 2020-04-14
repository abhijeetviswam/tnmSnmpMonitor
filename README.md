


# tnmSnmpMonitor
A simple SNMP based system monitoring tool

### PreRequisites
- SNMP daemon `snmpd` should be configured and running in the device 
- readonly community "public" should be configured to be accessible via localhost

Please follow the following instructions to set up snmpd correctly in your system

1. Install `snmpd` on the device. Instructions provided are for ubuntu/debian OS
	```bash
   sudo apt update
   sudo apt install snmpd
   ```
3. Backup existing snmpd configuration
	```bash
	mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf_original
	```
 3. Create the file **/etc/snmp/snmp.conf**  and include the following line:
	```bash
    rocommunity public
    ```
4. Restart the SNMP service with the following command:
	```bash
   /etc/init.d/snmpd restart
   ```
5. After restarting SNMP service, perform a local test to verify that SNMP is running:
	```bash
	snmpwalk -v 1 -c public localhost sysname
	```
### Instructions for using the App
We developed the app as an executable bash script. No compilation is required.
- Execute the script `tnmSnmpMonitor.sh`
	```bash
	./tnmSnmpMonitor.sh
	```
- Select the necessary option from the menu\
	`1. Show system details` :\
	Queries the SNMP agent running on your system and display your systems' details\
	Details are fetched from the SNMP system subtree - 1.3.6.1.2.1.1
	
	`2. Monitor Interface statistics` :\
	Queries the SNMP agent running on your system periodically and display the statistics of the interfaces on your system\
	All interfaces available on the device are listed. Choose the interface you're interested in and set the `refreshInterval`. The values are refreshed every `refreshInterval` seconds
	
	`3. Setup threshold alert` : Allows the user to set thresholds for any statistical parameter. If the threshold is exceeded, the user is provided an Alert regarding this.\
	You can list the interfaces available and select the statistic you're interested to monitor \
	Alternately, You can monitor any OID with this tool. But please use only numeric type OID's like INTEGER or Counter32. Providing other types like STRING can cause the tool to misbehave.
	
