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

public class InsertBracketedConstituentWhenTextSelected extends RecordableCommand {
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
			Node leftMostNode;
			Node rightMostNode;
			MarkManager markManager = docView.getMarkManager();
			TextLocation dotTextLoc = markManager.getDot();
			TextLocation markTextLoc = markManager.getMark();
			showAlert(docView, "Before checking dot and mark locations");
			if (dotTextLoc == null || markTextLoc == null) {
				return null;
			}
			long lDot = dotTextLoc.getPositionFromBegin();
			long lMark = markTextLoc.getPositionFromBegin();
			showAlert(docView, "dot =" + lDot + " mark=" + lMark);
			if ((lMark - lDot) > 0) {
				// dot is to the left of mark
				leftMostNode = getWrdNodeContainingText(docView, dotTextLoc);
				rightMostNode = getWrdNodeContainingText(docView, markTextLoc);
			} else {
				// dot is to the right of mark
				rightMostNode = getWrdNodeContainingText(docView, dotTextLoc);
				leftMostNode = getWrdNodeContainingText(docView, markTextLoc);
//				showAlert(docView, "dot is to the right of mark");
//				docView.executeCommand("selectNode", "self[implicitNode]", 0, 0);
//				rightMostNode = docView.getSelectedNode();
//				// rightMostNode is the one where the dot is
//				while (rightMostNode != null && !"wrd".equals(rightMostNode.name().localPart)) {
//					rightMostNode = rightMostNode.getParentElement();
//				}
//				showAlert(docView, "rightmost = " + rightMostNode.getXPath());
//				showAlert(docView, "before trying to get text node");
//				TextNode tn = markTextLoc.getTextNode();
//				showAlert(docView, "tn = " + tn.getXPath());
//				leftMostNode = tn.getParentElement();
//				while (leftMostNode != null && !"wrd".equals(leftMostNode.name().localPart)) {
//					leftMostNode = leftMostNode.getParentElement();
//				}
//				showAlert(docView, "leftmost = " + leftMostNode.getXPath());
			}
			BracketedConstituentInserter inserter = new BracketedConstituentInserter(docView,
					leftMostNode, rightMostNode, parameter);
			inserter.insert();

			return null;
		} catch (Exception e) {
			Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
			return e.getMessage();
		}
	}

	private Node getWrdNodeContainingText(DocumentView docView, TextLocation textLoc) {
		Node wrdNode;
		TextNode tn = textLoc.getTextNode();
		showAlert(docView, "tn = " + tn.getXPath());
		wrdNode = tn.getParentElement();
		while (wrdNode != null && !"wrd".equals(wrdNode.name().localPart)) {
			wrdNode = wrdNode.getParentElement();
		}
		showAlert(docView, "wrd node = " + wrdNode.getXPath());
		return wrdNode;
	}

	// For debugging
	private void showAlert(DocumentView docView, String msg) {
		if (m_showAlerts) {
			Alert.showError(docView.getPanel(), msg);
		}
	}
}
