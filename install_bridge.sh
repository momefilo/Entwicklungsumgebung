#!/bin/bash
#  !!!!!!!!! LOCALE MUESSEN IN RASPI-CONFIG GESETZT SEIN !!!!!!
sudo apt update
#sudo apt upgrade
sudo apt install automake autoconf build-essential texinfo libtool libftdi-dev libusb-1.0-0-dev git minicom -y
git clone https://github.com/raspberrypi/openocd.git --recursive --depth=1
cd openocd
./bootstrap
git submodule init
git submodule update
./configure --enable-ftdi --enable-sysfsgpio --enable-bcm2835gpio --enable-internal-jimtcl
# !! Entferne in Makefil Zeile 1353 -Werror am Ende !!!
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
