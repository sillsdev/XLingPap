package xlingpaper.xxe;

import java.io.File;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.load.LoadDocument;
import com.xmlmind.xml.save.SaveDocument;
import com.xmlmind.xml.save.SaveOptions;
import com.xmlmind.xmledit.view.DocumentView;

public class ChangeDefaultLangAttributesInTemplates extends ChangeLangAttributes {
    boolean m_showAlerts = false; // used for debugging

    protected Object doExecute(DocumentView docView, String parameter, int x, int y) {
	super.doExecute(docView, parameter, x, y);
	try {

	    String templateFileNames[] = { "elementTemplates",
		    ".." + File.separator + "templates" + File.separator + "XLingPapTemplate",
		    ".." + File.separator + "templates" + File.separator + "XLingPapTomPayneGrammaticalDescription",
		    ".." + File.separator + "templates" + File.separator + "XLingPapPartsTemplate",
		    ".." + File.separator + "templates" + File.separator + "XLingPapChaptersTemplate" };

	    SaveOptions saveOptions = new SaveOptions();
	    saveOptions.indent = -1;
	    saveOptions.maxLineLength = 1000;

	    for (String templateFileName : templateFileNames) {
		showAlert(docView, "working on file = " + templateFileName);
		File templateFile = new File(sConfigFileDirectory + File.separator
			+ templateFileName + ".xml");
		Document doc = LoadDocument.load(templateFile);
		ConvertLangAttributes("lang", sNewLangData, doc, "//langData[@lang='" + sOldLangData + "']");
		ConvertLangAttributes("lang", sNewGloss, doc, "//gloss[@lang='" + sOldGloss + "']");
		ConvertLangAttributes("id", sNewLangData, doc, "//language[@id='" + sOldLangData + "']");
		ConvertLangAttributes("id", sNewGloss, doc, "//language[@id='" + sOldGloss + "']");
		SaveDocument.save(doc, templateFile, saveOptions);
	    }

	    return null;

	} catch (Exception e) {
	    Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
	    return null;
	}
    }

}
