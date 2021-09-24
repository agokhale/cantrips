#!/usr/bin/awk -f
#nmap -sn -n 192.168.1.0/24 | awk -f normalize_nmap.awk

#Nmap scan report for delerium (192.168.1.250)
#Host is up (0.0058s latency).
#MAC Address: EC:F4:BB:C0:48:04 (Dell)
#3Nmap scan report for kaylee (192.168.1.200)
#Host is up.

#-> 

#192.168.1.162   MAC Address: 50:C5:8D:A7:D6:40 (Juniper Networks)


/Nmap scan report for/ { 
	ip=$5
}

/MAC/ {
	printf ("%s\t%s\n", ip, $0);
}
	
