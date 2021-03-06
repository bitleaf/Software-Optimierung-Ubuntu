#! /usr/bin/env bash

# This software is licensed unter the GPLv3.
#
# Copyright (C) 2018 Mathias Renner
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# See http://www.gnu.org/licenses/ fore more information.


# Terminate on any error
set -e

# Ask for sudo password if not sudo privileges
#echo "This script requires sudo privileges. You are asked to provide your user password."
#[ "$UID" -eq 0 ] || gksudo bash "$0" "$@"

# Ask user for configurations
echo -e "\e[0mWould you like to specify which tasks this software shall execute? If yes, type 'y', otherwise 'n':\e[32m"
read usersettingcustomize

if [[ $usersettingcustomize == y ]]; then

  echo -e "\e[0mThere are about ten tasks you now can decide about.\e[32m"

  echo -e "\e[0mWould you like to install Teamviewer for remote support? If yes, type 'y', otherwise 'n':\e[32m"
  read usersettingteamviewer

  echo -e "\e[0mWould you like to install Anydesk for remote support? If yes, type 'y', otherwise 'n':\e[32m"
  read usersettinganydesk

  echo -e "\e[0mWould you like to install the browser Chromium (=Chrome without Google)? If yes, type 'y', otherwise 'n':\e[32m"
  read usersettingchromium

  echo -e "\e[0mWould you like to install the password manager KeePass? If yes, type 'y', otherwise 'n':\e[32m"
  read usersettingkeepass

  echo -e "\e[0mWould you like to install the clipboard manager copyq? If yes, type 'y', otherwise 'n':\e[32m"
  read usersettingcopyq

  echo -e "\e[0mWould you like to install Firefox add-ons for better privacy? If yes, type 'y', otherwise 'n':\e[32m"
  read usersettingfirefoxaddon

  echo -e "\e[0mWould you like to harden Firefox for better security and privacy? If yes, type 'y', otherwise 'n':\e[32m"
  read usersettingfirefoxharden

  echo -e "\e[0mWould you like to disable Bluetooth and remove all software components for bluetooth? If yes, type 'y', otherwise 'n':\e[32m"
  read usersettingbluetooth
fi

echo -e "\e[0m\n#################################################"
echo -e "### Software Cleanup (automated)"
echo -e "#################################################\e[32m"


echo -e "\e[0m\n\n**************************************************"
echo -e "----> Auto-cleanup packages \n\e[32m"

sudo apt autoremove -y


echo -e "\e[0m\n\n**************************************************"
echo -e "----> Cleanup old kernels \n\e[32m"

sudo dpkg -l linux-{image,headers}-* | awk '/^ii/{print $2}' | egrep '[0-9]+\.[0-9]+\.[0-9]+' | grep -v $(uname -r) | xargs sudo apt-get -y purge

echo -e "\e[0m\n\n**************************************************"
echo -e "----> Remove online search in dash (u.a. Amazon)\n\e[32m"

# https://askubuntu.com/questions/192269/how-can-i-remove-amazon-search-results-from-the-dash-or-disable-the-feature
sudo apt remove -y ubuntu-web-launchers


echo -e "\e[0m\n\n**************************************************"
echo -e "----> Remove error reporting daemon\n\e[32m"

# https://forum.ubuntuusers.de/topic/datenschutz-und-ubuntu/
# This also disable error reporting in system settings
sudo apt remove -y whoopsie apport apport-gtk ubuntu-report ubuntu-web-launchers


echo -e "\e[0m\n\n#################################################"
echo -e "### Software Update (automated)"
echo -e "#################################################\e[32m"


echo -e "\e[0m\n\n**************************************************"
echo -e "----> Update repositories \n\e[32m"

sudo apt update


echo -e "\e[0m\n\n**************************************************"
echo -e "----> Update of installed apps \n\e[32m"

sudo apt upgrade -y


echo -e "\e[0m\n\n**************************************************"
echo -e "----> Install/Update curl \n\e[32m"

sudo apt install -y curl


# Teamviewer
if [[ $usersettingteamviewer == y ]]; then
   echo -e "\e[0m\n\n**************************************************"
   echo -e "----> Install/Update TeamViewer\n\e[32m"

   # Fixes dependency error
   sudo apt install -fy

   # Make this command always true to not stop the script
   #   error will be resolved with 'install -f' afterwards
   curl https://download.teamviewer.com/download/teamviewer_i386.deb | awk  -F '[<>]' -F '["]' ' {print $2}' | xargs curl -o /tmp/teamviewer.deb # parse download page and download .deb file
   sudo dpkg -i /tmp/teamviewer.deb || true

   # Fixes dependency error
   sudo apt install -fy
fi

# Anydesk
if [[ $usersettinganydesk == y ]]; then
   echo -e "\e[0m\n\n**************************************************"
   echo -e "----> Install/Update AnyDesk\n\e[32m"

   #sudo curl https://download.anydesk.com/linux/anydesk_2.9.5-1_amd64.deb -o /tmp/anydesk.deb
   # Download latest version of website
   DEBNAME=$(curl -s https://download.anydesk.com/linux/ | grep -m 1 'a href="./anydesk' | awk -F[\>] '{print $2}' | awk -F[\<] '{print $1}')
   curl -s https://download.anydesk.com/linux/$DEBNAME -o /tmp/anydesk.deb

   # Make this command always true to not stop the script
   #   error will be resolved with 'install -f' afterwards
   sudo dpkg -i /tmp/anydesk.deb || true # install deb package

   # Fixes dependency error
   sudo apt install -fy
fi

# CopyQ
if [[ $usersettingcopyq == y ]]; then
  echo -e "\e[0m\n\n**************************************************"
  echo -e "----> Install/Update Clipboard Manager\n\e[32m"

  sudo add-apt-repository -y ppa:hluk/copyq
  sudo apt update
  sudo apt install -y copyq
fi

echo -e "\e[0m\n\n**************************************************"
echo -e "----> Install/Update Firefox\n\e[32m"

sudo apt install -y firefox

# Chromium
if [[ $usersettingchromium == y ]]; then
  echo -e "\e[0m\n\n**************************************************"
  echo -e "----> Install/Update Chromium\n\e[32m"

  sudo apt install -y chromium-browser
fi

# Update Firefox Add-Ons
if [[ $usersettingfirefoxaddon == y ]]; then

   echo -e "\e[0m\n\n**************************************************"
   echo -e "----> Install/Update Firefox Add-Ons\n\e[32m"
   # Ideas from: https://www.kuketz-blog.de/jondofox-profil-nutzung-nicht-mehr-empfehlenswert/


   # Install wget as download tool
   sudo apt install -y wget

   # Install uBlock
   if [ -f /tmp/uBlock0@raymondhill.net.xpi ]; then
      echo -e "\nuBlock install file already exists. Skipping..."
   else
     wget https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/addon-607454-latest.xpi
     mv addon-607454-latest.xpi /tmp/uBlock0@raymondhill.net.xpi
     cd ~/.mozilla/firefox/
     cd "$(ls -la --sort=time | grep -i default | awk -F ' ' '{print $9}' | head -n1)" # cd into most recently used profile
     mkdir -p extensions/
     cp /tmp/uBlock0@raymondhill.net.xpi extensions/
   fi

   # Install https-everywhere
   if [ -f /tmp/https-everywhere@eff.org.xpi ]; then
      echo -e "\nHttps-everywhere install file already exists. Skipping..."
   else
     wget https://addons.mozilla.org/firefox/downloads/latest/https-everywhere/addon-229918-latest.xpi
     mv addon-229918-latest.xpi /tmp/https-everywhere@eff.org.xpi
     cd ~/.mozilla/firefox/
     cd "$(ls -la --sort=time | grep -i default | awk -F ' ' '{print $9}' | head -n1)" # cd into most recently used profile
     mkdir -p extensions/
     cp /tmp/https-everywhere@eff.org.xpi extensions/
   fi

   # Install CanvasBlocker
   if [ -f /tmp/CanvasBlocker@kkapsner.de.xpi ]; then
      echo -e "\nCanvasBlocker install file already exists. Skipping..."
   else
     wget https://addons.mozilla.org/firefox/downloads/latest/canvasblocker/addon-534930-latest.xpi
     mv addon-534930-latest.xpi /tmp/CanvasBlocker@kkapsner.de.xpi
     cd ~/.mozilla/firefox/
     cd "$(ls -la --sort=time | grep -i default | awk -F ' ' '{print $9}' | head -n1)" # cd into most recently used profile
     mkdir -p extensions
     cp /tmp/CanvasBlocker@kkapsner.de.xpi extensions/
   fi

   # Install privacy-settings
   if [ -f /tmp/jid1-CKHySAadH4nL6Q@jetpack.xpi ]; then
      echo -e "\nPrivacy-settings install file already exists. Skipping..."
   else
     wget https://addons.mozilla.org/firefox/downloads/latest/privacy-settings/addon-627512-latest.xpi
     mv addon-627512-latest.xpi /tmp/jid1-CKHySAadH4nL6Q@jetpack.xpi
     cd ~/.mozilla/firefox/
     cd "$(ls -la --sort=time | grep -i default | awk -F ' ' '{print $9}' | head -n1)" # cd into most recently used profile
     mkdir -p extensions
     cp /tmp/jid1-CKHySAadH4nL6Q@jetpack.xpi extensions/
   fi

   # Install Privacy Badger
   if [ -f /tmp/jid1-MnnxcxisBPnSXQ@jetpack.xpi ]; then
      echo -e "\nPrivacy Badger install file already exists. Skipping..."
   else
     wget -O addon-506646-latest.xpi https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/addon-506646-latest.xpi
     mv addon-506646-latest.xpi /tmp/jid1-MnnxcxisBPnSXQ@jetpack.xpi
     cd ~/.mozilla/firefox/
     cd "$(ls -la --sort=time | grep -i default | awk -F ' ' '{print $9}' | head -n1)" # cd into most recently used profile
     mkdir -p extensions
     cp /tmp/jid1-MnnxcxisBPnSXQ@jetpack.xpi extensions/
   fi
fi


# Harden Firefox
if [[ $usersettingfirefoxharden == y ]]; then

   echo -e "\e[0m\n\n**************************************************"
   echo -e "----> Harden Firefox \n\e[32m"

   cd ~/.mozilla/firefox/
   cd "$(ls -la --sort=time | grep -i default | awk -F ' ' '{print $9}' | head -n1)" # cd into most recently used profile

   if [ -f user.js ]; then
      echo "User.js exists, deleting it..."
      rm user.js # delete existing user.js, to be updated next
   fi

   # Downloading user.js
   wget https://raw.githubusercontent.com/pyllyukko/user.js/master/user.js # get hardening config file

   # Enable keyword search in browser URL
   sed -ie 's/user_pref("keyword.enabled",                                    false);/user_pref("keyword.enabled",                                    true);/g' user.js

   # Don't use private browsing mode all the time
   sed -ie 's/user_pref("browser.privatebrowsing.autostart",                  true);/user_pref("browser.privatebrowsing.autostart",                  false);/g' user.js
fi


#echo -e "\e[0m\n\n**************************************************"
#echo -e "----> Installiere libraries to play DVDs\n\e[32m"

# http://howtoubuntu.org/how-to-play-a-dvd-in-ubuntu
# https://wiki.ubuntuusers.de/DVD-Wiedergabe/
#sudo apt install -y libdvdcss2 libdvdread4 libdvdnav4 libdvd-pkg && sudo dpkg-reconfigure libdvd-pkg

if [[ $usersettingkeepass == y ]]; then
  echo -e "\e[0m\n\n**************************************************"
  echo -e "----> Install/Update KeePass\n\e[32m"

  sudo apt install -y keepass2
fi

echo -e "\e[0m\n\n**************************************************"
echo -e "----> Install/Update Preload\n\e[32m"

# Data about its advantage: http://www.hecticgeek.com/2013/05/using-preload-ubuntu-13-04/
# Compare to package 'ureadahaed' that is installed by default https://wiki.ubuntuusers.de/Tuning/
sudo apt install -y preload


echo -e "\e[0m\n\n**************************************************"
echo -e "----> Install/Update FSlint\n\e[32m"

sudo apt install -y fslint


echo -e "\e[0m\n\n**************************************************"
echo -e "----> Install/Update compizconfig-settings-manager\n\e[32m"
sudo apt install -y compizconfig-settings-manager
# open it via `ccsm`, go to "effects" and disable checkbox


echo -e "\e[0m\n\n**************************************************"
echo -e "----> Install/Update GNOME tweak tool\n\e[32m"
sudo apt-get install -y gnome-tweak-tool
# open via search for "tweaks"
# Desktop -> don't show icons
# Top bar -> Application menu -> set off
# Windows -> Titlebar buttons -> placement -> left


echo -e "\e[0m\n\n#################################################"
echo -e "### Optimize settings (automated)"
echo -e "#################################################\e[32m"


echo -e "\e[0m\n\n**************************************************"
echo -e "----> Show *all* apps in list of startup items\n\e[32m"

sudo sed -i 's/NoDisplay=true/NoDisplay=false/g' /etc/xdg/autostart/*.desktop
echo "Done."
# Check for Autostarts.

#echo -e "\e[0m\n\n**************************************************"
#echo -e "----> Create keybinding for taking screenshots when pressing PRINT key\n\e[32m"

#if [ -f /usr/local/bin/take-screenshot ]; then
#   echo -e "\nScreenshots already configured. Skipping..."
#else
#  # Create folder to save screenshots to
#  mkdir -p $HOME/Screenshots
#
#  # Write screenshot command to file
#cat << EOM >> /usr/local/bin/take-screenshot
#"gnome-screenshot -f $HOME/Screenshots/Screenshot-$(date +%G-%m-%d--%H-%M-%S).png"
#EOM
#
#  # Make file executable
#  chmod a+x /usr/local/bin/take-screenshot
#
#  # Install xbindkeys
#  apt install -y xbindkeys
#
#  # Create keybinding of print-key to the take-screenshot "binary"
#cat << EOM >> /home/mac/.xbindkeysrc
#"bash /usr/local/bin/take-screenshot"
#Print
#EOM
#fi

echo -e "\e[0m\n\n**************************************************"
echo -e "----> Configure automatic updates \n\e[32m"

sudo apt install unattended-upgrades

#  # Edit config file 1
#cat << EOM >> /etc/apt/apt.conf.d/20auto-upgrades
#APT::Periodic::Update-Package-Lists "7";
#APT::Periodic::Download-Upgradeable-Packages "1";
#APT::Periodic::AutocleanInterval "1";
#APT::Periodic::Unattended-Upgrade "1";
#EOM
#
#  # Edit config file 2
#cat << EOM >> /etc/apt/apt.conf.d/50unattended-upgrades
#// Automatically upgrade packages from these (origin:archive) pairs
#Unattended-Upgrade::Allowed-Origins {
#"${distro_id}:${distro_codename}";
#"${distro_id}:${distro_codename}-security";
#"${distro_id}:${distro_codename}-updates";
#//	"${distro_id}:${distro_codename}-proposed";
#//	"${distro_id}:${distro_codename}-backports";
#};
#
#// List of packages to not update (regexp are supported)
#Unattended-Upgrade::Package-Blacklist {
#//	"vim";
#//	"libc6";
#//	"libc6-dev";
#//	"libc6-i686";
#};
#
#// This option allows you to control if on a unclean dpkg exit
#// unattended-upgrades will automatically run
#//   dpkg --force-confold --configure -a
#// The default is true, to ensure updates keep getting installed
#Unattended-Upgrade::AutoFixInterruptedDpkg "true";
#
#// Split the upgrade into the smallest possible chunks so that
#// they can be interrupted with SIGUSR1. This makes the upgrade
#// a bit slower but it has the benefit that shutdown while a upgrade
#// is running is possible (with a small delay)
#Unattended-Upgrade::MinimalSteps "true";
#
#// Install all unattended-upgrades when the machine is shuting down
#// instead of doing it in the background while the machine is running
#// This will (obviously) make shutdown slower
#Unattended-Upgrade::InstallOnShutdown "false";
#
#// Send email to this address for problems or packages upgrades
#// If empty or unset then no email is sent, make sure that you
#// have a working mail setup on your system. A package that provides
#// 'mailx' must be installed. E.g. "user@example.com"
#//Unattended-Upgrade::Mail "root";
#
#// Set this value to "true" to get emails only on errors. Default
#// is to always send a mail if Unattended-Upgrade::Mail is set
#//Unattended-Upgrade::MailOnlyOnError "true";
#
#// Do automatic removal of new unused dependencies after the upgrade
#// (equivalent to apt autoremove)
#Unattended-Upgrade::Remove-Unused-Dependencies "true";
#
#// Automatically reboot *WITHOUT CONFIRMATION*
#//  if the file /var/run/reboot-required is found after the upgrade
#//Unattended-Upgrade::Automatic-Reboot "false";
#
#// If automatic reboot is enabled and needed, reboot at the specific
#// time instead of immediately
#//  Default: "now"
#//Unattended-Upgrade::Automatic-Reboot-Time "02:00";
#
#// Use apt bandwidth limit feature, this example limits the download
#// speed to 1Mb/sec
#Acquire::http::Dl-Limit "1000";
#EOM
#
#  # restart service
#  /etc/init.d/unattended-upgrades restart


#

echo -e "\e[0m\n\n**************************************************"
echo -e "----> Harden against attacs via TMP files\n\e[32m"
    # see https://www.privacy-handbuch.de/handbuch_90b.htm
    sudo apt install libpam-tmpdir
echo "Done."


# Handle Bluetooth
if [[ $usersettingbluetooth == y ]]; then

   echo -e "\e[0m\n\n**************************************************"
   echo -e "----> Disable Bluethooth\n\e[32m"

   sudo systemctl disable bluetooth
   sudo modprobe -r btusb
   echo "blacklist btusb #disable bluetooth" >> /etc/modprobe.d/blacklist.conf
   sudo apt remove -y bluez* bluetooth

fi

echo -e "\e[0m\n\n**************************************************"
echo -e "----> Don't send usage statistics to Canonical \n\e[32m"

dconf write /org/gnome/desktop/privacy/send-software-usage-stats false
dconf write /org/gnome/desktop/privacy/report-technical-problem false
echo "Done."

echo -e "\e[0m\n\n**************************************************"
echo -e "----> Finally cleanup packages \n\e[32m"

sudo apt autoclean autoremove


echo -e "\e[0m\n\nAll done without errors.\n"

# Ask for configurations
echo -e "You must reboot for all changes to take effect. Would you like to reboot? If yes, type 'y', otherwise 'n':\e[32m"
read usersettingreboot

if [[ $usersettingreboot == y ]]; then
   sudo reboot
fi
