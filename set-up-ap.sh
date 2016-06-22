#!/bin/bash

APPASS="chrisiscool123"
APSSID="rPi3"


apt-get remove --purge hostapd -y
apt-get install hostapd dnsmasq -y

cat > /etc/dnsmasq.conf <<EOF
interface=wlan0
dhcp-range=10.0.0.2,10.0.0.5,255.255.255.0,12h
EOF

cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
hw_mode=g
channel=1
#auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
#wpa_pairwise=CCMP
#rsn_pairwise=CCMP
wpa_passphrase=$APPASS
ssid=$APSSID
EOF

sed -i -- 's/exit 0/ /g' /etc/rc.local

cat >> /etc/rc.local <<EOF
ifconfig wlan0 down
ifconfig wlan0 10.0.0.1 netmask 255.255.255.0 up
iwconfig wlan0 power off
service dnsmasq restart
hostapd -B /etc/hostapd/hostapd.conf & > /dev/null 2>&1
exit 0
EOF

#Forward Traffic
cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF


sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE


echo "All done!"