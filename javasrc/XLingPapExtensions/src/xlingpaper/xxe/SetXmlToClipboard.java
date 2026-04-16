package xlingpaper.xxe;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.view.DocumentView;

import java.awt.datatransfer.Clipboard;
import java.awt.Toolkit;

public class SetXmlToClipboard extends RecordableCommand {
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
		
		// Create our custom transferable
		XmlTransferable transferable = new XmlTransferable(parameter);

		// Access the system clipboard
		Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();

		// Set the contents (null for the owner parameter is fine for most
		// cases)
		clipboard.setContents(transferable, null);

		System.out.println("XML successfully pushed to clipboard with custom MIME types.");
		return "";
	}

	// For debugging
	
	private void showAlert(DocumentView docView, String msg) {
		if (m_showAlerts) {
			Alert.showError(docView.getPanel(), msg);
		}
	}
	 
}
