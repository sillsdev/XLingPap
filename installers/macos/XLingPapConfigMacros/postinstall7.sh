#!/bin/sh

# postinstall
# 
#
# Created by Harold Andrew Black on 3/2/10.
# Edited on 8/10/2017
# Copyright 2017 SIL International. All rights reserved.
mkdir -p $HOME/Library/Application\ Support/XMLmind/XMLEditor7/addon/XLingPap
#cd $HOME/Library/Application\ Support/XMLmind/XMLEditor7/addon/XLingPap
cd /Users/Shared/XLingPap/configuration
sudo chmod a+w *
cd ../templates
sudo chmod a+w *
cd ../publisherstylesheets
sudo chmod a+w *
cd ../batchfiles
sudo chmod a+w *
sudo chmod +x *
#pwd > /habby.txt
#echo Before cp >> /habby.txt
cd $HOME/Library/Application\ Support/XMLmind/XMLEditor7/addon/XLingPap
cp -rp /Users/Shared/XLingPap/* .
#cd XLingPap
# Make directories writable for all; some have problems with this
sudo chmod 777 $HOME/Library/Application\ Support/XMLmind/XMLEditor7
sudo chmod 777 $HOME/Library/Application\ Support/XMLmind/XMLEditor7/addon
#echo "after cp" >> /habby.txt
#ls -l >> /habby.txt
#rm -r /Users/Shared/XLingPap
#echo "After rmdir" >> /habby.txt
rm -rf $HOME/Library/Application\ Support/XMLmind/XMLEditor7/cache
exit 0
