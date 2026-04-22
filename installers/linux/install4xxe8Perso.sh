#!/bin/bash
# Install XLingPaper full setup with the Personal Edition of XXE on Wasta 
# Original work by Peter Wulfing; modified by Andy Black

# First, get user's home directory
USERHOME=$HOME
if [ "$HOME" = "/root" ]; then
	USERHOME=$1
fi
NAMEO=${USERHOME:6}
SPRA=${LANGUAGE:0:2}

# then become root
if ! [ $(id -u) = 0 ]; then
	 exec sudo -E "$0" "$@"	# If not, re-run the command as root
fi

#case "$SPRA" in
#	es) echo "Pluse Enter para instalar XLingPaper y XXE en " $USERHOME "para usuario: " $NAMEO". Si no, pulse Ctrl-C " ;;
#	fr) echo "Appuyez sur Enter pour installer XLingPaper et XXE dans " $USERHOME "pour utlisateur: " $NAMEO". Sinon, tapez sur Ctrl-C " ;;
#	*) echo "Hit Enter to install XlingPaper and XXE in " $USERHOME " for user: " $NAMEO". , else Ctrl-C \n"  ;;
#esac
#
#read evar

INSTALL_DIR=`pwd`
# Show the user the XXE Personal Edition license
echo "Part 1/6: To use this installer, you must qualify for the Personal Edition license of the XMLmind XML Editor."
read -p "Type q when you are done reading the license. To see the license, press Enter."
less $INSTALL_DIR/XXEPersonalAndXLingPaperLicense.txt
read -p "Do you qualify for the Personal Edition License for the XMLmind XML Editor? (y/n) " yesOrNo
if [[ $yesOrNo == "" ]] || [[ $yesOrNo != "y" ]]; then
	exit 1;
fi

# Install XXE
echo  Part 2/6: install the Personal Edition of the XMLmind XML Editor
#case "$SPRA" in
#	es) echo "Paso 2: Instalación de XXE" ;;
#	fr) echo "Etape 2: Installation de XXE" ;;
#	*) echo "Step 2: Installation of XXE" ;;
#esac

tar -xjf "$INSTALL_DIR"/XXE8-2Installer.tar
# for some reason the XXE8Installer directory is owned by root and unless we change it, the user cannot delete it easily
chown $NAMEO -R "$INSTALL_DIR"/XXE8Installer
unzip -qq "$INSTALL_DIR"/XXE8Installer/xxe-perso-8_2_0.zip -d /opt

#Make Link for xxe
if ! [ -d /usr/local/bin ]; then
	mkdir /usr/local/bin
fi
if [ -f /usr/local/bin/xxe ]; then
	sudo rm /usr/local/bin/xxe
fi
sudo ln -s /opt/xxe-perso-8_2_0/bin/xxe /usr/local/bin

echo  Part 3/6: install XLingPaper configuration files
INSTALL_DIR=`pwd`
# we make both version 7 and 8 for now
sudo mkdir -p $USERHOME/.xxe7/addon
# Make sure directories are writable for all; some have had problems with this
sudo chmod 777 $USERHOME/.xxe7
sudo chmod 777 $USERHOME/.xxe7/addon
cd $USERHOME/.xxe7/addon
tar -xjf "$INSTALL_DIR"/xlingpaperconfig-xxe7.tar
##unzip -qq "$INSTALL_DIR"/XXE7Installer/es_dictionary-7_6_0.zip
##unzip -qq "$INSTALL_DIR"/XXE7Installer/fr_dictionary-7_6_0.zip
##unzip -qq "$INSTALL_DIR"/XXE7Installer/fr_translation-7_6_0
##unzip -qq "$INSTALL_DIR"/XXE7Installer/sample_customize_xxe-7_6_0.zip
sudo chown -R $NAMEO $USERHOME/.xxe7

sudo mkdir -p $USERHOME/.xxe8/addon
# Make sure directories are writable for all; some have had problems with this
sudo chmod 777 $USERHOME/.xxe8
sudo chmod 777 $USERHOME/.xxe8/addon
cd $USERHOME/.xxe8/addon
tar -xjf "$INSTALL_DIR"/xlingpaperconfig-xxe7.tar
unzip -qq "$INSTALL_DIR"/XXE8Installer/es_dictionary-8_2_0.zip
unzip -qq "$INSTALL_DIR"/XXE8Installer/fr_dictionary-8_2_0.zip
unzip -qq "$INSTALL_DIR"/XXE8Installer/fr_translation-8_2_0
unzip -qq "$INSTALL_DIR"/XXE8Installer/sample_customize_xxe-8_2_0.zip
sudo chown -R $NAMEO $USERHOME/.xxe8

echo  Part 4/6: install texlive for XLingPaper files
#sudo mkdir -p /usr/local
sudo tar -xzf "$INSTALL_DIR"/texlive4xlingpaper.tar -C /opt
sudo ln -s /opt/texlivexlingpaper/2009/bin/i386-linux /usr/texbinxlingpaper

echo  Part 5/6: install XXE preferences
#case "$SPRA" in
#	es) echo "Paso 5: Instalación de las preferencias de XLingPaper." ;;
#	fr) echo "Etape 5: Installation des préférences de XLingPaper." ;;
#	*) echo "Step 5: Installation of XLingPaper preferences." ;;
#esac
##cd $USERHOME/.xxe7
##cp "$INSTALL_DIR"/XXE7Installer/preferences.properties .
cd $USERHOME/.xxe8
cp "$INSTALL_DIR"/XXE8Installer/preferences.properties .

echo  Part 6/6: install sample XLingPaper document
#case "$SPRA" in
#	es) echo "Paso 6: Instalación de un documento de ejemplo para XLingPaper." ;;
#	fr) echo "Etape 6: Installation d'un document d'échantilion de XLingPaper." ;;
#	*) echo "Step 6: Installation of XLingPaper sample document." ;;
#esac

if [ -d "Documentos" ]; then
	tar -xjf "$INSTALL_DIR"/XLingPaperSample.tar -C $USERHOME/Documentos
else
	tar -xjf "$INSTALL_DIR"/XLingPaperSample.tar -C $USERHOME/Documents
fi

#-------------------------------------------------------
#Build desktop file for applications menu
LOC="/usr/local/share/applications"
if [ ! -d $LOC ]; then
	mkdir $LOC
fi
echo "[Desktop Entry]">$LOC/XXE.desktop
echo "Name=XMLmind XML Editor">>$LOC/XXE.desktop
echo "Comment=Edit XML Data">>$LOC/XXE.desktop
echo "GenericName=XML Document editor">>$LOC/XXE.desktop
echo "GenericName[es]=Editor de archivos XML">>$LOC/XXE.desktop
echo "GenericName[fr]=Editeur de fichiers XML">>$LOC/XXE.desktop
echo "Exec=xxe %u">>$LOC/XXE.desktop
echo "Path=/opt/xxe-perso-8_2_0/bin">>$LOC/XXE.desktop
echo "Icon=/opt/xxe-perso-8_2_0/bin/icon/xxe.ico">>$LOC/XXE.desktop
echo "MimeType=text/xml;">>$LOC/XXE.desktop
echo "Terminal=false">>$LOC/XXE.desktop
echo "Type=Application">>$LOC/XXE.desktop
echo "Categories=GTK;GNOME;Office;Education">>$LOC/XXE.desktop
echo "StartupNotify=true">>$LOC/XXE.desktop
echo "text/xml=XXE.desktop">>$LOC/defaults.list
###chmod +x $LOC/XXE.desktop
###Add XXE to mimeinfo.sh

echo Installation complete. Please type ./runxxe8 and press the Enter key
#case "$SPRA" in
#	es) echo "Instalación terminada con exito." ;;
#	fr) echo "Installation terminée avec succès." ;;
#	*) echo "Successful installation complete." ;;
#esac
