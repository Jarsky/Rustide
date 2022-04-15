iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 28016 -j ACCEPT
iptables -A INPUT -p udp --dport 28015 -j ACCEPT
iptables -I INPUT 1 -i lo -j ACCEPT
iptables -P INPUT ACCEPT
iptables -A INPUT -j DROP
apt-get install iptables-persistent -y
invoke-rc.d iptables-persistent save