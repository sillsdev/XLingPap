package xlingpaper.xxe;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.Reader;
import java.io.Writer;
import java.net.URL;
import java.net.URLConnection;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.util.Console;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.DocumentTypeDeclaration;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xml.load.LoadDocument;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.name.Namespace;
import com.xmlmind.xml.save.SaveDocument;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmleditapp.cmd.process.ProcessCommandDialog;
import com.xmlmind.xmleditapp.cmd.process.TransformItem;

import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.ClipboardOwner;
import java.awt.datatransfer.Transferable;
import java.awt.datatransfer.StringSelection;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.awt.Toolkit;

import org.ccil.cowan.tagsoup.*;
import org.xml.sax.ContentHandler;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXNotRecognizedException;
import org.xml.sax.SAXNotSupportedException;
import org.xml.sax.XMLReader;

public class GetHtmlTableFromClipboard extends RecordableCommand {
    boolean m_showAlerts = true; // used for debugging

    private static Parser theParser = null;
    private static HTMLSchema theSchema = null;
    private static String theOutputEncoding = null;

    public boolean prepare(DocumentView docView, String parameter, int x, int y) {
	MarkManager markManager = docView.getMarkManager();
	if (markManager == null) {
	    return false;
	}

	Element editedElement = docView.getSelectedElement(/* implicit */true);
	if (editedElement == null) {
	    return false;
	}
	docView.getElementEditor().editElement(editedElement);
	return true;
    }

    protected Object doExecute(DocumentView docView, String parameter, int x, int y) {
	// Alert.showError(docView.getPanel(), "parameter = " + parameter);
	String html = getClipboardContents();
	if (!html.isEmpty()) {
	    try {
		PrintWriter writer = new PrintWriter(parameter, "UTF-8");
		writer.println(html);
		writer.close();
	    } catch (IOException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	    }
	    String dst;
	    // tag soup stuff taken from CommandLine.java
	    int j = parameter.lastIndexOf('.');
	    if (j == -1)
		dst = parameter + ".xhtml";
	    else if (parameter.endsWith(".xhtml"))
		dst = parameter + "_";
	    else
		dst = parameter.substring(0, j) + ".xhtml";
	    // Alert.showError(docView.getPanel(), "dst = " + dst);
	    OutputStream os = null;
	    try {
		os = new FileOutputStream(dst);
	    } catch (FileNotFoundException e1) {
		Alert.showError(docView.getPanel(), "FileNotFoundException: " + e1.getMessage());
		e1.printStackTrace();
		return null;
	    }
	    // Alert.showError(docView.getPanel(), "After new os");
	    XMLReader r = new Parser();
	    theSchema = new HTMLSchema();

	    try {
		r.setProperty(Parser.schemaProperty, theSchema);
		// Alert.showError(docView.getPanel(), "After new parser");
		r.setFeature(Parser.defaultAttributesFeature, false);
		r.setFeature(Parser.ignoreBogonsFeature, true);
		r.setFeature(Parser.CDATAElementsFeature, false);
		// Alert.showError(docView.getPanel(),
		// "After setting features");

		Writer w;
		w = new OutputStreamWriter(os, "utf-8");
		// Alert.showError(docView.getPanel(),
		// "Before content handler");
		XMLWriter xw;
		xw = new XMLWriter(w);
		xw.setPrefix(theSchema.getURI(), "");
		ContentHandler h = xw;
		// Alert.showError(docView.getPanel(),
		// "Before set content handler");
		r.setContentHandler(h);
		// Alert.showError(docView.getPanel(),
		// "After set content handler");
		InputSource s = new InputSource();

		String uri = "file:///" + parameter.replace('\\', '/');

		s.setSystemId(uri);
		s.setEncoding("utf-8");
		// Alert.showError(docView.getPanel(), "before r.parse(s)");
		r.parse(s);
		// Alert.showError(docView.getPanel(), "After r.parse(s)");
		// Try to close input file so it can be deleted later; does not really work
		// It may be that the file is locked by the parse() method and we have no way to
		// get to it.
		InputStream is = s.getByteStream();
		if (is != null) {
		    is.close();
		    //Alert.showError(docView.getPanel(), "ByteStream: After is.close()");
		}
		Reader isr = s.getCharacterStream();
		if (isr != null) {
		    isr.close();
		    //Alert.showError(docView.getPanel(), "After isr.close()");
		}
		
		URL basis = new URL("file", "", System.getProperty("user.dir") + "/.");
		URL url = new URL(basis, uri);
		URLConnection c = url.openConnection();
		is = c.getInputStream();
		if (is != null) {
		    is.close();
		    //Alert.showError(docView.getPanel(), "URL: After is.close()");
		}
		os.close();
		// Alert.showError(docView.getPanel(), "before os.close()");
		w.close();
		// Alert.showError(docView.getPanel(), "before w.close()");
	    } catch (SAXNotRecognizedException e) {
		Alert.showError(docView.getPanel(), "SAXNotRecognizedException: " + e.getMessage());
		e.printStackTrace();
	    } catch (SAXNotSupportedException e) {
		Alert.showError(docView.getPanel(), "SAXNotSupportedException: " + e.getMessage());
		e.printStackTrace();
	    } catch (IOException e) {
		Alert.showError(docView.getPanel(), "IOException: " + e.getMessage());
		e.printStackTrace();
	    } catch (SAXException e) {
		Alert.showError(docView.getPanel(), "SAXException: " + e.getMessage());
		e.printStackTrace();
	    }
	}
	return html;
    }

    public String getClipboardContents() {
	// / we are only interested in HTML results

	String result = "";
	Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
	// odd: the Object param of getContents is not currently used
	Transferable contents = clipboard.getContents(null);
	DataFlavor flavorsToUse[] = contents.getTransferDataFlavors();
	boolean hasTransferableText = (contents != null)
		&& contents.isDataFlavorSupported(DataFlavor.stringFlavor);
	if (hasTransferableText) {
	    try {
		DataFlavor flavor = DataFlavor.selectBestTextFlavor(flavorsToUse);
		if (flavor.isMimeTypeEqual("text/html")) {
		    InputStreamReader sr = (InputStreamReader) contents.getTransferData(flavor);
		    StringBuilder sb = new StringBuilder();
		    int c;
		    while ((c = sr.read()) != -1) {
			sb.append((char) c);
		    }
		    result = sb.toString();
		}
	    } catch (UnsupportedFlavorException ex) {
		System.out.println(ex);
		ex.printStackTrace();
	    } catch (IOException ex) {
		System.out.println(ex);
		ex.printStackTrace();
	    }
	}
	return result;

    }

    // For debugging
    /*
     * private void showAlert(DocumentView docView, String msg) { if
     * (m_showAlerts) { Alert.showError(docView.getPanel(), msg); } }
     */
}
