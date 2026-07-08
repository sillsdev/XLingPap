package xlingpaper.xxe;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Attribute;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.Node;
import com.xmlmind.xml.doc.Text;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xml.doc.Node.Type;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.name.Namespace;
import com.xmlmind.xml.xpath.EvalException;
import com.xmlmind.xml.xpath.ParseException;
import com.xmlmind.xml.xpath.XPathUtil;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;

public class ExpandInterlinearRef extends RecordableCommand {
	// used for debugging
	boolean m_showAlerts = false;

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

		try {
			Element interlinearRef = editedElement;
			if (!"interlinearRef".equals(interlinearRef.name().localPart)) {
				return null;
			}

			Document doc = docView.getDocument();
			String textref = interlinearRef.getAttribute(Name.get("textref"));
			if (textref != null) {
				String sXPath = "//interlinear-text/descendant::interlinear[@text='" + textref
						+ "']";
				showAlert(docView, "sXPath='" + sXPath + "'");
				XNode[] results = XPathUtil.evalAsNodeSet(sXPath, doc);
				if (results.length == 0) {
					return null;
				}
				Element interlinear = (Element) results[0].deepCopy();
				interlinear.removeAttribute(Name.get(Namespace.NONE, "text"));
				Element parent = interlinearRef.getParentElement();
				if (parent != null) {
					parent.replaceChild(interlinearRef, interlinear);
				}
			}
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
