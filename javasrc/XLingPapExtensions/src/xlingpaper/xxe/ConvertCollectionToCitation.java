package xlingpaper.xxe;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.Node;
import com.xmlmind.xml.doc.Text;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.name.Namespace;
import com.xmlmind.xml.validate.Data;
import com.xmlmind.xml.validate.IDDataTypeImpl;
import com.xmlmind.xml.validate.IdEntry;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmleditapp.cmd.helper.Prompt;

public class ConvertCollectionToCitation extends ConvertCollectionOrProceedingsToCitation {
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
			Element collection = editedElement;
			if (!"collection".equals(collection.name().localPart)) {
				return null;
			}

			Element refWork = collection.getParentElement();
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
			Element newCollection = new Element(collection.name());
			Element newRefAuthor = new Element(Name.get(Namespace.NONE, "refAuthor"));
			Element newRefWork = new Element(refWork.name());
			Element newBook = new Element(Name.get(Namespace.NONE, "book"));
			Element newCollCitation = new Element(Name.get(Namespace.NONE, "collCitation"));
			newCollection.appendChild(newCollCitation);
			String sDate = "";
			String citeName = null;
			boolean fCollEdPlural = true;
			Element newRefTitle = null;
			Element[] children = collection.getChildElements();
			for (Element e : children) {
				if ("url".equals(e.name().localPart)) {
					newCollection.appendChild(e);
				} else if ("dateAccessed".equals(e.name().localPart)) {
					newCollection.appendChild(e);
				} else if ("iso639-3code".equals(e.name().localPart)) {
					newCollection.appendChild(e);
				} else if ("comment".equals(e.name().localPart)) {
					newCollection.appendChild(e);
				} else if ("collEd".equals(e.name().localPart)) {
					fCollEdPlural = checkEditorPlural(fCollEdPlural, e);
					citeName = getAndSetCiteName(newRefAuthor, e);
				} else if ("collEdInitials".equals(e.name().localPart)) {
					newRefAuthor.appendChild(copyTextIntoNewElement(e, "refAuthorInitials"));
				} else if ("collTitle".equals(e.name().localPart)) {
					setAuthorRole(newRefWork, fCollEdPlural);
					sDate = copyRefDate(refWork, newRefWork);
					newRefTitle = copyTextIntoNewElement(e, "refTitle");
					newRefWork.appendChild(newRefTitle);
				} else if ("collTitleLowerCase".equals(e.name().localPart)) {
					newRefWork.appendChild(copyTextIntoNewElement(e, "refTitleLowerCase"));
				} else if ("edition".equals(e.name().localPart)) {
					newBook.appendChild(copyTextIntoNewElement(e, "edition"));
				} else if ("collVol".equals(e.name().localPart)) {
					newBook.appendChild(copyTextIntoNewElement(e, "bVol"));
				} else if ("seriesEd".equals(e.name().localPart)) {
					newBook.appendChild(copyTextIntoNewElement(e, "seriesEd"));
				} else if ("seriesEdInitials".equals(e.name().localPart)) {
					newBook.appendChild(copyTextIntoNewElement(e, "seriesEdInitials"));
				} else if ("series".equals(e.name().localPart)) {
					newBook.appendChild(copyTextIntoNewElement(e, "series"));
				} else if ("location".equals(e.name().localPart)) {
					newBook.appendChild(copyTextIntoNewElement(e, "location"));
				} else if ("publisher".equals(e.name().localPart)) {
					newBook.appendChild(copyTextIntoNewElement(e, "publisher"));
				}
			}
			String newRefWorkId = "r" + citeName + sDate + "CollectionCitation";
			boolean result = askUserForIdAndSetIt(docView, newRefWorkId, newRefWork,
					newCollCitation, x, y);
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
				refWork.replaceChild(collection, newCollection);
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
