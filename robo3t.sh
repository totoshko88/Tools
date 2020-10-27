#!/bin/bash -
#title          :robo3t.sh
#description    :Install robo3t on Linux
#author         :totoshko88@gmail.com
#date           :20201028
#version        :1.0
#usage          :./robo3t.sh
#notes          :
#bash_version   :bash 5.0.17
#============================================================================
echo ""
echo "This script will install Robo3t https://robomongo.org/download"
echo ""
echo "Please enter the URL of the latest robo3t version [ENTER]:"
read LINK
LOGO=https://blog.robomongo.org/content/images/2016/01/enjoy.png
NAME=$(echo $LINK | awk -F"/" {'print $6'})
FNAME=$(basename $NAME .tar.gz)
DIR=/opt/robo3t
echo ""
echo "Downloading Robo3t"
echo ""
wget $LINK
sudo mkdir -p $DIR
sudo tar xvf $NAME -C $DIR
rm $NAME
echo ""
echo "Creating the link"
echo ""
sudo ln -s $DIR/$FNAME/bin/robo3t /usr/local/bin/
echo ""
echo "Creating shortcut"
sudo wget $LOGO -O $DIR/robo3t.png
sudo rm -f /usr/share/applications/robo3t.desktop
cat << EOF | sudo tee -a /usr/share/applications/robo3t.desktop
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Robo3t
Icon=$DIR/robo3t.png
Exec=/usr/local/bin/robo3t
Comment=Robo3t
Categories=Development;
Terminal=false
StartupNotify=true
EOF
echo ""
echo "Enjoy!"
echo ""
exit 0
