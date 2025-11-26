package xlingpaper.xxe;

import java.awt.Font;
import java.awt.Frame;

import javax.swing.JDialog;
import javax.swing.JFrame;

import com.xmlmind.guiutil.AWTUtil;
import com.xmlmind.guiutil.Alert;
import com.xmlmind.guiutil.FontChooserDialog;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.name.Name;


;

public class SetTableSizeCmd extends RecordableCommand {

    public boolean prepare(DocumentView docView, String parameter, int x, int y) {
	if (docView.getDocument() == null) {
	    // Alert.showError(docView.getPanel(),
	    // "docView.getDocument() is null");
	    return false;
	}

	MarkManager markManager = docView.getMarkManager();
	if (markManager == null) {
	    // Alert.showError(docView.getPanel(), "markManager is null");
	    return false;
	}

	Element editedElement = docView.getSelectedElement(/* implicit */true);
	if (editedElement == null) {
	    // Alert.showError(docView.getPanel(), "edited element is null");
	    return false;
	}
	if (editedElement.getName().localPart != "table") {
	    return false;
	}
	docView.getElementEditor().editElement(editedElement);

	// Alert.showError(docView.getPanel(), "returning true");
	return true;
    }

    protected Object doExecute(DocumentView docView, String parameter, int x, int y) {

	XLingPaperSetTableSizeDialog chooser = new XLingPaperSetTableSizeDialog();

	int iInitialHeaderRows = 0;
	int iInitialNonHeaderRows = 2;
	int iInitialColumns = 2;
	try {
	    // Alert.showError(docView.getPanel(), "parameter in= " +
	    // parameter);
	    int iSeparatorIndex = parameter.indexOf('|');
	    // String initValues[] = parameter.split("|");
	    // Alert.showError(docView.getPanel(), "size of initValues = " +
	    // initValues.length + "initValues[0]= " + initValues[0] +
	    // "initValues[1]= " + initValues[1] + "initValues[2]= " +
	    // initValues[2]);
	    // Alert.showError(docView.getPanel(), "header rows string in= "
	    // + parameter.substring(0, iSeparatorIndex));
	    iInitialHeaderRows = getValueFromParameter(iInitialHeaderRows, parameter.substring(0,
		    iSeparatorIndex));
	    // Alert.showError(docView.getPanel(), "header rows in= " +
	    // iInitialHeaderRows);
	    int iSeparatorIndex2 = parameter.indexOf(':');
	    // Alert.showError(docView.getPanel(), "separator 2 index in= " +
	    // iSeparatorIndex2);
	    // Alert.showError(docView.getPanel(), "nonheader rows string in= "
	    // + parameter.substring(iSeparatorIndex + 1, iSeparatorIndex2));
	    iInitialNonHeaderRows = getValueFromParameter(iInitialNonHeaderRows, parameter
		    .substring(iSeparatorIndex + 1, iSeparatorIndex2));
	    // Alert.showError(docView.getPanel(), "non header rows in= " +
	    // iInitialNonHeaderRows);
	    // Alert.showError(docView.getPanel(), "columns string in= "
	    // + parameter.substring(iSeparatorIndex2 + 1));
	    iInitialColumns = getValueFromParameter(iInitialColumns, parameter
		    .substring(iSeparatorIndex2 + 1));
	    // Alert.showError(docView.getPanel(), "columns in = " +
	    // iInitialColumns);
	} catch (Exception e) {
	    ; // ignore it
	}
	chooser.setIHeaderRows(iInitialHeaderRows);
	chooser.setINonHeaderRows(iInitialNonHeaderRows);
	chooser.setIColumns(iInitialColumns);
	chooser.setVisible(true);
	if (chooser.getReturnStatus() == XLingPaperSetTableSizeDialog.RET_CANCEL) {
	    return null;
	}
	// get results from dialog
	int iFinalHeaderRows = chooser.getIHeaderRows();
	int iFinalNonHeaderRows = chooser.getINonHeaderRows();
	int iFinalColumns = chooser.getIColumns();
	StringBuilder sb = new StringBuilder();
	if (iFinalHeaderRows > iInitialHeaderRows) {
	    sb.append(iFinalHeaderRows - iInitialHeaderRows);
	} else {
	    sb.append(0);
	}
	sb.append('|');
	if (iFinalNonHeaderRows > iInitialNonHeaderRows) {
	    sb.append(iFinalNonHeaderRows - iInitialNonHeaderRows);
	} else {
	    sb.append(0);
	}
	sb.append(':');

	if (iFinalColumns > iInitialColumns) {
	    sb.append(iFinalColumns - iInitialColumns);
	} else {
	    sb.append(0);
	}
	//Alert.showError(docView.getPanel(), "header rows out = " + iFinalHeaderRows);
	//Alert.showError(docView.getPanel(), "non header rows out = " + iFinalNonHeaderRows);
	//Alert.showError(docView.getPanel(), "columns out = " + iFinalColumns);
	//Alert.showError(docView.getPanel(), "result =  \"" + sb.toString() + "\"");

	return sb.toString();
    }

    private int getValueFromParameter(int iDefaultValue, String sValue) {
	try {
	    iDefaultValue = Integer.parseInt(sValue);
	} catch (NumberFormatException e) {
	    ; // do nothing
	}
	return iDefaultValue;
    }

}
