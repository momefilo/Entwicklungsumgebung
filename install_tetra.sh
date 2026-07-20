sudo apt update && sudo apt upgrade -y
sudo apt-get -y install xterm libliquid-dev librtlsdr-dev cmake \
libncurses-dev libxml2-dev git gnuradio gnuradio-dev gr-osmosdr \
gr-iqbal gqrx-sdr unzip wget make gcc patch sudo libosmocore \
libosmocore-dev rtl-sdr xserver-xorg xfce4 xfce4-goodies lightdm\
libtool libusb-1.0-0-dev build-essential pkg-config
sudo systemctl set-default graphical.target

git clone https://github.com/sq5bpf/install-tetra-codec
cd install-tetra-codec
wget https://raw.githubusercontent.com/momefilo/Entwicklungsumgebung/refs/heads/main/en_30039502v010303p0.zip
unzip -L en_30039502v010303p0.zip
patch -p1 -N -E < codec.diff
cd c-code
make

cd ../../
git clone https://github.com/sq5bpf/osmo-tetra-sq5bpf-2
cd osmo-tetra-sq5bpf-2/src
sed -i '/	if (sid.mle_si.bs_service_details==0) return;/c\	if (sid.mle_si.bs_service_details==0) return 0;' tetra_upper_mac.c
sed -i '80c\void show_ascii_strings(unsigned char *buf,int len)' testsds.c
make

cd ../../
git clone https://github.com/sq5bpf/telive-2
cd telive-2
sed -i '/void keyf(unsigned char r)/i int get_scan_range(char *list,int item);' telive.c
sed -i '/void do_text_input(unsigned char c)/i int tune_grxml_receiver(char *url,int rxid,uint32_t freq,int force);' telive.c
make

cd ~/tetra
git clone https://github.com/alphafox02/tetra-rtlsdr
cd tetra-rtlsdr
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build

cd ~/tetra 
mkdir -p run/telive/bin 
cp osmo-tetra-sq5bpf-2/src/tetra-rx run/ 
cp tetra-rtlsdr/build/tetra-rtlsdr run/ 
cp telive-2/telive run/telive/ 
cp telive-2/rxx run/telive/ 
cp telive-2/tetra.xml run/telive/ 
cp telive-2/ssi_descriptions run/telive/ 
cp telive-2/bin/tetrad run/telive/bin/ 
cp telive-2/bin/tplay run/telive/bin/ 
sudo mkdir -p /tetra/bin 
sudo mkdir -p /tetra/in 
sudo mkdir -p /tetra/out 
sudo mkdir -p /tetra/log 
sudo mkdir -p /tetra/tmp 
sudo chown -hR $USER:$USER /tetra
cd ~/
cp tetra/install-tetra-codec/c-code/ccoder.c /tetra/bin/ 
cp tetra/install-tetra-codec/c-code/scoder.c /tetra/bin/ 
cp tetra/install-tetra-codec/c-code/cdecoder.c /tetra/bin/ 
cp tetra/install-tetra-codec/c-code/sdecoder.c /tetra/bin/ 
cp tetra/telive-2/bin/tetrad /tetra/bin/ 
cp tetra/telive-2/bin/tplay /tetra/bin/

cat > tetra_sound_conv.service <<EOF2
[Unit]
Description=Fileconverter to OGG

[Service]
ExecStart=/tetra/bin/tetrad

[Install]
WantedBy=multi-user.target
Alias=tetra_sound_conv.service
EOF2
sudo mv tetra_sound_conv.service /etc/systemd/system/
sudo systemctl enable tetra_sound_conv.service
sudo systemctl start tetra_sound_conv.service

sed -i '$a\export TETRA_HACK_PORT=7379 TETRA_HACK_IP=127.0.0.1 TETRA_HACK_RXID=1' ~/.bashrc

cat > ~/tetra/start.sh <<EOF2
#!/bin/sh

cd /home/momefilo/tetra/run
export TETRA_HACK_PORT=7379 TETRA_HACK_IP=127.0.0.1 TETRA_HACK_RXID=1
#./tetra-rtlsdr -f 392.5e6 -g 49.6 -T ./tetra-rx > /dev/null
./tetra-rtlsdr -f \$1 -g 49.6 -T ./tetra-rx > /dev/null

## Scan Frequenzen
#./tetra-rtlsdr -S 392e6:393e6 -g 48 -D 3
EOF2
chmod +x ~/tetra/start.sh

cat > ~/Schreibtisch/xterm_telive.desktop <<EOF2
[Desktop Entry]
Version=1.0
Type=Application
Name=xterm 203x60
Comment=xterm 203x60 for telive
Exec=xterm -g 203x60 -e ./rxx
Icon=/usr/share/pixmaps/xterm-color_48x48.xpm
Path=/home/$USER/tetra/run/telive
Terminal=false
StartupNotify=false
GenericName=xterm 203x60 for telive
Name[en_US.utf8]=telive xterm
EOF2


