#!/bin/bash

# Function to perform network scan
scan_network() {
  local is_private="$1"  # Optional argument, "y" for private network

  # Get IP address (assuming single interface)
  sudo ifconfig | grep "broadcast" | cut -d " " -f 10 | cut -d "." -f 1,2,3 | uniq > config.txt
  CON_LIST=($(cat config.txt))

  # Initialize counter
  local scan_count=0

  # Loop through each IP in the range (254 for private network, adjust for public)
  local start_ip=1
  local end_ip=254
  if [[ ! "$is_private" == "y" ]]; then
    # Adjust IP range for public network (replace with actual range if needed)
    start_ip=1
    end_ip=254
  fi

  echo ''> newconfig.txt
  echo "Please wait while the scan is performed..."

  for ip in $(seq $start_ip $end_ip); do
    # Increment counter and print progress
    scan_count=$((scan_count + 1))
    printf "Scanning IP  %s...(%d/%d)\r" "$CON_LIST.$ip" "$scan_count" "$end_ip"

    ping -c 1 "$CON_LIST.$ip" | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" >> newconfig.txt
  done
  echo -e "\n"
  echo > mac.txt
  echo > ports.txt
  echo "Below contains your network information...."
  echo "IP Address               MAC Address"
  # Read IP addresses from newconfig.txt and perform nmap scan
  while read ip; do
    if [ -z "$ip" ]  ; then
      continue
    fi
     MC="Not Available"
    MC=$(sudo nmap -sn $ip | grep "MAC")
    
    if [ -z "$MC" ]  ; then
      MC="Not Available"
    fi
    echo "$ip             $MC"
  done < newconfig.txt
  echo "Do You Want to show the ports of any IP Address? y/n"
  read choice
  if [[ "$choice" = 'y' ]] || [[ "$choice" = 'Y' ]]; then
    echo "Enter the Host ID of the IP Address (the last part of the IP Address):"
    read hostid
    hid=$CON_LIST.$hostid
    pot=$(sudo nmap -sS --top-ports 25 $hid)
    echo "Ports on this IP Address are: "
    echo "$pot"
  else 
    echo "Exiting..."
  fi
  cat mac.txt
}

# Welcome message and user input
figlet "Network Trailblazzer" -c
echo "This program requires root privilages."
echo "Welcome to Network Trailblazzer!"
echo "Are you on a Private Network  or Public Internet? y/n"
read ans

# Call scan_network function based on user input
if [ "$ans" == "y" ]; then
  scan_network "y"  # Pass "y" to indicate private network
else
  clear
fi
