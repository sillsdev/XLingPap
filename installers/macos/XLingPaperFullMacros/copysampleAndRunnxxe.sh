#!/bin/sh

# postinstall
# 
#
# Created by Harold Andrew Black on 3/2/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

MyXLPDir=$HOME/Documents/My_XLingPaper
mkdir -p $MyXLPDir

#echo Before cp >> /habby.txt
cp /Users/Shared/XLingPaperSamples/* $MyXLPDir
cd $MyXLPDir
chown -R $USER .
#echo "after cp" >> /habby.txt
#rm -r /Users/Shared/Documents/$MyXLPDir
#echo "After rmdir" >> /habby.txt

/Applications/XMLmind.app/Contents/Resources/xxe/bin/xxe -putprefs "/Users/Shared/XXE8.2/XLingPaper.preferences" "$MyXLPDir/SamplePaper.xml"
exit 0
