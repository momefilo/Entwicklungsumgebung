# Entwicklungsumgebung
Siehe PiZero-wlan-debug.pdf\
Pi Pico enwicklungsumgebung mit RPI zero als headNwireless-Bruecke zur Developmaschine\
Auf beiden Maschinen mus der gleiche username benutzt werden mit inen /home/user/ Verzeichniss\

install_bridge.sh\
Installiert und konfiguriert einen PiZeroW als debugging-Bridge zur Entwicklermaschine\
In der raspi-config muss die Loginshell für die serielle Konsole deaktiviert, und der Hardwarezugriff aktiviert sein

install_desktop.sh\
Installiert und konfiguriert eine Linuxmaschine mit Geany und ladet new_projekt.sh zur Ausführung in Geany\

new_projekt.sh\
Erstellt eine Geany-Konfigurationsdatei so das in Geany mit Menue oder Funktionstasten gebuildet, kompiliert und auf des pico uebertragen werden kann sowie die serielle Konsole zum debuggen ueber printf-Anweisungen geoeffnet\
Als parameter muss der Projektname mit angegeben werden\

new_lib.sh\
Aufruf mit projektname und Bibliotheksname
Erstellt neue Bibliotheken-Grundgerueste in einem bereits vorhandenen Projekt\
Es wird das Unterverzeichniss im Projektverzeichniss erstellt sowie die CMakeLists.txt, header und .c datei in diesem erstellt\
auch wird die CMakeLists.txt  C-Datei des Projekts angepasst so das nur noch die header Datei und die c-Datei der Bibliothek bearbeitet werden muessen\


# SSH Konfiguration
auf dem Entwicklungsrechner ssh-Schluessel erzeugen\
-->"ssh-keygen -t rsa"\
den Schluessel auf den Raspi-Zero übertragen\
-->"ssh-copy-id -i ~/.ssh/id_rsa.pub user@bridge-hostname"\
