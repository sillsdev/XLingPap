package xlingpaper.xxe;


import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.xpath.EvalException;
import com.xmlmind.xml.xpath.ParseException;
import com.xmlmind.xml.xpath.XPathUtil;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.view.DocumentView;

public class ChangeLangAttributes extends RecordableCommand {
    boolean m_showAlerts = false; // used for debugging
    String sConfigFileDirectory;
    String sOldLangData;
    String sNewLangData;
    String sOldGloss;
    String sNewGloss;


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
	try {
	    showAlert(docView, "parameter =|" + parameter + "|");
	    String[] params = parameter.split(" ");
	    if (params.length != 5) {
		showAlert(docView, "Wrong number of parameters");
		return null;
	    }
	    sOldLangData = params[0];
	    sNewLangData = params[1];
	    sOldGloss = params[2];
	    sNewGloss = params[3];
	    sConfigFileDirectory = params[4].replace('*', ' ');

	    showAlert(docView, "config dir = " + sConfigFileDirectory + "; old langData = "
		    + sOldLangData + "; new langData = " + sNewLangData + "; old gloss = "
		    + sOldGloss + "; new gloss = " + sNewGloss);

	    return null;

	} catch (Exception e) {
	    Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
	    return null;
	}
    }

    protected void ConvertLangAttributes(String sAttributeName, String sNewLang, Document doc, String sXpath)
	    throws ParseException, EvalException {
	XNode[] results = XPathUtil.evalAsNodeSet(sXpath, doc);
	if (results == null) {
	    return;
	}

	for (XNode node : results) {
	    Element element = (Element) node;
	    element.putAttribute(Name.get(sAttributeName), sNewLang);
	}
    }

    // For debugging
    protected void showAlert(DocumentView docView, String msg) {
	if (m_showAlerts) {
	    Alert.showError(docView.getPanel(), msg);
	}
    }
}
