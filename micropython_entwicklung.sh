#!/bin/bash
# script zur installation einer micropython Entwicklungsumgebung auf RPi

# Software installieren
sudo apt update
sudo apt-get install cmake build-essential libffi-dev git pkg-config gcc-arm-none-eabi libnewlib-arm-none-eabi -y

# Verzeichnis und Demo-dateien erstellen
mkdir -p python/module/demo
cd python
#touch module/demo/micropython.mk
echo 'include(${CMAKE_CURRENT_LIST_DIR}/demo/micropython.cmake)' >> module/micropython.cmake
echo '
DEMO_MOD_DIR := $(USERMOD_DIR)

SRC_USERMOD += $(DEMO_MOD_DIR)/demo.c
#SRC_USERMOD += $(DEMO_MOD_DIR)/demo_lib.c

# We can add our module folder to include paths if needed
# This is not actually needed in this example.
CFLAGS_USERMOD += -I$(DEMO_MOD_DIR)' >> module/demo/micropython.mk
echo '
# Create an INTERFACE library for our C module.
add_library(usermod_demo INTERFACE)

# Add our source files to the lib
target_sources(usermod_demo INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/demo.c
)

# Add the current directory as an include directory.
target_include_directories(usermod_demo INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}
)

# Link our INTERFACE library to the usermod target.
target_link_libraries(usermod INTERFACE usermod_demo)' >> module/demo/micropython.cmake
echo '
#include <stdio.h>
#include "py/runtime.h"

static mp_obj_t demo_init(size_t n_args, const mp_obj_t *args){
    if(n_args < 1) {
        printf("demo.init(liste)");
        return mp_const_none;
    }
    mp_obj_iter_buf_t demo_buf;
    mp_obj_t item, iterable = mp_getiter(args[0], &demo_buf);
    uint32_t color = 0;
    uint8_t i = 3;
    while ((item = mp_iternext(iterable)) != MP_OBJ_STOP_ITERATION) {
        uint8_t val = mp_obj_get_int(item);
        color  =  (color | (val << (8 * i)));
        i--;
    }
    return mp_obj_new_int_from_ll(color);
}
MP_DEFINE_CONST_FUN_OBJ_VAR_BETWEEN(demo_init_obj, 0, 1, demo_init);

static const mp_rom_map_elem_t demo_module_globals_table[] = {
    { MP_ROM_QSTR(MP_QSTR___name__), MP_ROM_QSTR(MP_QSTR_demo) },
    { MP_ROM_QSTR(MP_QSTR_init), MP_ROM_PTR(&demo_init_obj) },
};
static MP_DEFINE_CONST_DICT(demo_module_globals, demo_module_globals_table);

const mp_obj_module_t demo_user_cmodule = {
    .base = { &mp_type_module },
    .globals = (mp_obj_dict_t *)&demo_module_globals,
};

MP_REGISTER_MODULE(MP_QSTR_demo, demo_user_cmodule);' >> module/demo/demo.c

# micropython downloaden
git clone https://github.com/micropython/micropython.git --branch master
git clone https://github.com/micropython/micropython-lib.git --branch master
cd micropython

# compilieren
cp -r ports/rp2 ports/rp2_orig
# in ports/rp2/mpconfigport.h ändere #define MICROPY_HW_ENABLE_UART_REPL (1)
sed -i '/#define MICROPY_HW_ENABLE_UART_REPL/c #define MICROPY_HW_ENABLE_UART_REPL             (1)' ports/rp2/mpconfigport.h
# in ports/rp2/modules könen eine main.py(Autostart, nicht ueberschreibbar) und andere module mit eingebunden werden
make -j4 -C mpy-cross
cd ports/rp2
make -j4 BOARD=RPI_PICO_W submodules
cmake -DUSER_C_MODULES=/home/momefilo/python/module/micropython.cmake .
make -j4 USER_C_MODULES=../../../module/micropython.cmake BOARD=RPI_PICO_W
#ändere demo.c zum testen
#cd build-RPI_PICO_W
#make -f CMakeFiles/firmware.dir/build.make CMakeFiles/firmware.dir/home/momefilo/python/module/demo/demo.c.o
#zum rekompilieren
#cd ..
#make BOARD=RPI_PICO_W clean
#make -j4 USER_C_MODULES=../../../module/micropython.cmake BOARD=RPI_PICO_W

# transfer firmaware
#cd ports/rp2
#~/pico/transfer.sh firmware.elf

# start python REPL
#ssh pi0 -t "minicom -b 115200 -o -D /dev/serial0"
#import demo
#demo(init([0xab, 0xba, 0xff])

# auf der wlan-debug-bridge
#sudo apt update
#sudo apt install python3-pip
#sudo mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.orig
#pip install rshell
#pip install ampy
#rshell -p /dev/serial0 cp /home/momefilo/$1 /pyboard/
#ampy --port /dev/serial0 put $1
