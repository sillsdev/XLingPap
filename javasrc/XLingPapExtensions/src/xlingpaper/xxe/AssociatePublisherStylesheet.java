package xlingpaper.xxe;

import java.io.File;
import java.io.IOException;
import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.DocumentTypeDeclaration;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xml.load.LoadDocument;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.name.Namespace;
import com.xmlmind.xmledit.view.DocumentView;

import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;

public class AssociatePublisherStylesheet extends RecordableCommand {
    boolean m_showAlerts = true; // used for debugging

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
	int separatorIndex = parameter.indexOf('|');
	String myFileName = null;
	String myURI = null;
	// Make sure the file exists and is a publisherStyleSheet
	try {
	    myFileName = parameter.substring(0, separatorIndex);
	    myURI = parameter.substring(separatorIndex + 1);
	    File f = new File(myFileName);

	    // Make sure the file or directory exists and isn't write protected
	    if (!f.exists()) {
		return fileErrorMessage(myFileName, "was not found");
	    }
	    Document pubStyleSheetDoc = LoadDocument.load(f);
	    Element pubRoot = pubStyleSheetDoc.getRootElement();
	    if (!"publisherStyleSheet".equals(pubRoot.name().localPart)) {
		return fileErrorMessage(myFileName, "is not a Publisher Style Sheet");
	    }
	} catch (IOException e1) {
	    return fileErrorMessage(myFileName, "could not be loaded");
	}
	ElementEditor elementEditor = docView.getElementEditor();
	Element editedElement = elementEditor.getEditedElement();

	if (editedElement == null) {
	    return null;
	}

	try {
	    Document doc = docView.getDocument();
	    Element root = doc.getRootElement();
	    if (root == null) {
		return null;
	    }
	    if ("lingPaper".equals(root.name().localPart)) {
		// Does not yet have an assigned publisher style sheet
		createStyledPaper(myURI, doc, root);
	    } else if ("xlingpaper".equals(root.name().localPart)) {
		// May have a publisher style sheet or may just have other info
		XNode daughter = root.firstChild();
		if ("styledPaper".equals(daughter.name().localPart)) {
		    // have already assigned a publisher style sheet
		    doc.beginEdit();
		    Element styleSheet = (Element) daughter.lastChild();
		    if (styleSheet == null) {
			return null;
		    }
		    Element xiInclude = createIncludeToPublisherStyleSheet(myURI);
		    ((Element) daughter).replaceChild(styleSheet, xiInclude);
		    doc.endEdit();
		} else {
		    // not supposed to be possible to do
		    return null;
		}
	    }

	    return null;
	} catch (Exception e) {
	    Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
	    return e.getMessage();
	}
    }

    private String fileErrorMessage(String myFileName, String msg) {
	return "Sorry, but the file (" + myFileName + ") " + msg + ".";
    }

    private void createStyledPaper(String parameter, Document doc, Element root) {
	doc.beginEdit();

	DocumentTypeDeclaration newDocType = new DocumentTypeDeclaration("xlingpaper",
		"-//XMLmind//DTD XLingPap//EN", "XLingPap.dtd", null);
	DocumentTypeDeclaration oldDocType = doc.getDocumentTypeDeclaration();
	doc.replaceChild(oldDocType, newDocType);

	Element xlingpaper = new Element(Name.get(Namespace.NONE, "xlingpaper"));
	xlingpaper.putAttribute(Name.get(Namespace.NONE, "version"), "2.24.0");
	Element newStyledPaper = new Element(Name.get(Namespace.NONE, "styledPaper"));
	xlingpaper.appendChild(newStyledPaper);

	Element newLingPaper = (Element) root.copy();
	newStyledPaper.appendChild(newLingPaper);

	Element xiInclude = createIncludeToPublisherStyleSheet(parameter);
	newStyledPaper.appendChild(xiInclude);

	doc.replaceChild(root, xlingpaper);
	doc.endEdit();
    }

    private Element createIncludeToPublisherStyleSheet(String parameter) {
	Element xiInclude = new Element(Name.get(Namespace.XI, "include"));
	xiInclude.putAttribute(Name.get(Namespace.NONE, "href"), parameter);
	xiInclude.putAttribute(Name.get(Namespace.NONE, "xpointer"), "element(/1)");
	return xiInclude;
    }

    // For debugging
    /*
     * private void showAlert(DocumentView docView, String msg) { if
     * (m_showAlerts) { Alert.showError(docView.getPanel(), msg); } }
     */
}
