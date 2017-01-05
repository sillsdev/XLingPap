# XLingPap
A way to author and archive linguistic papers or books in the Third Wave

These are configuration files for the XMLmind XML Editor (http://www.xmlmind.com/xmleditor/), also known as XXE.  This editor provides an excellent way to hide the complexities of XML while editing.

Unfortunately, sometimes newer versions of XXE break older configuation mechanisms.  For this reason, we have two main branches: **XXE5.3** and **XXE7.3**.  The configuration files for XXE version 5.3.0 are not compatible with the ones for XXE versionn 7.3.0.  The main files which differ betweeen the two are:
* configuration/commands.xml
* configuration/menus.xml
* configuration/menusLonger.xml
* configuration/menus.Shorter.xml
* css/XLingPap.css (and resource files in **XXE7.3**)
* externalPackages (**XXE7.3** has JColorChooser which is no longer in Java 8 by default)
* javasrc (**XXE5.3** is for Java 6 and **XXE7.3** is for Java 8, plus some other differences)
* XLingPap.jar
* XLingPap.xxe

The others are the same.
