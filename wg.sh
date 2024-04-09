#!/bin/sh


key="#INSERT YOUR KEY HERE"
secret="#INSERT YOUR SERCRET HERE"

# Generate the public key from the private key for your wireguard client
wg genkey | tee privatekey | wg pubkey > publickey

private_key=$(cat privatekey)
public_key=$(cat publickey)

# Get the client/server information

read -p "Please enter the client's IP address (example: 10.10.10.X/32): " address
read -p "Enter the name of the client: " name
read -p "Enter your OPNsense web interface address: (example: opnsense.home.com): " opnsense_address
read -p "Enter your preferred DNS server: " dns
read -p "Enter your wireguard port (default: 51820) : " wg_port

get_srv_uuid() {
  curl -s -X POST -u "$key:$secret" -H "Content-Type: application/json" -d '{"current":1,"rowCount":7,"sort":{},"searchPhrase":""}' https://$opnsense_address/api/wireguard/server/searchServer 
}

srv_uuid=$(get_srv_uuid | jq -r '.rows[].uuid') 

get_peer_public_key() {
  curl -s -u "$key:$secret" https://$opnsense_address/api/wireguard/server/getServer/$srv_uuid
}

# wg client configuration: 
peer_public_key=$(get_peer_public_key | jq -r '.[].pubkey')
allowed_ips="0.0.0.0/0"   # This currently allows all traffic, you can edit this 
endpoint="ip:port"        # Edit this with your wireguard's public ip and port

# Create the WireGuard configuration file
cat <<EOF > wg1.conf
[Interface]
PrivateKey = $private_key
Address = $address
DNS = $dns

[Peer]
PublicKey = $peer_public_key
AllowedIPs = $allowed_ips
Endpoint = $endpoint
EOF

# Create the JSON configuration for your client 
cat <<EOF > opnsense_config.json
{
  "client": {
    "enabled": "1",
    "name": "$name",
    "pubkey": "$public_key",
    "tunneladdress": "$address",
    "persistentkeepalive": "25",
    "serverport": "$wg_port"       
  }
}
EOF


get_clients_uuid() {
  curl -s -X POST -u "$key:$secret" -H "Content-Type: application/json" -d '{"current":1,"rowCount":7,"sort":{},"searchPhrase":""}' https://$opnsense_address/api/wireguard/client/searchClient
}
client_uuid=$(get_clients_uuid | jq -r '.rows[].uuid' | awk 'NR > 1 { printf(",") } {printf "%s",$0}')

run() {
  curl -s -X POST -u "$key:$secret" -H "Content-Type: application/json" -d @opnsense_config.json https://$opnsense_address/api/wireguard/client/addClient 
}

uuid=$(run | jq -r '.uuid')

cat <<EOF > opnsense_serverconfig.json

{"server":{"enabled":"1","peers": "$uuid,$client_uuid"}}

EOF

curl -s -X POST -u "$key:$secret" -H "Content-Type: application/json" -d @opnsense_serverconfig.json https://$opnsense_address/api/wireguard/server/setServer/$srv_uuid &> /dev/null 
curl -s -X POST -u "$key:$secret" -H "Content-Type: application/json" -d '{}' https://$opnsense_address/api/wireguard/service/reconfigure 

rm *key opnsense* 
