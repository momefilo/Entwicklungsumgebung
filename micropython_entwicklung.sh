mkdir -p mpython/module/mandelbrodt
cd mpython
echo 'include(${CMAKE_CURRENT_LIST_DIR}/mandelbrodt/micropython.cmake)' >> module/micropython.cmake
echo '
MANDELBRODT_MOD_DIR := $(USERMOD_DIR)

# Add all C files to SRC_USERMOD.
SRC_USERMOD += $(MANDELBRODT_MOD_DIR)/mandelbrodt.c

# We can add our module folder to include paths if needed
# This is not actually needed in this example.
CFLAGS_USERMOD += -I$(MANDELBRODT_MOD_DIR)
' >> module/mandelbrodt/micropython.mk
echo '
# Create an INTERFACE library for our C module.
add_library(usermod_mandelbrodt INTERFACE)
# Add our source files to the lib
target_sources(usermod_mandelbrodt INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/mandelbrodt.c
)
# Add the current directory as an include directory.
target_include_directories(usermod_mandelbrodt INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}
)
# Link our INTERFACE library to the usermod target.
target_link_libraries(usermod INTERFACE usermod_mandelbrodt)
' >> module/mandelbrodt/micropython.cmake
echo '
#include "py/runtime.h"

static mp_obj_t get(
        mp_obj_t real_obj,
        mp_obj_t imag_obj,
        mp_obj_t itercount_obj) {
    mp_float_t real = mp_obj_get_float(real_obj);
    mp_float_t imag = mp_obj_get_float(imag_obj);
    mp_int_t itercount = mp_obj_get_int(itercount_obj);
    mp_int_t ret_val;
    
    double r = 0;
    double i = 0;
    double array[] = {0, 0, real, imag};
    int count = 0;
    while (count < itercount){
        count++;
        r = array[0]*array[0] - array[1]*array[1] - array[2];
        i = array[0]*array[1] + array[0]*array[1] - array[0];
        if ((r*r + i*i) >=4){
            ret_val = count;
            return mp_obj_new_int(ret_val);
        }
        array[0] = r;
        array[1] = i;
    }
    ret_val = 0;
    return mp_obj_new_int(ret_val);
}
static MP_DEFINE_CONST_FUN_OBJ_3(get_obj, get);

// Define all attributes of the module.
// Table entries are key/value pairs of the attribute name (a string)
// and the MicroPython object reference.
// All identifiers and strings are written as MP_QSTR_xxx and will be
// optimized to word-sized integers by the build system (interned strings).
static const mp_rom_map_elem_t mandelbrodt_module_globals_table[] = {
    { MP_ROM_QSTR(MP_QSTR___name__), MP_ROM_QSTR(MP_QSTR_mandelbrodt) },
    { MP_ROM_QSTR(MP_QSTR_get), MP_ROM_PTR(&get_obj) },
};
static MP_DEFINE_CONST_DICT(mandelbrodt_module_globals, mandelbrodt_module_globals_table);

// Define module object.
const mp_obj_module_t mandelbrodt_user_cmodule = {
    .base = { &mp_type_module },
    .globals = (mp_obj_dict_t *)&mandelbrodt_module_globals,
};

// Register the module to make it available in Python.
MP_REGISTER_MODULE(MP_QSTR_mandelbrodt, mandelbrodt_user_cmodule);
' >> module/mandelbrodt/mandelbrodt.c

git clone https://github.com/micropython/micropython.git --branch master
git clone https://github.com/micropython/micropython-lib.git --branch master
cd micropython
cp -r ports/rp2 ports/rp2_momefilo
# in ports/rp2_momefilo/mpconfigport.h ändere #define MICROPY_HW_ENABLE_UART_REPL 1
# in ports/rp2_momefilo/modules könen eine main.py(Autostart, nicht ueberschreibbar) und andere module mit eingebunden werden
make -j4 -C ports/rp2_momefilo BOARD=RPI_PICO_W submodules
make -j4 -C mpy-cross
cd ports/rp2_momefilo
make -j4 USER_C_MODULES=../../../module/micropython.cmake BOARD=RPI_PICO_W
cd build-RPI_PICO_W
# zum rekompilieren ändere mandelbrodt.c
cd ports/rp2_momefilo
make BOARD=RPI_PICO_W clean
make -j4 USER_C_MODULES=../../../module/micropython.cmake BOARD=RPI_PICO_W

# transfer firmaware
~/pico/transfer.sh firmware.elf

# start python REPL
ssh pi0 -t "minicom -b 115200 -o -D /dev/serial0"
import mandelbrodt
print(mandelbrodt.add_ints(1, 3))

# auf der wlan-debug-bridge
sudo apt update
sudo apt install python3-pip
sudo mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.orig
pip install rshell
pip install ampy
rshell -p /dev/serial0 cp /home/momefilo/$1 /pyboard/
ampy --port /dev/serial0 put $1
