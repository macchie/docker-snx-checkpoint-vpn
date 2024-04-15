#!/bin/bash

#    Copyright 2019 Kedu S.C.C.L.
#
#    This file is part of Docker-snx-checkpoint-vpn.
#
#    Docker-snx-checkpoint-vpn is free software: you can redistribute it
#    and/or modify it under the terms of the GNU General Public License
#    as published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    Docker-snx-checkpoint-vpn is distributed in the hope that it will be
#    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Docker-snx-checkpoint-vpn. If not, see
#    <http://www.gnu.org/licenses/>.
#
#    info@kedu.coop

server=$SNX_SERVER
user=$SNX_USER
password=$SNX_PASSWORD
certificate_path="/certificate.p12"

# Function to perform cleanup or other commands when SIGTERM is received
handle_sigterm() {
    echo -e "\nReceived SIGTERM, disconnecting SNX Client..."
    snx -d
    exit 0
}

# Function to perform cleanup or other commands when SIGTERM is received
handle_sigkill() {
    echo -e "\nReceived SIGKILL, disconnecting SNX Client..."
    snx -d
    exit 0
}

# Trap SIGTERM
trap 'handle_sigterm' SIGTERM
trap 'handle_sigkill' SIGKILL

snx -d

if [ -f "$certificate_path" ]; then
    if [ ! -z "$user" ]; then
        echo -e "$SNX_PASSWORD\ny" | snx -g -s $server -u $user -c $certificate_path
    else
        echo -e "$SNX_PASSWORD\ny" | snx -g -s $server -c $certificate_path
    fi
else
    echo -e "$SNX_PASSWORD\ny" | snx -g -s $server -u $user
fi

echo -e "\n"

VPN_IP_ADDRESS=$(ip -4 addr show tunsnx | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Check if we successfully got the IP
if [ -z "$VPN_IP_ADDRESS" ]; then
    echo "No IP address found for interface tunsnx."
    snx -d
    exit 0
else
    echo "IP address of tunsnx is $VPN_IP_ADDRESS"
fi

# iptables -t nat -A POSTROUTING -o tunsnx -j MASQUERADE
iptables -t nat -A POSTROUTING -o tunsnx -j SNAT --to-source $VPN_IP_ADDRESS
iptables -A FORWARD -i eth0 -j ACCEPT

/bin/bash
