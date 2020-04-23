#!/bin/bash
# Author: Eduardo Marossi <eduardom44@gmail.com>
# Version: 1.0.0

# Adjust the following if necessary
IPP_FILE="/var/log/openvpn/ipp.txt" # ipp file (OpenVPN)
OPENCA_DIR="/home/ubuntu/openvpn-ca/"
MAKE_CONFIG_SCRIPT="/home/ubuntu/client-configs/make_config.sh" ## https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-16-04
CONFIGS_FOLDER="/home/ubuntu/client-configs/files"
VPN_SERVER_IP="10.8.0.1"

## DO NOT CHANGE (ONLY DO IF YOU KNOW WHAT ARE YOU DOING)
IFS=',' # comma is set as delimiter
cd $OPENCA_DIR
source vars

read -p 'Create CCD folder and config file (static ip) for every certificate? Will use ipp.txt [y or empty for N]:  ' ccd
if [ -n "$ccd" ]
then
    [ "$UID" -eq 0 ] || { echo "This script must be run as root."; exit 1;}
    sudo mkdir /etc/openvpn/ccd
    sudo chown -R nobody:nogroup /etc/openvpn/ccd
    echo "Sucessfully created CCD directory. Please enable client-config-dir at OpenVPN config and restart service. "
fi


while IFS= read -r line
do
  if [[ $line == *"#"* ]]; then
      echo "Skipping comment $line"
  elif [[ $line == *","* ]]; then
      read -ra IP <<< "$line" # line is read into an array as tokens separated by IFS
      echo "Checking if certificate exists for ${IP[0]}"
      if [ ! -f keys/${IP[0]}.crt ]; then
        echo "Missing certificate, creating..."
        (echo -en "\n\n\n\n\n\n\n\n"; sleep 1; echo -en "\n"; sleep 1; echo -en "\n"; sleep 3; echo -en "yes"; echo -en "\n"; sleep 3; echo -en "yes"; echo -en "\n") | ./build-key ${IP[0]}
      fi  
      if [ ! -f $CONFIGS_FOLDER/${IP[0]}.ovpn ]; then
        echo "Missing config for client, creating..."
        $MAKE_CONFIG_SCRIPT ${IP[0]}
      fi 
      if [ -n "$ccd" ]
      then
        [ "$UID" -eq 0 ] || { echo "This script must be run as root."; exit 1;}
        if [ ! -f /etc/openvpn/ccd/${IP[0]} ]; then
            echo "Missing static ip config for client, creating..."
            sudo echo "ifconfig-push ${IP[1]} $VPN_SERVER_IP" > /etc/openvpn/ccd/${IP[0]}
        fi 
      fi 
      echo "Client ${IP[0]} is ready. Copy config from $CONFIGS_FOLDER/${IP[0]}"
  fi
done < "$IPP_FILE"