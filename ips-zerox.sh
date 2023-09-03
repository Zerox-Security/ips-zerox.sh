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


# Ruta al archivo de reglas IPTables
RULES_FILE="/etc/iptables/rules.v4"

# Verifica si el archivo de reglas existe
if [ -f "$RULES_FILE" ]; then
  # Crea una copia de seguridad del archivo de reglas original
  cp "$RULES_FILE" "$RULES_FILE.bak"

  # Utiliza awk para eliminar las reglas duplicadas y guardar el resultado en un nuevo archivo temporal
  awk '!seen[$0]++' "$RULES_FILE" > "$RULES_FILE.tmp"

  # Reemplaza el archivo original con el archivo temporal
  mv "$RULES_FILE.tmp" "$RULES_FILE"

  echo "Reglas duplicadas eliminadas del archivo $RULES_FILE"
else
  echo "El archivo de reglas $RULES_FILE no existe."
fi


