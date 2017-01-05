package xlingpaper.xxe;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Attribute;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.Node;
import com.xmlmind.xml.doc.Text;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.name.Namespace;
import com.xmlmind.xml.validate.Data;
import com.xmlmind.xml.validate.IDDataTypeImpl;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmleditapp.cmd.helper.Prompt;

public abstract class ConvertCollectionOrProceedingsToCitation extends RecordableCommand {
    boolean m_showAlerts = true; // used for debugging

    protected boolean askUserForIdAndSetIt(DocumentView docView, String newRefWorkId,
	    Element newRefWork, Element newCitation, int x, int y) {
	LocalizeString ls = new LocalizeString();
	ls.prepare(docView, null, x, y);
	String normalizedID = newRefWorkId.replace(" ", "");
	String sPromptString = (String)ls.doExecute(docView, "java.convertCollOrProcToCitationPrompt", x, y);
	String promptString = String.format(sPromptString, normalizedID); 
	    // "'Id to use' 'Please key the id you want to use.  One possibility is "
		// + normalizedID + ".'";
	String usersID = "";
	Prompt p = new Prompt();
	while (usersID.length() == 0) {
	    p.prepare(docView, promptString, x, y);
	    Object result = p.execute(docView, promptString, x, y);
	    try {
		usersID = ((String) result).trim();
	    } catch (Exception e) {
		// user aborted (clicked on Cancel or hit Esc key)
		return false;
	    }
	    if (usersID.length() == 0) {
		continue;
	    }
	    try {
		IDDataTypeImpl id = new IDDataTypeImpl();
		Data data = id.parseData(usersID, null, null);
		//// XLingPaperUtils.showAlert(false, docView, "data = " + data);
	    } catch (Exception e) {
		String sInvalidId = (String)ls.doExecute(docView, "java.convertCollOrProcToCitation", x, y);
		// if we get an exception, then we assume that what the user
		// typed is not valid
		//// XLingPaperUtils.showAlert(true,	docView,String.format(sInvalidId, usersID));
		usersID = "";
		continue;
	    }
	    newRefWork.putAttribute(Name.get(Namespace.NONE, "id"), usersID);
	    newCitation.putAttribute(Name.get(Namespace.NONE, "refToBook"), usersID);
	}
	return true;
    }
    protected boolean checkEditorPlural(boolean fPlural, Element e) {
	Name plural = Name.get(Namespace.NONE, "plural");
	if (!e.hasAttribute(plural)) {
	    return fPlural;
	}
	String sPlural = e.attributeValue(plural);
	if (sPlural.length() > 0) {
	    if (sPlural.equals("no")) {
		fPlural = false;
	    }
	}
	return fPlural;
    }
    protected String copyRefDate(Element refWork, Element newRefWork) {
	Element[] refWorkChildren = refWork.getChildElements();
	for (Element e : refWorkChildren) {
	    if ("refDate".equals(e.name().localPart)) {
		newRefWork.appendChild(copyTextIntoNewElement(e, "refDate"));
		return e.getText();
	    }
	}
	return null;
    }

    protected Element copyTextIntoNewElement(Element e, String elementName) {
	Element newElement = new Element(Name.get(Namespace.NONE, elementName));
	Text newText = new Text();
	newElement.appendChild(newText);
	newElement.setText(e.getText());
	return newElement;
    }

    protected String getAndSetCiteName(Element newRefAuthor, Element e) {
	String citeName;
	String authorName = e.getText();
	newRefAuthor.putAttribute(Name.get(Namespace.NONE, "name"), authorName);
	int i = authorName.indexOf(",");
	if (i > 0) {
	    citeName = authorName.substring(0, i);
	} else {
	    citeName = authorName;
	}
	newRefAuthor.putAttribute(Name.get(Namespace.NONE, "citename"), citeName);
	return citeName;
    }

    protected void setAuthorRole(Element newRefWork, boolean fPlural) {
	Element newAuthorRole = new Element(Name.get(Namespace.NONE, "authorRole"));
	Text newText = new Text();
	newAuthorRole.appendChild(newText);
	String sEditor = "ed" + (fPlural ? "s" : "");
	newAuthorRole.setText(sEditor);
	newRefWork.appendChild(newAuthorRole);
    }
}