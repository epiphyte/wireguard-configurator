#!/bin/bash

###################################################################                                             
# Copyright (c) Epiphyte LLC 2022. All Rights Reserved.
# Author       	    :Fernandez-Alcon, Jose                
# Email         	:jose@epiphyte.io
# Date          	:2022-Feb-18
# Version       	:0.1.0
# 
# Description   	: Deploys wireguard in a new server
#                                         
# Usage         	: wireguard-deploy.sh
#
# History
###################################################################
version="0.1.0"

TMPDIR="/tmp/wireguard"



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