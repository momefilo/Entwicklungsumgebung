#!/bin/sh

##install SDRAngel

sudo mkdir -p /opt/build
sudo chown $USER:users /opt/build
sudo mkdir -p /opt/install
sudo chown $USER:users /opt/install

## dependencys
sudo apt-get update && sudo apt-get -y install \
git cmake g++ pkg-config autoconf automake libtool libfftw3-dev libusb-1.0-0-dev libusb-dev libhidapi-dev libopengl-dev \
libfaad-dev libflac-dev zlib1g-dev libboost-all-dev libasound2-dev pulseaudio libopencv-dev libxml2-dev bison flex \
ffmpeg libavcodec-dev libavformat-dev libopus-dev doxygen graphviz libunwind-dev

## QT5
sudo apt-get update && sudo apt-get -y install \
qtbase5-dev qtchooser libqt5multimedia5-plugins qtmultimedia5-dev libqt5websockets5-dev \
qttools5-dev qttools5-dev-tools libqt5opengl5-dev libqt5quick5 libqt5location5-plugins libqt5charts5-dev \
qml-module-qtlocation  qml-module-qtpositioning qml-module-qtquick-window2 \
qml-module-qtquick-dialogs qml-module-qtquick-controls qml-module-qtquick-controls2 qml-module-qtquick-layouts \
libqt5serialport5-dev qtdeclarative5-dev qtpositioning5-dev qtlocation5-dev libqt5texttospeech5-dev \
qtwebengine5-dev qtbase5-private-dev libqt5gamepad5-dev libqt5svg5-dev

#APT
# Optionally: sudo apt-get install libsndfile-dev
cd /opt/build
git clone https://github.com/srcejon/aptdec.git
cd aptdec
git checkout libaptdec
git submodule update --init --recursive
mkdir build; cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/aptdec ..
make -j $(nproc) install

#CM265cc
cd /opt/build
git clone https://github.com/f4exb/cm256cc.git
cd cm256cc
git reset --hard "v1.1.2"
mkdir build; cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/cm256cc ..
make -j $(nproc) install

#LibDAB
cd /opt/build
git clone https://github.com/srcejon/dab-cmdline
cd dab-cmdline/library
git checkout msvc
mkdir build; cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libdab ..
make -j $(nproc) install

#MBElib
cd /opt/build
git clone https://github.com/srcejon/mbelib.git
cd mbelib
git reset --hard 0cf0604433d1409576073d0656926a13287d0de5
mkdir build; cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/mbelib ..
make -j $(nproc) install

#SerialDV
cd /opt/build
git clone https://github.com/f4exb/serialDV.git
cd serialDV
git reset --hard "v1.1.5"
mkdir build; cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/serialdv ..
make -j $(nproc) install

#DSDcc
cd /opt/build
git clone https://github.com/f4exb/dsdcc.git
cd dsdcc
git reset --hard "v1.9.6"
mkdir build; cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/dsdcc -DUSE_MBELIB=ON -DLIBMBE_INCLUDE_DIR=/opt/install/mbelib/include -DLIBMBE_LIBRARY=/opt/install/mbelib/lib/libmbe.so -DLIBSERIALDV_INCLUDE_DIR=/opt/install/serialdv/include/serialdv -DLIBSERIALDV_LIBRARY=/opt/install/serialdv/lib/libserialdv.so ..
make -j $(nproc) install

#Codec2/FreeDV
sudo apt-get -y install libspeexdsp-dev libsamplerate0-dev
cd /opt/build
git clone https://github.com/drowe67/codec2-dev.git codec2
cd codec2
git reset --hard "v1.1.1"
mkdir build_linux; cd build_linux
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/codec2 ..
make -j $(nproc) install

##SGP4
cd /opt/build
git clone https://github.com/dnwrnr/sgp4.git
cd sgp4
mkdir build; cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/sgp4 ..
make -j $(nproc) install

#CSpice
cd /opt/build
git clone https://github.com/srcejon/cspice-cmake.git
cd cspice-cmake
git switch msvc
mkdir build; cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/cspice -DCSPICE_BUILD_STATIC_LIBRARY=OFF ..
make -j $(nproc) install

#LibSigMF
cd /opt/build
git clone https://github.com/f4exb/libsigmf.git
cd libsigmf
git checkout "new-namespaces"
mkdir build; cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libsigmf .. 
make -j $(nproc) install

#GGMorse
cd /opt/build
git clone https://github.com/ggerganov/ggmorse.git
cd ggmorse
mkdir build; cd build
cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/ggmorse -DGGMORSE_BUILD_TESTS=OFF -DGGMORSE_BUILD_EXAMPLES=OFF ..
make -j $(nproc) install

#RNnoise
cd /opt/build
git clone https://github.com/f4exb/rnnoise
cd rnnoise
mkdir build; cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/install/rnnoise -DRNN_ENABLE_X86_RTCD=ON ..
make -j $(nproc) install

#nmarsatC
cd /opt/build
git clone https://github.com/srcejon/inmarsatc.git
cd inmarsatc
git switch msvc
mkdir build; cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/install/inmarsatc ..
make -j $(nproc) install

#RTL-SDR
cd /opt/build
git clone https://github.com/osmocom/rtl-sdr.git librtlsdr
cd librtlsdr
git reset --hard 420086af84d7eaaf98ff948cd11fea2cae71734a 
mkdir build; cd build
cmake -Wno-dev -DDETACH_KERNEL_DRIVER=ON -DCMAKE_INSTALL_PREFIX=/opt/install/librtlsdr ..
make -j $(nproc) install

#Soapy SDR
cd /opt/build
git clone https://github.com/pothosware/SoapySDR.git
cd SoapySDR
git reset --hard 1667b4e6301d7ad47b340dcdcd6e9969bf57d843
mkdir build; cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/install/SoapySDR ..
make -j $(nproc) install

#RTL-SDR soapy
cd /opt/build
git clone https://github.com/pothosware/SoapyRTLSDR.git
cd SoapyRTLSDR
mkdir build; cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/install/SoapySDR  -DRTLSDR_INCLUDE_DIR=/opt/install/librtlsdr/include -DRTLSDR_LIBRARY=/opt/install/librtlsdr/lib/librtlsdr.so -DSOAPY_SDR_INCLUDE_DIR=/opt/install/SoapySDR/include -DSOAPY_SDR_LIBRARY=/opt/install/SoapySDR/lib/libSoapySDR.so ..
make -j $(nproc) install

#SDRAngel
cd /opt/build
git clone https://github.com/f4exb/sdrangel.git
cd sdrangel
mkdir build; cd build
cmake -Wno-dev -DDEBUG_OUTPUT=ON -DRX_SAMPLE_24BIT=OFF -DBUILD_SERVER=OFF \
-DCMAKE_BUILD_TYPE=RelWithDebInfo \
-DRTLSDR_DIR=/opt/install/librtlsdr \
-DIIO_DIR=/opt/install/libiio \
-DXTRX_DIR=/opt/install/xtrx-images \
-DSOAPYSDR_DIR=/opt/install/SoapySDR \
-DUHD_DIR=/opt/install/uhd \
-DAPT_DIR=/opt/install/aptdec \
-DCM256CC_DIR=/opt/install/cm256cc \
-DDSDCC_DIR=/opt/install/dsdcc \
-DSERIALDV_DIR=/opt/install/serialdv \
-DMBE_DIR=/opt/install/mbelib \
-DCODEC2_DIR=/opt/install/codec2 \
-DSGP4_DIR=/opt/install/sgp4 \
-DCSPICE_DIR=/opt/install/cspice \
-DLIBSIGMF_DIR=/opt/install/libsigmf \
-DDAB_DIR=/opt/install/libdab \
-DGGMORSE_DIR=/opt/install/ggmorse \
-DRNNOISE_DIR=/opt/install/rnnoise \
-DINMARSATC_DIR=/opt/install/inmarsatc \
-DCMAKE_INSTALL_PREFIX=/opt/install/sdrangel ..
make -j $(nproc) install

-DMIRISDR_DIR=/opt/install/libmirisdr \
-DAIRSPY_DIR=/opt/install/libairspy \
-DAIRSPYHF_DIR=/opt/install/libairspyhf \
-DBLADERF_DIR=/opt/install/libbladeRF \
-DHACKRF_DIR=/opt/install/libhackrf \
-DPERSEUS_DIR=/opt/install/libperseus \
-DLIMESUITE_DIR=/opt/install/LimeSuite \
