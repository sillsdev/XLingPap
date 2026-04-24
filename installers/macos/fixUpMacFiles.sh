#!/bin/sh
cd XlingPap/batchfiles
chmod a+w *
chmod +x *
cp HasXeLaTeX2020 HasXeLaTeX
cp DoTeXPDF2020 DoTeXPDF
cd ../configuration
chmod a+w *
cp XeLaTeXVersion2020.txt XeLaTeXVersion.txt
cd ../templates
chmod a+w *
cd ../..
echo Done

