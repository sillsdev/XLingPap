#!/bin/sh

# postinstall
# 
#
# Created by Harold Andrew Black on 3/8/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

#if [ "$(which /usr/local/bin/xxe/bin/xxe)" != "" ]; then
#	/usr/local/bin/xxe/bin/xxe -putprefs "$HOME/.xxe8/XXE/XLingPaper.preferences" $HOME/Documents/#My_XLingPaper/SamplePaper.xml
#else
#	xxe -putprefs "$HOME/.xxe8/XXE/XLingPaper.preferences" $HOME/Documents/My_XLingPaper/#SamplePaper.xml
#fi
if [ "$(which /usr/local/bin/xxe/bin/xxe)" != "" ]; then
	/usr/local/bin/xxe/bin/xxe $HOME/Documents/My_XLingPaper/SamplePaper.xml
else
	xxe $HOME/Documents/My_XLingPaper/SamplePaper.xml
fi
exit 0

