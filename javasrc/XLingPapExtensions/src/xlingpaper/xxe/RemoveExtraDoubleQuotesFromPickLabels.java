package xlingpaper.xxe;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.view.DocumentView;

public class RemoveExtraDoubleQuotesFromPickLabels extends RecordableCommand {

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
	if (parameter == null || parameter.length() == 0) {
	    return null;
	}

	try {
	    StringBuffer sb = new StringBuffer();
	    String[] lines = parameter.split("\n");
	    for (String line : lines) {
		String[] quoteSegments = line.split("\"");
		//Alert.showError(docView.getPanel(), "line:'" + line + "' is split " + quoteSegments.length + " ways.");
		if (quoteSegments.length > 2) {
		    String noQuotes = line.replace("\"", "''");
		    sb.append('\"');
		    sb.append(noQuotes);
		    sb.append('\"');
		    sb.append('\n');
		}
		else {
		    sb.append(line);
		    sb.append('\n');
		}
	    }
	    return sb.toString();
	} catch (Exception e) {
	    Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
	    return e.getMessage();
	}
    }

}
