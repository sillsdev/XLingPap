package xlingpaper.xxe;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.DocumentTypeDeclaration;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xmledit.view.DocumentView;

import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;

public class RemovePublisherStylesheet extends RecordableCommand {
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
	    if (!"xlingpaper".equals(root.name().localPart)) {
		return null;
	    }
	    XNode styledPaper = root.firstChild();
	    if (styledPaper == null) {
		return null;
	    }
	    if (!"styledPaper".equals(styledPaper.name().localPart)) {
		return null;
	    }
	    Element lingPaper = (Element) styledPaper.firstChild();
	    if (lingPaper == null) {
		return null;
	    }
	    if (!"lingPaper".equals(lingPaper.name().localPart)) {
		return null;
	    }
	    doc.beginEdit();
	    Element newLingPaper = (Element) lingPaper.copy();
	    doc.replaceChild(root, newLingPaper);
	    
		DocumentTypeDeclaration newDocType = new DocumentTypeDeclaration("lingPaper",
			"-//XMLmind//DTD XLingPap//EN", "XLingPap.dtd", null);
		DocumentTypeDeclaration oldDocType = doc.getDocumentTypeDeclaration();
		doc.replaceChild(oldDocType, newDocType);

	    doc.endEdit();

	    return null;
	} catch (Exception e) {
	    showAlert(docView, "doExecute: Exception caught:" + e.getMessage());
	    return e.getMessage();
	}
    }

    // For debugging

    private void showAlert(DocumentView docView, String msg) {
	if (m_showAlerts) {
	    Alert.showError(docView.getPanel(), msg);
	}
    }

}
