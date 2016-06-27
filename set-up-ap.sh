#!/usr/bin/env bash

#Based on this guide:
#https://frillip.com/using-your-raspberry-pi-3-as-a-wifi-access-point-with-hostapd/

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi



#Installs Software for Access Point, DHCP, DNS
sudo apt-get remove --purge hostapd -y
sudo apt-get remove --purge dnsmasq -y
sudo apt-get install dnsmasq hostapd -y

#Append File to stop DHCP on wlan0
grep -q -F 'denyinterfaces wlan0' /etc/dhcpcd.conf || echo 'denyinterfaces wlan0' >> /etc/dhcpcd.conf

#Comment out the wpa-conf
#sudo sed -e '/wpa-conf \/etc\/wpa_supplicant\/wpa_supplicant.conf/ s/^#*/#/' -i /etc/network/interfaces

echo "# interfaces(5) file used by ifup(8) and ifdown(8)

# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'

# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

iface eth0 inet manual

allow-hotplug wlan0  
iface wlan0 inet static  
    address 172.24.1.1
    netmask 255.255.255.0
    network 172.24.1.0
    broadcast 172.24.1.255
#    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf


allow-hotplug wlan1
iface wlan1 inet manual
#    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
" > /etc/network/interfaces


sudo service dhcpcd restart
sudo ifdown wlan0
sudo ifup wlan0




echo "Type the name of your SSID, followed by [ENTER]:"
read ssid
echo "Type the password of Access Point (Use 8 Characters), followed by [ENTER]:"
read -s password

sudo echo "# This is the name of the WiFi interface we configured above
interface=wlan0

# Use the nl80211 driver with the brcmfmac driver
driver=nl80211

# This is the name of the network
ssid=$ssid

# Use the 2.4GHz band
hw_mode=g

# Use channel 6
channel=6

# Enable 802.11n
ieee80211n=1

# Enable WMM
wmm_enabled=1

# Enable 40MHz channels with 20ns guard interval
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]

# Accept all MAC addresses
macaddr_acl=0

# Use WPA authentication
auth_algs=1

# Require clients to know the network name
ignore_broadcast_ssid=0

# Use WPA2
wpa=2

# Use a pre-shared key
wpa_key_mgmt=WPA-PSK

# The network passphrase
wpa_passphrase=$password

# Use AES, instead of TKIP
rsn_pairwise=CCMP" > /etc/hostapd/hostapd.conf

sudo echo "interface=wlan0      # Use interface wlan0  
listen-address=172.24.1.1 # Explicitly specify the address to listen on  
bind-interfaces      # Bind to the interface to make sure we aren't sending things elsewhere  
server=8.8.8.8       # Forward DNS requests to Google DNS  
domain-needed        # Don't forward short names  
bogus-priv           # Never forward addresses in the non-routed address spaces.  
dhcp-range=172.24.1.10,172.24.1.240,12h # Assign IP addresses between 172.24.1.10 and 172.24.1.240 with a 12 hour lease time" > /etc/dnsmasq.conf  

sudo echo "#
# /etc/sysctl.conf - Configuration file for setting system variables
# See /etc/sysctl.d/ for additional system variables.
# See sysctl.conf (5) for information.
#

#kernel.domainname = example.com

# Uncomment the following to stop low-level messages on console
#kernel.printk = 3 4 1 3

##############################################################3
# Functions previously found in netbase
#

# Uncomment the next two lines to enable Spoof protection (reverse-path filter)
# Turn on Source Address Verification in all interfaces to
# prevent some spoofing attacks
#net.ipv4.conf.default.rp_filter=1
#net.ipv4.conf.all.rp_filter=1

# Uncomment the next line to enable TCP/IP SYN cookies
# See http://lwn.net/Articles/277146/
# Note: This may impact IPv6 TCP sessions too
#net.ipv4.tcp_syncookies=1

# Uncomment the next line to enable packet forwarding for IPv4
net.ipv4.ip_forward=1

# Uncomment the next line to enable packet forwarding for IPv6
#  Enabling this option disables Stateless Address Autoconfiguration
#  based on Router Advertisements for this host
net.ipv6.conf.all.forwarding=1


###################################################################
# Additional settings - these settings can improve the network
# security of the host and prevent against some network attacks
# including spoofing attacks and man in the middle attacks through
# redirection. Some network environments, however, require that these
# settings are disabled so review and enable them as needed.
#
# Do not accept ICMP redirects (prevent MITM attacks)
#net.ipv4.conf.all.accept_redirects = 0
#net.ipv6.conf.all.accept_redirects = 0
# _or_
# Accept ICMP redirects only for gateways listed in our default
# gateway list (enabled by default)
# net.ipv4.conf.all.secure_redirects = 1
#
# Do not send ICMP redirects (we are not a router)
#net.ipv4.conf.all.send_redirects = 0
#
# Do not accept IP source route packets (we are not a router)
#net.ipv4.conf.all.accept_source_route = 0
#net.ipv6.conf.all.accept_source_route = 0
#
# Log Martian Packets
#net.ipv4.conf.all.log_martians = 1
#
" > /etc/sysctl.conf


echo '# Defaults for hostapd initscript
#
# See /usr/share/doc/hostapd/README.Debian for information about alternative
# methods of managing hostapd.
#
# Uncomment and set DAEMON_CONF to the absolute path of a hostapd configuration
# file and hostapd will be started during system boot. An example configuration
# file can be found at /usr/share/doc/hostapd/examples/hostapd.conf.gz
#
#DAEMON_CONF="/etc/hostapd/hostapd.conf"

# Additional daemon options to be appended to hostapd command:-
#       -d   show more debug messages (-dd for even more)
#       -K   include key data in debug messages
#       -t   include timestamps in some debug messages
#
# Note that -B (daemon mode) and -P (pidfile) options are automatically
# configured by the init.d script and must not be added to DAEMON_OPTS.
#
#DAEMON_OPTS=""
' > /etc/default/hostapd


sudo sed -i -- 's/exit 0/ /g' /etc/rc.local
sudo sed -i -- 's/sudo \/usr\/sbin\/hostapd \/etc\/hostapd\/hostapd.conf/ /g' /etc/rc.local


LINE="sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE  
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT  
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT"

FILE=/etc/rc.local
grep -q "$LINE" "$FILE" || echo "$LINE" >> "$FILE"


echo "sudo /usr/sbin/hostapd /etc/hostapd/hostapd.conf" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local


sudo service hostapd start  
sudo service dnsmasq start 

echo "Done, Reboot might be needed"
