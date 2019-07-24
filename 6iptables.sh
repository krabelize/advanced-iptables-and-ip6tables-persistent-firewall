#!/bin/bash
#By krabelize | cryptsus.com
#Persistent IPv6 iptables firewall script

#Reset all IPv6 iptables rules
ip6tables -F
ip6tables -X

#Disallowing any IPv6 traffic as deny any any 
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT DROP

ip6tables -A INPUT -s ::1/128 ! -i lo -j DROP

#Save IPv6 iptables config
sudo sh -c "ip6tables-save > /sbin/scripts/iptables6.rules"
