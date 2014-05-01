package xlingpaper.xxe;


import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.Tree;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xml.xpath.XPathUtil;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.view.DocumentView;

public class RemoveFLExExportHomographNumbers extends RecordableCommand {
    boolean m_showAlerts = false; // used for debugging


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

	return true;
    }

    protected Object doExecute(DocumentView docView, String parameter, int x, int y) {
	try {
	    Document doc = docView.getDocument();
	    XNode[] results = XPathUtil.evalAsNodeSet("//object[@type='tHomographNumber']", doc);
		if (results == null) {
		    return null;
		}

		for (XNode node : results) {
		    Element element = (Element) node;
		    Tree parent = element.getParent();
		    parent.removeChild(element);
		}

	    return null;

	} catch (Exception e) {
	    Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
	    return null;
	}
    }

    // For debugging
    protected void showAlert(DocumentView docView, String msg) {
	if (m_showAlerts) {
	    Alert.showError(docView.getPanel(), msg);
	}
    }
}
