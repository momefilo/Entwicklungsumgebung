# Entwicklungsumgebung
Pi Pico enwicklungsumgebu
Auf dem Entwicklungsrechner sollte der Benutzer "momefilo" aktiv sein, sonnst sind im Script die Passagen der Verzeichnisse anzupassen.
Alle einzugebenden Befehle sehen so aus: -->"befehl"; z.B.: -->"cd .."
und sind ohne -->" " einzugeben, innerhalb der Gaensefuesschen ist die Unterscheidung zwischen
ein- und zweifachen Gaensefuesschen wichtig!

Raspi-Zero mit naktem raspios vorbereiten und einloggen
-->"sudo raspi-config"
im Menue Interface-options->Serial Port: Wählen Sie zuerst keine Shell ueber
die serielle Schnittstelle und aktivieren Sie den Hardwarezugriff auf die serielle Schnittstelle
Aendern Sie im Menue System->Hostname den Hostnamen in "pi0"

SSH Konfiguration
auf dem Raspi-Zero ssh-Schluessel erzeugen
-->"ssh-keygen -t rsa"
den Schluessel auf den Entwicklungsrechner übertragen
-->"ssh-copy-id -i ~/.ssh/id_rsa.pub user@remote-system"
dise Prozedur ist auf dem Entwicklungsrechner ebenso durchzufuehren
auf dem Entwicklungsrechner ssh-Schluessel erzeugen
-->"ssh-keygen -t rsa"
den Schluessel auf den Raspi-Zero übertragen
-->"ssh-copy-id -i ~/.ssh/id_rsa.pub momefilo@pi0"

OpenOCD auf Paspi-Zero installieren
Pinkonfiguration: swdio -> gpio24, swckl -> gpio25, GND -> GND
-->"sudo apt update"
-->"sudo apt upgrade"
-->"sudo apt install automake autoconf build-essential texinfo libtool libftdi-dev libusb-1.0-0-dev git minicom"
-->"git clone https://github.com/raspberrypi/openocd.git --branch rp2040 --recursive --depth=1"
-->"cd openocd"
-->"./bootstrap"
-->"./configure --enable-ftdi --enable-sysfsgpio --enable-bcm2835gpio"
-->"make"
-->"sudo make install"
erstelle die ausfuehrbare Datei transfer.sh
-->"cd .."
-->"touch transfer.sh"
-->"chmod +x transfer.sh"
-->"echo '#!/bin/bash' >> transfer.sh"
-->"echo 'openocd -f interface/raspberrypi-swd.cfg -f target/rp2040.cfg -c "program /home/momefilo/$1 verify reset exit" && rm /home/momefilo/$1' >> transfer.sh"

#ON THE DEVELOPING MASCHINE
Das Pico-Sdk und Geany auf dem Entwicklungsrechner installieren
-->"sudo apt update"
-->"sudo apt install cmake gcc-arm-none-eabi libnewlib-arm-none-eabi build-essential geany git"
-->"mkdir pico"
-->"cd pico"
-->"git clone https://github.com/raspberrypi/pico-sdk.git --branch master"
-->"cd pico-sdk"
-->"git submodule update --init"
-->"cd .."
-->"git clone https://github.com/raspberrypi/pico-examples.git --branch master"

Fuegen Sie am Ende der Datei ".bashrc" folgende Zeilen hinzu
-->"echo 'export PICO_SDK_PATH=/home/momefilo/pico/pico-sdk' >> ~/.bashrc"
-->"echo 'export pico_serial=/home/momefilo/pico/serial' >> ~/.bashrc"
-->"echo 'export pico_transfer=/home/momefilo/pico/transfer' >> ~/.bashrc"
-->"echo 'export pico_project=/home/momefilo/pico/new_project' >> ~/.bashrc"
Erstellen Sie die Dateien transfer und serial mit folgendem Inhalt
-->"touch transfer"
-->"chmod +x transfer"
-->"echo '#!/bin/bash' >> transfer"
-->"echo 'scp $1 pi0:/home/momefilo/ && \' >> transfer"
-->"echo 'ssh pi0 -t "/home/momefilo/transfer.sh $1"' >> transfer"
-->"touch serial"
-->"chmod +x serial"
-->"echo '#!/bin/bash' >> serial"
-->"echo 'ssh pi0 -t "minicom -b 115200 -o -D /dev/serial0"' >> serial"
-->"mkdir projekte"
-->"cd projekte"
-->"mkdir remote"
-->"cd .."

Erstellen Sie die Dateien "new_project" mit folgendem Inhalt und machen Sie sie mit 
-->"chmod +x new_project"
ausfuehrbar.
Copy and Paste mit dem Editor!
-->"
#!/bin/bash
if [ $# -ne 1 ]; then
	echo "projektname angeben!"
 	exit 1
fi
PFAD=/home/momefilo/pico/projekte/remote/$1
BASE_PFAD=/home/momefilo/pico/projekte/remote
if  ! [ -d $PFAD ]; then
mkdir -p $PFAD/build
cp /home/momefilo/pico/pico-sdk/external/pico_sdk_import.cmake $PFAD/pico_sdk_import.cmake
touch $BASE_PFAD/$1.geany
echo -e "[editor]
line_wrapping=false
line_break_column=85
auto_continue_multiline=true

[file_prefs]
final_new_line=true
ensure_convert_new_lines=false
strip_trailing_spaces=true
replace_tabs=false

[indentation]
indent_width=4
indent_type=1
indent_hard_tab_width=8
detect_indent=false
detect_indent_width=false
indent_mode=2

[long line marker]
long_line_behaviour=1
long_line_column=100" >> $BASE_PFAD/$1.geany

echo -e "[build-menu]
NF_00_LB=_Make
NF_00_CM=make
NoneFT_01_LB=build
NoneFT_01_CM=rm -rf * | cmake ..
filetypes=None;C;
CFT_01_LB=_Build
CFT_01_CM=rm -rf * | cmake ..
EX_00_LB=_Execute
EX_01_LB=serial
EX_01_CM=$pico_serial" >> $BASE_PFAD/$1.geany
echo "NF_00_WD=$PFAD/build/" >> $BASE_PFAD/$1.geany
echo "NoneFT_01_WD=$PFAD/build" >> $BASE_PFAD/$1.geany
echo "CFT_01_WD=$PFAD/build/"  >> $BASE_PFAD/$1.geany
echo "EX_00_CM=$pico_transfer $1.elf"  >> $BASE_PFAD/$1.geany
echo "EX_00_WD=$PFAD/build/"  >> $BASE_PFAD/$1.geany
echo "EX_01_WD=$PFAD/build/"  >> $BASE_PFAD/$1.geany
echo "[project]" >> $BASE_PFAD/$1.geany
echo "name=$1" >> $BASE_PFAD/$1.geany
echo "description=" >> $BASE_PFAD/$1.geany
echo "file_patterns=" >> $BASE_PFAD/$1.geany
echo "base_path=/home/momefilo/pico/projekte/remote/$1" >> $BASE_PFAD/$1.geany
echo -e "[files]
current_page=0
FILE_NAME_0=0;C;0;EUTF-8;1;1;0;%2Fhome%2Fmomefilo%2Fpico%2Fprojekte%2Fremote%2F$1%2F$1.c;0;4
FILE_NAME_1=0;CMake;0;EUTF-8;1;1;0;%2Fhome%2Fmomefilo%2Fpico%2Fprojekte%2Fremote%2F$1%2FCMakeLists.txt;0;4
[VTE]
last_dir=/home/momefilo/pico/projekte/remote/$1/build" >> $BASE_PFAD/$1.geany

echo -e '// momefilo Desing\n#include <stdio.h>\n#include "pico/stdlib.h"' > $PFAD/$1.c

echo -e "cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project($1_project C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()
add_executable($1
$1.c
)

target_link_libraries($1 pico_stdlib)" > $PFAD/CMakeLists.txt
geany $BASE_PFAD/$1.geany
else
echo "projekt schon vorhanden!"

fi
"

Wenn Sie nun am Entwicklungsrechner in einem neuen Terminal (damit die Variablen geladen werden) ins Verzeichnis Pico wechseln, koennen Sie 
durch Eingabe von: "./new_project Ihr_Projektname" direkt Geany mit einem
Grundskelet starten. Mit F9 bilden Sie Ihr Programm erstmals (vergessen Sie die main Funktion nicht hinzuzufügen;) um es dann 
mit ^F9 immer wieder compilieren zu koennen. Das Programm wird mit F5 auf den Pico uebertragen.
Im Geany-Menue "Erstellen" gibt es  den Eintrag "serial" welcher ein Terminal oeffnet, wenn sie die serielle Verbindung
zwichen Pi-Pico und Raspi-Zerodurch zwei drähte hergestellt haben sind die "printf()-Ausgaben" Ihres Programms sehen koennen.

