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

public final class TeXMLLikeCharacterConversion {

    public static void convert(String[] arguments, File workingDir) throws IOException {
	// ignore arguments because we know what the file names are
	// if (arguments.length != 1)
	// throw new IllegalArgumentException("arguments");

	File inFile = new File(workingDir, "TeXML.xml");
	if (!inFile.isFile())
	    throw new FileNotFoundException(inFile.getPath());
	File outFile = new File(workingDir, "TeXML2.xml");

	String sLeftWedge = "\\textless{}";
	String sRightWedge = "\\textgreater{}";

	// FileReader in = new FileReader(inFile);
	// FileWriter out = new FileWriter(outFile);
	BufferedReader in = new BufferedReader(new InputStreamReader(new FileInputStream(inFile),
		"UTF8"));
	BufferedWriter out = new BufferedWriter(new OutputStreamWriter(
		new FileOutputStream(outFile), "UTF8"));
	// System.err.println("convert: made it to try: workingDir = " +
	// workingDir.getAbsolutePath());
	try {
	    int c; /* character read */
	    boolean fInXmlElement = false;
	    while ((c = in.read()) != -1) {
		int c1; /* first next character read */
		int c2; /* second next character read */
		int c3; /* third next character read */
		int c4; /* fourth next character read */
		switch (c) {
		case '\\':
		    out.write("\\textbackslash{}");
		    break;
		case '{':
		    out.write("\\{");
		    break;
		case '}':
		    out.write("\\}");
		    break;
		case '$':
		    out.write("\\textdollar{}");
		    break;
		case '[':
		    out.write("\\textsquarebracketleft{}");
		    break;
		case ']':
		    out.write("\\textsquarebracketright{}");
		    break;
		case '&':
		    c1 = in.read();
		    if (c1 == 'l' || c1 == 'g') {
			c2 = in.read();
			if (c2 != -1 && (c2 == 't' || c2 == 'e')) {
			    c3 = in.read();
			    if (c3 != -1 && c3 == ';') {
				/* found "&lt;", "&le;", "&gt;" or "&ge;" */
				if (c1 == 'l')
				    out.write(sLeftWedge);
				else
				    out.write(sRightWedge);
				if (c2 == 'e')
				    out.write('=');
				break;
			    } else { /* c3 is EOF */
				out.write(c);
				out.write(c1);
				out.write(c2);
				break;
			    }
			} else { /* c2 is EOF */
			    out.write(c);
			    out.write(c1);
			    break;
			}
		    }
		    if (c1 == 'a') {
			c2 = in.read();
			if (c2 != -1 && c2 == 'm') {
			    c3 = in.read();
			    if (c3 != -1 && c3 == 'p') {
				c4 = in.read();
				if (c4 != -1 && c4 == ';') {
				    /*
				     * found "&amp;" so add backslash in front
				     * of it. This will then come out OK in the
				     * XML and the TeX, too.
				     */
				    out.write("\\&amp;");
				    break;
				} else { /* c4 is EOF */
				    out.write(c);
				    out.write(c1);
				    out.write(c2);
				    out.write(c3);
				    break;
				}
			    } else { /* c3 is EOF */
				out.write(c);
				out.write(c1);
				out.write(c2);
				break;
			    }
			} else { /* c2 is EOF */
			    out.write(c);
			    out.write(c1);
			    break;
			}
		    }
		    // need to take care of &#x..; cases for < > and &
		    // & = &#x26; &#38; &#o46; - or whatever octal is...
		    // < = &#x3c; &#60; &#o74;
		    // > = &#x3e; &#62; &#o76;
		    /* c1 is not 'a' */
		    out.write(c);
		    if (c1 != -1)
			out.write(c1);
		    break;
		case '#':
		    out.write("\\#");
		    break;
		case '^':
		    out.write("\\^{}");
		    break;
		case '_':
		    out.write("\\_");
		    break;
		case '~':
		    out.write("\\textasciitilde{}");
		    break;
		case '%':
		    out.write("\\%");
		    break;
		case '|':
		    out.write("\\textbar{}");
		    break;
		case '<':
		    fInXmlElement = false; /* be pessimistic */
		    c1 = in.read();
		    if (c1 != -1 && (c1 == '?' || c1 == '/' || c1 == '!')) {
			/* skip these; they are part of the XML */
			fInXmlElement = true;
			out.write(c);
			out.write(c1);
			break;
		    }
		    if (c1 == 't') {
			c2 = in.read();
			if (c2 != -1 && c2 == 'e') {
			    c3 = in.read();
			    if (c3 != -1 && c3 == 'x') {
				c4 = in.read();
				if (c4 != -1 && c4 == ':') {
				    /* found "<tex:"; skip it */
				    fInXmlElement = true;
				    out.write(c);
				    out.write(c1);
				    out.write(c2);
				    out.write(c3);
				    out.write(c4);
				    break;
				} else { /* c4 is EOF */
				    out.write(sLeftWedge);
				    out.write(c1);
				    out.write(c2);
				    out.write(c3);
				    break;
				}
			    } else { /* c3 is EOF */
				out.write(sLeftWedge);
				out.write(c1);
				out.write(c2);
				break;
			    }
			} else { /* c2 is EOF */
			    out.write(sLeftWedge);
			    out.write(c1);
			    break;
			}
		    }
		    /* c1 is not 't' */
		    out.write(sLeftWedge);
		    if (c1 != -1)
			out.write(c1);
		    break;
		case '>':
		    if (fInXmlElement)
			out.write(c);
		    else
			out.write(sRightWedge);
		    break;
		case '.':
		    in.mark(6);   // remember where we are so we can come back to it, if need be
		    c1 = in.read();
		    c2 = in.read();
		    if (c1 == '\u200b' && c2 == ' ') {
			/* period, zero width space, space produces normal space after the period */
			out.write(".\\  ");
		    } else if (c1 == '\u200c' && c2 == ' ') {
			/* period, zero width non-joiner, space produces sentence space after the period */
			    out.write(".\\ \\ ");
		    } else if (c1 == '\u200d' && c2 == ' ') {
			/* period, zero width joiner, space produces normal space after the period
			 * and also ensures no line-break after the period */
			    out.write(".~");
		    } else {
			out.write(c);
			//out.write(c1); need to skip the second one in case it needs special handling
			in.reset();  // return to where we were.  This helps with finding the second period in e.g., i.e., etc.
		    }
		    break;
		/*
		 * } # not special but typography u'\u00a9':
		 * r'\textcopyright{}', u'\u2011': r'\mbox{-}'
		 */
		default:
		    out.write(c);
		    break;
		}

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
}
