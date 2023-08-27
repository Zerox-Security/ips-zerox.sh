#!/bin/bash

# Descargar la lista de IPs desde la URL de Cloudflare
IPS_URL="https://www.cloudflare.com/ips-v4"
TMP_FILE="/etc/iptables/zerox_ips.txt"
wget -q -O "$TMP_FILE" "$IPS_URL"

# Limpiar las reglas de iptables existentes

iptables -P INPUT ACCEPT

# Agregar reglas para las IPs de Cloudflare
while read -r ip; do
    iptables -A INPUT -s "$ip" -p tcp -m multiport --dports 80,443 -j ACCEPT
done < "$TMP_FILE"

# Reglas de bloqueo
iptables -A INPUT -p tcp -m tcp --tcp-flags SYN,ACK SYN,ACK -m state --state NEW -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,ACK,URG -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,RST FIN,RST -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,ACK FIN -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags PSH,ACK PSH -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags ACK,URG URG -j DROP

# Guardar las reglas en iptables
iptables-save > /etc/iptables/rules.v4


