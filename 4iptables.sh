#!/bin/bash
#By krabelize | cryptsus.com
#Persistent IPv4 iptables firewall script
LOOPBACK="127.0.0.0/8"
NIC_DATA="eth0"
NIC_MGMT="eth0"
SERVER_IP_DATA=$(hostname -I | awk '{print $1}')
SERVER_IP_MGMT=$(hostname -I | awk '{print $1}')
LOCAL_NETWORK="192.168.1.1/24"
DNS1="1.1.1.1"
DNS2="8.8.8.8"

#Reset all IPv4 iptables rules
iptables -F
iptables -X

#Disallowing any IPv4 traffic as deny any any 
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

#Allow loopback connections but block remote packets claming to be from the loopback interface
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -s $LOOPBACK ! -i lo -j DROP

#Drop invalid packets 
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

################
#INPUT rules   #
################
#Allow incoming OpenVPN connections to this host
iptables -A INPUT -i $NIC_MGMT -p udp -s 0/0 -d $SERVER_IP_MGMT --sport 32768:65535 --dport 1194 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o $NIC_MGMT -p udp -s $SERVER_IP_MGMT -d 0/0 --sport 1194 --dport 32768:65535 -m state --state ESTABLISHED -j ACCEPT

#################
#OUTPUT rules   #
#################
#Allow outgoing SSH sessions
iptables -A OUTPUT -o $NIC_DATA -p tcp -s $SERVER_IP_DATA -d 0/0 --sport 32768:65535 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i $NIC_DATA -p tcp -d $SERVER_IP_DATA -s 0/0 --sport 22 --dport 32768:65535 -m state --state ESTABLISHED -j ACCEPT

#Allow outgoing DNS lookups 
iptables -A OUTPUT -o $NIC_DATA -p udp -s $SERVER_IP_DATA -d $DNS1 --sport 32768:65535 --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i $NIC_DATA -p udp -s $DNS1 -d $SERVER_IP_DATA --sport 53 --dport 32768:65535 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o $NIC_DATA -p udp -s $SERVER_IP_DATA -d $DNS2 --sport 32768:65535 --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i $NIC_DATA -p udp -s $DNS2 -d $SERVER_IP_DATA --sport 53 --dport 32768:65535 -m state --state ESTABLISHED -j ACCEPT

#Allow outgoing ICMP ping requests
iptables -A OUTPUT -o $NIC_DATA -p icmp --icmp-type 8 -s $SERVER_IP_DATA -d 0/0 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i $NIC_DATA -p icmp --icmp-type 0 -d $SERVER_IP_DATA -s 0/0 -m state --state ESTABLISHED -j ACCEPT

#Allow outgoing HTTP(S) sessions for apt-get update and wget
iptables -A OUTPUT -o $NIC_DATA -p tcp -m tcp -s $SERVER_IP_DATA --sport 32768:65535 -d 0/0 --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i $NIC_DATA -p tcp -s 0/0 -d $SERVER_IP_DATA --sport 80 --dport 32768:65535 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o $NIC_DATA -p tcp -m tcp -s $SERVER_IP_DATA --sport 32768:65535 -d 0/0 --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i $NIC_DATA -p tcp -s 0/0 -d $SERVER_IP_DATA --sport 443 --dport 32768:65535 -m state --state ESTABLISHED -j ACCEPT	

#Allow DHCP handshakes for dynamic network settings
iptables -A OUTPUT -o $NIC_DATA -p udp -s $SERVER_IP_DATA -d 0/0 --sport 32768:65535 --dport 68 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i $NIC_DATA -p udp -d $SERVER_IP_DATA -s 0/0 --sport 68 --dport 32768:65535 -m state --state ESTABLISHED -j ACCEPT

#Allow outgoing NTP for time sync
iptables -A OUTPUT -o $NIC_DATA -p udp -s $SERVER_IP_DATA -d 0/0 --sport 32768:65535 --dport 123 -m state --state NEW -j ACCEPT
iptables -A INPUT -i $NIC_DATA -p udp -d $SERVER_IP_DATA -s 0/0 --sport 123 --dport 32768:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT

#Make sure nothing else goes IN or OUT from this host
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP

#Save IPv4 iptables config
##iptables4.rules should be executed on boot by modifying /etc/network/if-pre-up.d/iptables
sudo sh -c "iptables-save > /sbin/scripts/iptables4.rules"
