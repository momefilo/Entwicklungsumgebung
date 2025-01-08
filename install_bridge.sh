#!/bin/bash

sudo apt update
#sudo apt upgrade
sudo apt install automake autoconf build-essential texinfo libtool libftdi-dev libusb-1.0-0-dev git minicom -y
git clone https://github.com/raspberrypi/openocd.git --branch rp2040 --recursive --depth=1
cd openocd
./bootstrap
./configure --enable-ftdi --enable-sysfsgpio --enable-bcm2835gpio
make
sudo make install
# erstelle die ausfuehrbare Datei transfer.sh
cd ..
Pfad=$(cd `dirname $0` && pwd)
Text0="program ${Pfad}"
Text1='/$1 verify reset exit'
touch transfer.sh
chmod +x transfer.sh
echo '#!/bin/bash' > transfer.sh
echo "openocd -f interface/raspberrypi-swd.cfg -f target/rp2040.cfg -c \"${Text0}${Text1}\" && rm ${Pfad}/"'$1' >> transfer.sh
sudo reboot
