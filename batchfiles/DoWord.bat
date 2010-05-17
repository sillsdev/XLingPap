rem cd "%2"
if exist "C:\Program Files\XMLmind_XSL_Utility\bin\xslutilc.bat" goto xslutil
if exist "C:\Program Files (x86)\XMLmind_XSL_Utility\bin\xslutilc.bat" goto xslutilx86
if exist "C:\Program Files\XMLmind XSL-FO Converter" goto old
if exist "C:\Program Files (x86)\XMLmind XSL-FO Converter" goto oldx86
if exist "C:\Program Files\xfc_perso_java-4_3_1\bin" goto v4.3.1
if exist "C:\Program Files (x86)\xfc_perso_java-4_3_1\bin" goto v4.3.1x86
if exist "C:\Program Files\xfc_perso_java-4_3_2\bin" goto v4.3.2
if exist "C:\Program Files (x86)\xfc_perso_java-4_3_2\bin" goto v4.3.2x86
goto quit
:xslutil
path="C:\Program Files\XMLmind_XSL_Utility\bin";%path%
call "C:\Program Files\XMLmind_XSL_Utility\bin\xslutilc.bat" foToWML %1.fo %1.doc
goto quit
:xslutilx86
path="C:\Program Files (x86)\XMLmind_XSL_Utility\bin";%path%
call "C:\Program Files (x86)\XMLmind_XSL_Utility\bin\xslutilc.bat" foToWML %1.fo %1.doc
goto quit
:v4.3.2
path="C:\Program Files\xfc_perso_java-4_3_2\bin";%path%
call "C:\Program Files\xfc_perso_java-4_3_2\bin\fo2wml.bat" -baseURL=%2 %1.fo %1.doc
goto quit
:v4.3.2x86
path="C:\Program Files (x86)\xfc_perso_java-4_3_2\bin";%path%
call "C:\Program Files (x86)\xfc_perso_java-4_3_2\bin\fo2wml.bat" -baseURL=%2 %1.fo %1.doc
goto quit
:v4.3.1
path="C:\Program Files\xfc_perso_java-4_3_1\bin";%path%
call "C:\Program Files\xfc_perso_java-4_3_1\bin\fo2wml.bat" -baseURL=%2 %1.fo %1.doc
goto quit
:v4.3.1x86
path="C:\Program Files (x86)\xfc_perso_java-4_3_1\bin";%path%
call "C:\Program Files (x86)\xfc_perso_java-4_3_1\bin\fo2wml.bat" -baseURL=%2 %1.fo %1.doc
goto quit
:old
path="C:\Program Files\XMLmind XSL-FO Converter";%path%
call "C:\Program Files\XMLmind XSL-FO Converter\fo2wml.bat" %1.fo %1.doc
goto quit
:oldx86
path="C:\Program Files (x86)\XMLmind XSL-FO Converter";%path%
call "C:\Program Files (x86)\XMLmind XSL-FO Converter\fo2wml.bat" %1.fo %1.doc
goto quit
:xslutil
path="C:\Program Files\XMLmind XSL-FO Converter";%path%
call "C:\Program Files\XMLmind XSL-FO Converter\fo2wml.bat" %1.fo %1.doc

:quit
exit
