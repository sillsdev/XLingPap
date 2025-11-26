package xlingpaper.xxe;

import java.util.Scanner;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.util.Console;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.DocumentTypeDeclaration;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.Node;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xml.load.LoadDocument;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.name.Namespace;
import com.xmlmind.xml.save.SaveDocument;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.edit.XMLClipboard;
import com.xmlmind.xmledit.edit.XMLTransferable;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmleditapp.cmd.process.ProcessCommandDialog;
import com.xmlmind.xmleditapp.cmd.process.TransformItem;

import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.ClipboardOwner;
import java.awt.datatransfer.Transferable;
import java.awt.datatransfer.StringSelection;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.awt.Toolkit;
import java.io.File;
import java.io.FileNotFoundException;

public class SetHtmlTableToClipboard extends RecordableCommand implements ClipboardOwner {
    boolean m_showAlerts = true; // used for debugging

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
	//Alert.showError(docView.getPanel(), "parameter = " + parameter);

	String content;
	try {
	    Scanner scanner =new Scanner(new File(parameter), "utf-8"); 
	    content = scanner.useDelimiter("\\Z").next();
	    scanner.close();
	} catch (FileNotFoundException e) {
	    Alert.showError(docView.getPanel(), "The file " + parameter + " was not found.");
	    e.printStackTrace();
	    return "The file " + parameter + " was not found.";
	}
	//Alert.showError(docView.getPanel(), "after scanner");
	StringSelection stringSelection = new StringSelection(content);
	Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
	clipboard.setContents(stringSelection, this);
	//Alert.showError(docView.getPanel(), "clipboard set");
	// with XXE 5.6 have to specify MIME of "application/xml" and the following does it
	XMLClipboard xxeClipboard = XMLClipboard.getInstance();
	xxeClipboard.set(content);
	return "";
    }

    @Override
    public void lostOwnership(Clipboard clipboard, Transferable contents) {
	// do nothing

    }
    // For debugging
    /*
     * private void showAlert(DocumentView docView, String msg) { if
     * (m_showAlerts) { Alert.showError(docView.getPanel(), msg); } }
     */
}
