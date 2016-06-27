
#Make sure you are in the same directory as this file since I was lazy and hard coded directory changes

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

sudo apt-get install libssl-dev -y
sudo apt-get install cmake -y
sudo apt-get install libc-ares-dev -y
sudo apt-get install uuid-dev -y
sudo apt-get install daemon -y

tar zxvf libwebsockets*

cd libwebsockets*

mkdir build

cd build

cmake ..

sudo make install

sudo ldconfig

cd ..

cd ..



cd mosquitto-1.4.4-websocket


make


sudo make install

sudo mkdir /etc/mosquitto

sudo cp mosquitto.conf /etc/mosquitto

cat >> /etc/mosquitto/mosquitto.conf <<EOF
listener 1883
listener 9001
protocol websockets
EOF


sudo adduser mosquitto


sed -i -- 's/exit 0/ /g' /etc/rc.local

cat >> /etc/rc.local <<EOF
touch /etc/mosquitto/mosquitto.log
chmod 777 /etc/mosquitto/mosquitto.log
sudo mosquitto -c /etc/mosquitto/mosquitto.conf -v &> /etc/mosquitto/mosquitto.log
exit 0
EOF



echo "Please Restart Your computer"
