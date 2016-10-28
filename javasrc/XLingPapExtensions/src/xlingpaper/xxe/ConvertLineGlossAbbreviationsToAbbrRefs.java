package xlingpaper.xxe;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xmledit.view.DocumentView;

import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;
import xlingpaper.xxe.*;

public class ConvertLineGlossAbbreviationsToAbbrRefs extends ConvertAnyAbbreviationsToAbbrRefs {
 
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
	    Element lastWrd = editedElement.getParentElement();
	    if (lastWrd == null) {
		return null;
	    }

	    Element line = lastWrd.getParentElement();
	    if (line == null) {
		return null;
	    }

	    Element[] wrds = line.getChildElements();
	    for (Element wrd : wrds) {
		Element gloss = (Element) wrd.firstChild();
		if (gloss == null) {
		    return null;
		}
		convertAnyAbbreviations(docView, gloss, wrd);
	    }
	} catch (Exception e) {
	    Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
	    return e.getMessage();
	}
	return null;

    }
}
