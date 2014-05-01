package xlingpaper.xxe;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.view.DocumentView;

public class ConvertFileNameForXeLaTeX extends RecordableCommand {

    public boolean prepare(DocumentView docView, String parameter, int x, int y) {
	MarkManager markManager = docView.getMarkManager();
	if (markManager == null) {
	    return false;
	}

	// Selected element is not at issue for this command
//	Element editedElement = docView.getSelectedElement(/* implicit */true);
//	if (editedElement == null) {
//	    return false;
//	}
//	docView.getElementEditor().editElement(editedElement);
	return true;
    }

    protected Object doExecute(DocumentView docView, String parameter, int x, int y) {
//	ElementEditor elementEditor = docView.getElementEditor();
//	Element editedElement = elementEditor.getEditedElement();
//
//	if (editedElement == null) {
//	    return null;
//	}
	if (parameter == null || parameter.length() == 0) {
	    return null;
	}

	try {
	    StringBuffer sb = new StringBuffer();
	    for (int i = 0; i < parameter.length(); i++) {
		int code = parameter.codePointAt(i);
		if (code > 127) {
		    sb.append((Integer.toHexString(code)).toUpperCase());
		} else if (code == 32) {
		    sb.append("20"); // XXE can't use spaces
		} else if (code == 40) {
		    sb.append("28"); // TeX can't use (
		} else if (code == 41) {
		    sb.append("29"); // TeX can't use )
		} else if (code == 95) {
		    sb.append("5F"); // TeX can't use )
		} else {
		    sb.append(parameter.charAt(i));
		}
	    }
	    return sb.toString();
	} catch (Exception e) {
	    Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
	    return e.getMessage();
	}
    }

}
