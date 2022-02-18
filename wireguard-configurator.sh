#!/bin/bash

###################################################################                                             
# Copyright (c) Epiphyte LLC 2022. All Rights Reserved.
# Author       	    :Fernandez-Alcon, Jose                
# Email         	:jose@epiphyte.io
# Date          	:2022-Feb-18
# Version       	:0.2.0
# 
# Description   	: Deploys wireguard in a new server
#                                         
# Usage         	: wireguard-deploy.sh
#
# History
###################################################################
version="0.2.0"

TMPDIR="/tmp/wireguard"



generate_new_configuration() {
    #Generating a new server key pair
    echo "Generating a new server key at $TMPDIR"
    rm -rf $TMPDIR
    mkdir $TMPDIR
    wg genkey | tee $TMPDIR/privatekey | wg pubkey > $TMPDIR/publickey

    SERVER_PRIVATE_KEY=$(cat $TMPDIR/privatekey)
    SERVER_PUBLIC_KEY=$(cat $TMPDIR/publickey)

    #Generate server configuration
    echo "Generating server configuration"
    server_private_key=$SERVER_PRIVATE_KEY envsubst < wg0.conf.template > $TMPDIR/wg0.conf

    #client
    echo "10" > $TMPDIR/client_number
    echo $1 > $TMPDIR/server_address
}


install_configuration() {
    echo "Installing wireguard"
    sudo cp -pr $TMPDIR/* /etc/wireguard/
    sudo systemctl start wg-quick@wg0
}


new_client() {
    
    mkdir -p /etc/wireguard/clients/$1
    #Generate client key pair
    echo "Generating a new client key pair"
    wg genkey | sudo tee /etc/wireguard/clients/$1/"$1".key | wg pubkey | sudo tee /etc/wireguard/clients/$1/"$1".key.pub
    
    #Client Variables
    SERVER_ADDRESS=$(cat /etc/wireguard/server_address)
    CLIENT_NUMBER=$(cat /etc/wireguard/client_number)
    CLIENT_PRIVATE_KEY=$(cat /etc/wireguard/clients/$1/"$1".key)
    CLIENT_PUBLIC_KEY=$(cat /etc/wireguard/clients/$1/"$1".key.pub)
    SERVER_PUBLIC_KEY=$(cat /etc/wireguard/publickey)

    #Generating client configuration
    server_address=$SERVER_ADDRESS server_public_key=$SERVER_PUBLIC_KEY client_private_key=$CLIENT_PRIVATE_KEY  client_number=$CLIENT_NUMBER envsubst < client.conf.template > /etc/wireguard/clients/$1/client.conf

    #Adding configuration to server
    echo "Adding client configuration to server"
    # sudo wg set wg0 peer $CLIENT_PUBLIC_KEY endpoint $SERVER_ADDRESS:51820 allowed-ips 10.0.0.0/24, 0.0.0.0/0
    client_name=$S1 client_public_key=$CLIENT_PUBLIC_KEY  client_number=$CLIENT_NUMBER envsubst < client-wg0.conf.template >> /etc/wireguard/wg0.conf

    #Incrementing client number
    echo $(($CLIENT_NUMBER+1)) > /etc/wireguard/client_number

    #Restarting server
    echo "Restarting WireGuard Server"
    sudo systemctl restart wg-quick@wg0
}


display_client_qr() {
    echo "Displaying QR code"
    qrencode -t ansiutf8 < /etc/wireguard/clients/$1/client.conf
}


#!/bin/bash
while getopts "n:ic:d:" optname
  do
    case "$optname" in
      "n")
        generate_new_configuration $OPTARG
        ;;
      "i")
        install_configuration
        ;;
      "c")
        new_client $OPTARG
        ;;
      "d")
        display_client_qr $OPTARG
        ;;        
      "?")
        echo "Unknown option $OPTARG"
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        ;;
      *)
      # Should not occur
        echo "Unknown error while processing options"
        ;;
    esac
    echo "OPTIND is now $OPTIND"
  done

