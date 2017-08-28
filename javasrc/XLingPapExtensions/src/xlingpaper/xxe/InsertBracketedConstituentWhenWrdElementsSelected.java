package xlingpaper.xxe;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Attribute;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.Node;
import com.xmlmind.xml.doc.Text;
import com.xmlmind.xml.doc.TextNode;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xml.doc.Node.Type;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.name.Namespace;
import com.xmlmind.xml.xpath.EvalException;
import com.xmlmind.xml.xpath.ParseException;
import com.xmlmind.xml.xpath.XPathUtil;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmledit.cmd.CommandBase;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.cmd.select.SelectNode;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.edit.TextLocation;

public class InsertBracketedConstituentWhenWrdElementsSelected extends RecordableCommand {
	// used for debugging
	boolean m_showAlerts = false;

	public boolean prepare(DocumentView docView, String parameter, int x, int y) {
		MarkManager markManager = docView.getMarkManager();
		if (markManager == null) {
			return false;
		}

		// Following do not work if more than one node is selected
		// Element editedElement = docView.getSelectedElement(/* implicit
		// */true);
		// if (editedElement == null) {
		// return false;
		// }
		// docView.getElementEditor().editElement(editedElement);
		return true;
	}

	protected Object doExecute(DocumentView docView, String parameter, int x, int y) {
		ElementEditor elementEditor = docView.getElementEditor();
		Element editedElement = elementEditor.getEditedElement();
		
		if (editedElement == null) {
			return null;
		}

		try {
			showAlert(docView, "before get leftMostNode");
			Node leftMostNode = docView.getSelectedNode();
			Node rightMostNode = docView.getSelectedNode2();
			if (rightMostNode == null) {
				// only one item selected; make sure right is same as left
				rightMostNode = leftMostNode;
			}

			showAlert(docView, "leftMostNode = " + leftMostNode.getXPath());
			showAlert(docView, "rightMostNode = " + rightMostNode.getXPath());
			BracketedConstituentInserter inserter = new BracketedConstituentInserter(docView,
					leftMostNode, rightMostNode, parameter);
			inserter.insert();

			return null;
		} catch (Exception e) {
			Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
			return e.getMessage();
		}
	}

	// For debugging
	private void showAlert(DocumentView docView, String msg) {
		if (m_showAlerts) {
			Alert.showError(docView.getPanel(), msg);
		}
	}
}
