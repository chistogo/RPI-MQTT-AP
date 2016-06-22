# RPI-MQQT-AP
If you are lazy like I am, this is a guide and some of the software to turn your raspberry pi into an access point that hosts an MQTT broker using Mosquitto and websockets. 


#This is a guide on how to configure a pi as wifi acess point and host mqtt This is not ment to be ran since there are reboot commands in this file


#Download latest version of raspian-lite and burn it to SD Card (win32diskimager)
# Link to Raspbian: https://www.raspberrypi.org/downloads/raspbian/
# Link to win32imager: https://sourceforge.net/projects/win32diskimager/



#Make sure to exapand the File System (If you dont do this you will not have space to do anything)
```bash
sudo raspi-config 
sudo reboot
```
#Remeber to change password Raspberry Pi. This is import! Makes it so that people don't hack into it
#The following command changes the password
```bash
passwd pi
```

#Update Packages
```bash
sudo apt-get update
```
#Update Kernel (Gets more drivers possibly supporting more devices)
```bash
sudo apt-get dist-upgrade
```

#Upgrade Firmware
```bash
sudo apt-get install rpi-update -y
sudo rpi-update
```

#Restart the Pi to make sure you are using the latest firware
```bash
sudo reboot 
```

#Get Git
```bash
sudo apt-get install git -y
```

#Clone this scripts to get the software install and working. Edit the scripts BEFORE you run it to change SSID and Password and other configuration stuff.
```bash
git clone https://github.com/chistogo/RPI-MQQT-AP.git
```