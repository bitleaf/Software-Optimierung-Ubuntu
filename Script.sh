#!/bin/bash

# THIS SCRIPT HAS NOT BEEN TESTED - USE WITH CAUTION #

### Software Säuberung ###

echo 'Pakete automatisch aufräumen'
sudo apt-get autoclean autoremove

echo 'Alte Kernel in Boot-Partition säubern'
dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge

echo 'Install FSlint'
sudo apt-get install fslint

echo 'In der Dash-Suche, deaktiviere Ergebnisse aus dem Internet'
#http://askubuntu.com/questions/271408/how-to-hide-unity-dash-more-suggestions-not-unity-lens-shopping


### Software Update ###

echo 'Installiere/Aktualisiere Java'
sudo apt-get install default-jre
# test mit java -version

echo 'Update aller installierten Anwendungen'
sudo apt-get update && sudo apt-get upgrade

echo 'Installiere/Aktualisiere shutter'
sudo apt-get install shutter

# add shortcut with "shutter -f" und autom. speichern

echo 'Installiere/Aktualisiere Adobe Flash Player'
sudo apt-get install flashplugin-installer

echo 'Installiere/Aktualisiere TeamViewer'
sudo apt-get install teamViewer

echo 'Installiere/Aktualisiere Firefox'
sudo apt-get install firefox

echo 'Installiere/Aktualisiere Chromium'
sudo apt-get install chromium

echo 'Installiere Firefox Add-Ons'
#http://askubuntu.com/questions/73474/how-to-install-firefox-addon-from-command-line-in-scripts



### Optimierung der Einstellungen ###
