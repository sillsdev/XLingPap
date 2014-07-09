package xlingpaper.xxe;

import java.io.*;
import java.nio.*;
import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.view.DocumentView;

public final class NonASCIIIDandIDREFConversion {

    static String sHyperTarget = "\\hypertarget{";
    static String sHyperLink = "\\hyperlink{";
    static String sRightBrace = "}";
    static int iLenHyperTarget = sHyperTarget.length();
    static int iLenHyperLink = sHyperLink.length();

    public static void convert(String[] arguments, File workingDir) throws IOException {
	// ignore arguments because we know what the file names are
	// if (arguments.length != 1)
	// throw new IllegalArgumentException("arguments");

	File inFile = new File(workingDir, "TeXML2.tex");
	if (!inFile.isFile())
	    throw new FileNotFoundException(inFile.getPath());
	File outFile = new File(workingDir, "TeXML3.tex");

	// FileReader in = new FileReader(inFile);
	// FileWriter out = new FileWriter(outFile);
	BufferedReader in = new BufferedReader(new InputStreamReader(new FileInputStream(inFile),
		"UTF8"));
	BufferedWriter out = new BufferedWriter(new OutputStreamWriter(
		new FileOutputStream(outFile), "UTF8"));
	// System.err.println("convert: made it to try: workingDir = " +
	// workingDir.getAbsolutePath());
	try {
	    String line = in.readLine();
	    while (line != null) {
		StringBuffer sb = new StringBuffer();
		line = findAndConvertID(sHyperTarget, iLenHyperTarget, line, sb);
		sb = new StringBuffer();
		line = findAndConvertID(sHyperLink, iLenHyperLink, line, sb);
		out.write(sb.toString());
		out.newLine();
		line = in.readLine();
	    }

	} finally {
	    if (in != null) {
		in.close();
	    }
	    if (out != null) {
		out.close();
	    }
	}
    }

    private static String findAndConvertID(String sMatch, int iLenMatch, String line,
	    StringBuffer sb) {
	int iTarget = line.indexOf(sMatch);
	if (iTarget != -1) {
	    int iBegin = iTarget + iLenMatch;
	    int iBrace = (line.substring(iBegin)).indexOf(sRightBrace);
	    if (iBrace != -1) {
		String id = line.substring(iBegin, iBegin + iBrace);
		String newid = convertID(id);
		sb.append(line.substring(0, iBegin));
		sb.append(newid);
		//sb.append(sRightBrace);
		line = findAndConvertID(sMatch, iLenMatch, line.substring(iBegin + iBrace), sb);
	    } else {
		sb.append(line);
	    }
	} else {
	    sb.append(line);
	}

	return sb.toString();
    }

    static String convertID(String id) {
	StringBuffer sb = new StringBuffer();
	for (int i = 0; i < id.length(); i++) {
	    int code = id.codePointAt(i);
	    if (code > 127) {
		sb.append((Integer.toHexString(code)).toUpperCase());
	    } else {
		sb.append(id.charAt(i));
	    }
	}
	return sb.toString();
    }
}
