package xlingpaper.xxe;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.xpath.XPathUtil;
import com.xmlmind.xmledit.view.DocumentView;

import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;
import xlingpaper.xxe.*;

public class ConvertEveryGlossAbbreviationToAbbrRefInSelection extends ConvertAnyAbbreviationsToAbbrRefs {
 
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
	Element selectedElement = docView.getSelectedElement(/* implicit */true);
	if (selectedElement == null) {
	    return null;
	}

	try {
	    XNode[] results = XPathUtil.evalAsNodeSet("descendant-or-self::gloss", selectedElement);
		if (results == null) {
		    return null;
		}

		for (XNode node : results) {
		    Element gloss = (Element) node;
			if (gloss == null) {
			    continue;
			}
			Element parent = gloss.getParentElement();
			if (parent == null) {
			    continue;
			}
			convertAnyAbbreviations(docView, gloss, parent);
		}
	} catch (Exception e) {
	    Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
	    return e.getMessage();
	}
	return null;

    }
}
