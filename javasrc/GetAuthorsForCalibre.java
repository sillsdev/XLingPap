package xlingpaper.xxe;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.Charset;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xml.doc.Node.Type;
import com.xmlmind.xml.xpath.XPathUtil;
import com.xmlmind.xmledit.view.DocumentView;

import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.MarkManager;

public class GetAuthorsForCalibre extends RecordableCommand {
    public boolean prepare(DocumentView docView, String parameter, int x, int y) {
	// Alert.showError(docView.getPanel(), "In DeleteFile prepare");
	// Alert.showError(docView.getPanel(), "prepare: parameter = |" +
	// parameter + "|");
	MarkManager markManager = docView.getMarkManager();
	if (markManager == null) {
	    // Alert.showError(docView.getPanel(),
	    // "prepare: markManager is null");
	    return false;
	}

	Element editedElement = docView.getSelectedElement(/* implicit */true);
	if (editedElement == null) {
	    // Alert.showError(docView.getPanel(), "prepare: returning false");
	    return false;
	}
	docView.getElementEditor().editElement(editedElement);
	// Alert.showError(docView.getPanel(), "prepare: returning true");
	return true;
    }

    protected Object doExecute(DocumentView docView, String parameter, int x, int y) {
	// Alert.showError(docView.getPanel(),
	// "In GetHighestCalibreBookId doExecute");
	// Alert.showError(docView.getPanel(), "doExecute: parameter = |" +
	// parameter + "|");
	try {
	    Document doc = docView.getDocument();
	    String sXpath = "//author";
	    XNode[] results = XPathUtil.evalAsNodeSet(sXpath, doc);
	    if (results == null) {
		return "\"\" \"\"";
	    }

	    StringBuilder sb = new StringBuilder();
	    int i = 1;
	    int iEnd = results.length;
	    sb.append("\"");
	    for (XNode node : results) {
		if (node.type() == XNode.Type.ELEMENT) {
		    Element author = (Element) node;
		    sb.append(author.getText());
		    if (i < iEnd) {
			sb.append(", ");
			i++;
		    }
		}
	    }
	    sb.append("\" \"");
	    sXpath = "//publisherStyleSheetPublisher";
	    String publisher = XPathUtil.evalAsString(sXpath, doc);
	    sb.append(publisher);
	    sb.append("\"");
	    return sb.toString();
	} catch (Exception e) {
	    Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
	    return e.getMessage();
	}
    }

    private String setMessage(String message) {
	return "XLingPaper-" + message + "-XLingPaper";
    }
}
