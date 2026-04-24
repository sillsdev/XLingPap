#!/bin/sh

# copyaddons
# 
#
# Created by Harold Andrew Black on 5/11/2018.
# Copyright 2018 SIL International. All rights reserved.

mkdir -p $HOME/Library/Application\ Support/XMLmind/XMLEditor8/addon

unzip /Users/Shared/XXE8.2/es_dictionary-8_2_0.zip -d $HOME/Library/Application\ Support/XMLmind/XMLEditor8/addon

unzip /Users/Shared/XXE8.2/es_translation-8_2_0.zip -d $HOME/Library/Application\ Support/XMLmind/XMLEditor8/addon

unzip /Users/Shared/XXE8.2/fr_dictionary-8_2_0.zip -d $HOME/Library/Application\ Support/XMLmind/XMLEditor8/addon

unzip /Users/Shared/XXE8.2/fr_translation-8_2_0.zip -d $HOME/Library/Application\ Support/XMLmind/XMLEditor8/addon

unzip /Users/Shared/XXE8.2/sample_customize_xxe-8_2_0.zip -d $HOME/Library/Application\ Support/XMLmind/XMLEditor8/addon

exit 0

