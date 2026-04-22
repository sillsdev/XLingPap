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
tar -cjf xlingpaperconfig-xxe7.tar XLingPap
cp xlingpaperconfig-xxe7.tar ../installers/linux
cd ../installers/linux
tar -czf XLingPaper-$1XXEPersonalEditionFullSetup.tar.gz install4xxe8Perso.sh runxxe8.sh XLingPaperLicense XXEPersonalAndXLingPaperLicense.txt xlingpaperconfig-xxe7.tar texlivexlingpaper2020.tar XLingPaperSample.tar XXE8-2Installer.tar

