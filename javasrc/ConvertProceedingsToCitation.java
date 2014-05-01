package xlingpaper.xxe;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.name.Namespace;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.view.DocumentView;

public class ConvertProceedingsToCitation extends ConvertCollectionOrProceedingsToCitation{
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
	    Element proceedings = editedElement;
	    if (proceedings == null) {
		return null;
	    }
	    if (!"proceedings".equals(proceedings.name().localPart)) {
		return null;
	    }

	    Element refWork = proceedings.getParentElement();
	    if (refWork == null)
		return null;

		Element refAuthor = refWork.getParentElement();
		if (refAuthor == null) {
		    return null;
		}
		Element references = refAuthor.getParentElement();
		if (references == null) {
		    return null;
		}
		Element newProceedings = new Element(proceedings.name());
		Element newRefAuthor = new Element(Name.get(Namespace.NONE, "refAuthor"));
		Element newRefWork = new Element(refWork.name());
		String sDate = copyRefDate(refWork, newRefWork);
		Element newBook = new Element(Name.get(Namespace.NONE, "book"));
		Element newProcCitation = new Element(Name.get(Namespace.NONE, "procCitation"));
		newProceedings.appendChild(newProcCitation);			
		String citeName = null;		
		Element newRefTitle = null;
		boolean fProcEdPlural = true;
		Element[] children = proceedings.getChildElements();
		for (Element e : children) {
		    if ("url".equals(e.name().localPart)) {
			newProceedings.appendChild(e);
		    } else if ("dateAccessed".equals(e.name().localPart)) {
			newProceedings.appendChild(e);
		    } else if ("iso639-3code".equals(e.name().localPart)) {
			newProceedings.appendChild(e);
		    } else if ("comment".equals(e.name().localPart)) {
			newProceedings.appendChild(e);
		    } else if ("procEd".equals(e.name().localPart)) {
			fProcEdPlural = checkEditorPlural(fProcEdPlural, e);
			citeName = getAndSetCiteName(newRefAuthor, e);
		    } else if ("procEdInitials".equals(e.name().localPart)) {
			newRefAuthor.appendChild(copyTextIntoNewElement(e, "refAuthorInitials"));
		    } else if ("procTitle".equals(e.name().localPart)) {
			newRefTitle = copyTextIntoNewElement(e, "refTitle");
			newRefWork.appendChild(newRefTitle);
		    } else if ("procTitleLowerCase".equals(e.name().localPart)) {
			newRefWork.appendChild(copyTextIntoNewElement(e, "refTitleLowerCase"));
		    } else if ("procVol".equals(e.name().localPart)) {
			newBook.appendChild(copyTextIntoNewElement(e, "bVol"));
		    } else if ("location".equals(e.name().localPart)) {
			newBook.appendChild(copyTextIntoNewElement(e, "location"));
		    } else if ("publisher".equals(e.name().localPart)) {
			newBook.appendChild(copyTextIntoNewElement(e, "publisher"));
		    }
		}
		setAuthorRole(newRefWork, newRefTitle, fProcEdPlural);
		String newRefWorkId = "r" + citeName + sDate + "ProceedingsCitation";
		boolean result = askUserForIdAndSetIt(docView, newRefWorkId, newRefWork, newProcCitation, x, y);
		if (!result) {
		    // abort!
		    return null;
		}
		Document doc = docView.getDocument();
		if (doc == null) {
		    return null;
		}
		
		doc.beginEdit();
		try {
		    refWork.replaceChild(proceedings, newProceedings);
		} catch (Exception e) {
		    // TODO: handle exception
		    // can get null exception here if the original gloss element was
		    // selected; not sure why; ignore it
		}
		newRefWork.appendChild(newBook);
		newRefAuthor.appendChild(newRefWork);
		references.insertChild(refAuthor, newRefAuthor);
		doc.endEdit();
	    return null;
	} catch (Exception e) {
	    Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
	    return e.getMessage();
	}
    }
}
