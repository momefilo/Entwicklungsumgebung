#!/bin/bash 
#liegt in /home/user/pico/
if [ $# -ne 1 ]; then
	echo "projektname angeben!"
	exit 1
fi
SCRIPTDIR=$(cd `dirname $0` && pwd)
PFAD="${SCRIPTDIR}/projekte/geany/$1"
BASE_PFAD="${SCRIPTDIR}/projekte/geany"
find="\/"
replace="%2F"
# notice the the str isn't prefixed with $
#    this is just how this feature works :/
AKRONYM=${BASE_PFAD//$find/$replace}
if ! [ -d $PFAD ]; then
mkdir -p $PFAD/build
cp ${SCRIPTDIR}/pico-sdk/external/pico_sdk_import.cmake $PFAD/pico_sdk_import.cmake
touch $PFAD/$1.geany
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
long_line_column=100" > $PFAD/$1.geany
echo -e "
[build-menu]
NF_00_LB=_Make
NF_00_CM=make
NoneFT_01_LB=build
NoneFT_01_CM=rm -rf * | cmake .. 
filetypes=None;C;
CFT_01_LB=_Build
CFT_01_CM=rm -rf * | cmake ..
EX_00_LB=_Execute
EX_01_LB=serial
EX_01_CM=${SCRIPTDIR}/serial.sh" >> $PFAD/$1.geany
echo "NF_00_WD=$PFAD/build/" >> $PFAD/$1.geany
echo "NoneFT_01_WD=$PFAD/build" >> $PFAD/$1.geany
echo "CFT_01_WD=$PFAD/build/" >> $PFAD/$1.geany
echo "EX_00_CM=${SCRIPTDIR}/transfer.sh $1.elf" >> $PFAD/$1.geany
echo "EX_00_WD=$PFAD/build/" >> $PFAD/$1.geany
echo "EX_01_WD=$PFAD/build/" >> $PFAD/$1.geany
echo "[project]" >> $PFAD/$1.geany
echo "name=$1" >> $PFAD/$1.geany
echo "description=" >> $PFAD/$1.geany
echo "file_patterns=" >> $PFAD/$1.geany
echo "base_path=${SCRIPTDIR}/projekte/geany/$1" >> $PFAD/$1.geany
echo -e "[files]
current_page=0
FILE_NAME_0=0;C;0;EUTF-8;1;1;0;${AKRONYM}%2F$1%2F$1.c;0;4
FILE_NAME_1=0;CMake;0;EUTF-8;1;1;0;${AKRONYM}%2F$1%2FCMakeLists.txt;0;4
[VTE]
last_dir=${BASE_PFAD}/$1/build" >> $PFAD/$1.geany
echo -e "// $1" '\n#include <stdio.h>\n#include "pico/stdlib.h"' > $PFAD/$1.c
echo -e '\n\nint main() {
	stdio_init_all();
	while (true) {
		printf("Hallo Welt\\n");
		sleep_ms(1000);
	}
}
' >> $PFAD/$1.c
echo -e "cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project($1_project C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()
add_executable($1 $1.c )
target_link_libraries($1 pico_stdlib)
pico_add_extra_outputs($1)" > $PFAD/CMakeLists.txt
geany $PFAD/$1.geany 
else 
echo "projekt schon vorhanden!"
fi
