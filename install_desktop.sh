#!/bin/bash
if [ $# -ne 1 ]; then
	echo "Name des W-LAN-Bridge-Host angeben!"
	exit 1
fi
SCRIPTDIR=$(cd `dirname $0` && pwd)

#Das Pico-Sdk und Geany auf dem Entwicklungsrechner installieren
sudo apt update
sudo apt install cmake gcc-arm-none-eabi libnewlib-arm-none-eabi build-essential geany git doxygen texlive-latex-base texlive-fonts-recommended texlive-fonts-extra graphviz -y
mkdir pico
cd pico
git clone https://github.com/raspberrypi/pico-sdk.git --branch master
cd pico-sdk
git submodule update --init
cd ..
git clone https://github.com/raspberrypi/pico-examples.git --branch master

#Fuege am Ende der Datei ".bashrc" folgende Zeile hinzu
echo "export PICO_SDK_PATH=${SCRIPTDIR}/pico/pico-sdk" >> ~/.bashrc

#Erstellen Sie die Dateien transfer und serial mit folgendem Inhalt
touch transfer.sh
chmod +x transfer.sh
echo '#!/bin/bash' > transfer.sh
echo 'scp $1 ' "$1:${SCRIPTDIR}/ && " >> transfer.sh
echo "ssh $1 -t " "\"${SCRIPTDIR}/transfer.sh " '$1"' >> transfer.sh
touch serial.sh
chmod +x serial.sh
echo '#!/bin/bash' >> serial.sh
echo "ssh $1 -t \"minicom -b 115200 -o -D /dev/serial0\"" >> serial.sh
mkdir projekte
cd projekte
mkdir geany
cd ..
wget https://raw.githubusercontent.com/momefilo/Entwicklungsumgebung/refs/heads/main/new_projekt.sh
chmod +x new_projekt.sh
wget https://raw.githubusercontent.com/momefilo/Entwicklungsumgebung/refs/heads/main/new_lib.sh
chmod +x new_lib.sh
cd pico-sdk
mkdir build
cd build
cmake -DPICO_EXAMPLES_PATH=../../pico-examples ..
make docs
