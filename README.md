# wireguard-configurator
Set of scripts to deploy wireguard and manage clients

## Usage

To create a new server configuration:
```
wireguard-configurator -n <server_name>
```
It will create a configuration at ```/tmp/wireguard```

To actually apply the configuration:
```
wireguard-configurator -i 
```

To add a new client:
```
wireguard-configurator -c <client_name>
```
This will create a new config set on ```/etc/wireguard/clients/<client_name>```


To display the configuration of the client in a QR on the terminal
```
wireguard-configurator -d <server_name>
```