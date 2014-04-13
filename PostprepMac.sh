#!/bin/sh
# ----------------------------------------------
# Script is designed to be Postprep equivalent on Mac.
# author: Lucas Messenger
# version: 0.1.3
# created: 02_24_2014
# modified: 04_13_2014
#
#
# Notes:
# ----------------------------------------------
# Flash Player has better link:
# http://fpdownload.macromedia.com/get/flashplayer/current/licensing/mac/install_flash_player_13_osx_pkg.dmg
# But requires Adobe distribution license (looks like it's free)
#

clear
uid=$(id -u) #check to see if running in root
if [ "$uid" != "0" ]; then
	echo "Postprep for Mac must be run as root user. Please try again."
	exit
fi

mkdir ~/postprep_temp
cd ~/postprep_temp


# Check to see if there are newer versions of programs available by checking links + 1.
FLSHVER="13"
RDRVER="11"
updateVer=false

# Get Flash, Reader, AIR, and Shockwave, Silverlight, and Firefox with curl and progress bar
echo "Downloading installers...\n"
echo "(1/7) Downloading Adobe Flash Player..."
if curl -o /dev/null -s --head --fail http://aihdownload.adobe.com/bin/live/AdobeFlashPlayerInstaller_"$FLSHVER+1"_ltrosxd_aaa_aih.dmg; then
  updateVer=true
  curl --progress-bar -o Flash.dmg http://aihdownload.adobe.com/bin/live/AdobeFlashPlayerInstaller_"$FLSHVER+1"_ltrosxd_aaa_aih.dmg
else
  curl --progress-bar -o Flash.dmg http://aihdownload.adobe.com/bin/live/AdobeFlashPlayerInstaller_"$FLSHVER"_ltrosxd_aaa_aih.dmg
fi
echo "(2/7) Downloading Adobe Reader..."
if curl -o /dev/null -s --head --fail http://aihdownload.adobe.com/bin/live/AdobeReaderInstaller_"$RDRVER+1"_en_ltrosxd_aaa_aih.dmg; then
  updateVer=true
  curl --progress-bar -o Reader.dmg http://aihdownload.adobe.com/bin/live/AdobeReaderInstaller_"$RDRVER+1"_en_ltrosxd_aaa_aih.dmg
else
  curl --progress-bar -o Reader.dmg http://aihdownload.adobe.com/bin/live/AdobeReaderInstaller_"$RDRVER"_en_ltrosxd_aaa_aih.dmg
fi
echo "(3/7) Downloading Adobe AIR..."
curl --progress-bar -o AIR.dmg http://airdownload.adobe.com/air/mac/download/latest/AdobeAIR.dmg
echo "(4/7) Downloading Adobe Shockwave..."
curl --progress-bar -o Shockwave.dmg http://fpdownload.macromedia.com/get/shockwave/default/english/macosx/latest/Shockwave_Installer_Full_64bit.dmg
echo "(5/7) Downloading Microsoft Silverlight..."
curl --progress-bar -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Safari/537.36" \
    -Lo Silverlight.dmg http://www.microsoft.com/getsilverlight/handlers/getsilverlight.ashx
echo "(6/7) Downloading Mozilla Firefox..."
curl --progress-bar -L -o Firefox.dmg "http://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US"
echo "(7/7) Downloading Java..."
curl --progress-bar -L -o Java.dmg "http://javadl.sun.com/webapps/download/AutoDL?BundleId=83377"
sleep 1
echo "Installers downloaded.\n"
sleep 1
clear

# Mount downloaded installers
DMGNAMES=( "Flash.dmg" "Reader.dmg" "AIR.dmg" "Shockwave.dmg" "Silverlight.dmg" "Firefox.dmg" "Java.dmg" )
echo "Mounting installers..."
for DMG in "${DMGNAMES[@]}"
do
	hdiutil attach "$DMG" -nobrowse -quiet
	echo "$DMG is mounted."
done
sleep 1
echo "\n"
echo "Installers are mounted.\n"
sleep 1
clear

# Find dynamic directories, and only the top directory
# I only need to know where they reside in /Volumes
FLSH=$(find /Volumes -type d -name "*Flash*" -maxdepth 1)
RDR=$(find /Volumes -type d -name "*Reader*" -maxdepth 1)
AIR=$(find /Volumes -type d -name "*AIR*" -maxdepth 1)
FRFX=$(find /Volumes -type d -name "*Firefox*" -maxdepth 1)
SHKWV=$(find /Volumes -type d -name "*Shockwave*" -maxdepth 1)
SLVR=$(find /Volumes -type d -name "*Silverlight*" -maxdepth 1)
JAVA=$(find /Volumes -type d -name "*Java*" -maxdepth 1)

# Get .pkg location for folders that have it
SHKWVPKG=$(find "$SHKWV" -name '*Shockwave*.pkg')
SLVRPKG=$(find "$SLVR" -name '*Silverlight*.pkg')
JAVAPKG=$(find "$JAVA" -name '*Java*.pkg')

# Install from mounted volumes
echo "Installing Firefox..."
cp -R /Volumes/Firefox/Firefox.app /Applications
echo "Firefox installed."
/Volumes/Adobe\ Flash\ Player\ Installer/Install\ Adobe\ Flash\ Player.app/Contents/MacOS/Install\ Adobe\ Flash\ Player
/Volumes/Adobe\ Reader\ Installer/Install\ Adobe\ Reader.app/Contents/MacOS/Install\ Adobe\ Reader
/Volumes/Adobe\ AIR/Adobe\ AIR\ Installer.app/Contents/MacOS/Adobe\ AIR\ Installer
installer -pkg "$SHKWVPKG" -target /
installer -pkg "$SLVRPKG" -target /
installer -pkg "$JAVAPKG" -target /
sleep 1

VOLNAMES=( "$FLSH" "$RDR" "$AIR" "$FRFX" "$SHKWV" "$SLVR" "$JAVA" )

# Unmount installers
clear
echo "Unmounting installers..."
for VOL in "${VOLNAMES[@]}"
do
    hdiutil detach "$VOL" -quiet
    echo "$VOL is unmounted."
done
sleep 1
echo "Installers are unmounted.\n"
rm -rf ~/postprep_temp
sleep 1

#Before completing check if there we updated versions of software."
if [ "$updateVer" = true ] ; then
	echo "New software versions were found, and installed."
	echo "However, PostprepMac needs to be updated to reflect future updates. \n"
	echo "Contact Lucas Messenger to update script, or visit https://github.com/lmessenger/PostprepMac \n"
fi
echo "PostprepMac has completed."
exit
