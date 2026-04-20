#!/bin/sh
# Create  install package for XLingPaper on Linux
cd ../../XLingPaperConfiguration/
cd XLingPap/batchfiles
chmod a+x *
cp DoTeXPDF2020 DoTeXPDF
cp HasXeLaTeX2020 HasXeLaTeX
cd ../configuration
cp XeLaTeXVersion2020.txt XeLaTeXVersion.txt
cd ../..
pwd
tar -cjf xlingpaperconfig-xxe7.tar XLingPap
cp xlingpaperconfig-xxe7.tar ../installers/linux
cd ../installers/linux
pwd
ls -l
# cd ../linux
tar -czf XLingPaper-$1UpdateConfigOnlySetup.tar.gz installconfigonly-xxe7.sh xlingpaperconfig-xxe7.tar
