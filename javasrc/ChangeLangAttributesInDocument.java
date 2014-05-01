package xlingpaper.xxe;


import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xmledit.view.DocumentView;

public class ChangeLangAttributesInDocument extends ChangeLangAttributes {
    boolean m_showAlerts = false; // used for debugging


    protected Object doExecute(DocumentView docView, String parameter, int x, int y) {
	super.doExecute(docView, parameter, x, y);
	try {

		Document doc = docView.getDocument();
		doc.beginEdit();
		ConvertLangAttributes("lang", sNewLangData, doc, "//langData[@lang='" + sOldLangData + "']");
		ConvertLangAttributes("lang", sNewGloss, doc, "//gloss[@lang='" + sOldGloss + "']");
		ConvertLangAttributes("id", sNewLangData, doc, "//language[@id='" + sOldLangData + "']");
		ConvertLangAttributes("id", sNewGloss, doc, "//language[@id='" + sOldGloss + "']");
		doc.endEdit();

	    return null;

	} catch (Exception e) {
	    Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
	    return null;
	}
    }

}
