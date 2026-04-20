#!/bin/sh
# Install XLingPaper XXE Configuration files on Linux
# we make both version 7 and 8 for now

INSTALL_DIR=`pwd`
USERHOME=$HOME
if [ "$HOME" = "/root" ]; then
	USERHOME=$1
fi

mkdir -p $USERHOME/.xxe7/addon
cd $USERHOME/.xxe7/addon
tar -xjf "$INSTALL_DIR"/xlingpaperconfig-xxe7.tar

mkdir -p $USERHOME/.xxe8/addon
cd $USERHOME/.xxe8/addon
tar -xjf "$INSTALL_DIR"/xlingpaperconfig-xxe7.tar

