#!/bin/bash
# ./new_lib.sh vorhandenes_projekt neue_bibliothek
# Aufruf mit projektname und Bibliotheksname
# liegt in /home/user/pico/ und erstellt neue Bibliotheken-
# Grundgerueste in einem bereits vorhandenen Projekt
# Es wird das Unterverzeichniss im Projektverzeichniss erstellt
# sowie die CMakeLists.txt, header und .c datei in diesem erstellt
# auch wird die CMakeLists.txt des Projekts angepasst so das nur noch
# die header Datei und die c-Datei der Bibliothek bearbeitet werden muessen
# in der projekt.c wird auch der  Header includet
if [ $# -ne 2 ]; then
	echo "zu wenig parameter!"
	echo "./new_lib.sh vorhandenes_projekt neue_bibliothek"
	exit 1
fi
SCRIPTDIR=$(cd `dirname $0` && pwd)
PFAD="${SCRIPTDIR}/projekte/geany/$1"
LIB_PFAD="${SCRIPTDIR}/projekte/geany/${1}/${2}"

if ! [ -d $PFAD ]; then
	echo "projektname nicht vorhanden!"
	exit 1
else
	if [ -d $LIB_PFAD ]; then
		echo "lib schon vorhanden!"
		exit 1
	fi
mkdir -p $LIB_PFAD
echo -e "file(GLOB FILES *.c *.h)" > $LIB_PFAD/CMakeLists.txt
echo -e 'add_library('"${2}"' ${FILES})' >> $LIB_PFAD/CMakeLists.txt
echo -e "target_link_libraries(${2}\n\t pico_stdlib\n)" >> $LIB_PFAD/CMakeLists.txt
echo -e "\ntarget_include_directories(${2} PUBLIC ./)" >> $LIB_PFAD/CMakeLists.txt

echo -e "#ifndef my_${2}_h
#define my_${2}_h 1\n
\nint funktion();\n
#endif"  > $LIB_PFAD/"${2}.h"

echo -e "// $2 Bibliothek\n#include \"${2}.h\"" > $LIB_PFAD/$2.c
echo -e '\n\nint funktion(){
	return 0;
}
' >> $LIB_PFAD/$2.c

Datei="${PFAD}/CMakeLists.txt"
Suche="# Bibliotheksverzeichnisse"
Einsatz="add_subdirectory(./${2})"
sudo sed -i "/$Suche/a $Einsatz" "$Datei"

Suche="target_link_libraries($1"
Einsatz="\\\t${2}"
sudo sed -i "/$Suche/a $Einsatz" "$Datei"

Datei="${PFAD}/${1}.c"
Suche="\/\/ ${1}"
Einsatz="#include \"${2}/${2}.h\""
sudo sed -i "/$Suche/a $Einsatz" "$Datei"
fi
