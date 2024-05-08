package xlingpaper.xxe;

import java.io.IOException;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.wxs.validate.ValidationErrors;
import com.xmlmind.xml.xpath.EvalException;
import com.xmlmind.xml.xpath.ParseException;
import com.xmlmind.xml.xpath.XPathUtil;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.cmd.validate.CheckValidityDialog;
import com.xmlmind.xmledit.edit.MarkManager;

public class FindAnyDuplicateAuthors extends RecordableCommand {
	boolean m_showAlerts = false; // used for debugging

	public boolean prepare(DocumentView docView, String parameter, int x, int y) {
//		 Alert.showError(docView.getPanel(),
//		 "In FindAnyDuplicateAuthors prepare");
//		 Alert.showError(docView.getPanel(), "prepare: parameter = |" +
//		 parameter + "|");
		MarkManager markManager = docView.getMarkManager();
		if (markManager == null) {
//			 Alert.showError(docView.getPanel(),
//			 "prepare: markManager is null");
			return false;
		}

		// Selected element is not at issue for this command
		// Element editedElement = docView.getSelectedElement(/* implicit
		// */true);
		// if (editedElement == null) {
		// Alert.showError(docView.getPanel(), "prepare: returning false");
		// return false;
		// }
		// docView.getElementEditor().editElement(editedElement);
		// Alert.showError(docView.getPanel(), "prepare: returning true");
		return true;
	}

	protected Object doExecute(DocumentView docView, String parameter, int x, int y) {
		try {
			ValidationErrors validationErrors = new ValidationErrors();
			String sDocumentPath = parameter;
			LocalizeString ls = new LocalizeString();
			ls.prepare(docView, null, x, y);

			int iDuplicateAuthors = findAnyDuplicateAuthors(docView, validationErrors,
					sDocumentPath, ls);
			if (iDuplicateAuthors > 0) {
				showDuplicateAuthorsDialog(docView, validationErrors, ls);
				return "hadDuplicateAuthors";
			}

		} catch (Exception e) {
			Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
			return e.getMessage();
		}
		return "allClear";
	}

	private void showDuplicateAuthorsDialog(DocumentView docView,
			ValidationErrors validationErrors, LocalizeString ls) {
		String sDialogTitle = (String) ls.doExecute(docView, "java.duplicateAuthorsDialogTitle", 0, 0);
		CheckValidityDialog validityDialog = new CheckValidityDialog(docView.getPanel(),
				sDialogTitle);
		validityDialog.setModal(false);
		validityDialog.setLocationRelativeTo(null);
		validityDialog.showDiagnostics(validationErrors.toArray(), docView, 1);
	}

	private int findAnyDuplicateAuthors(DocumentView docView, ValidationErrors validationErrors,
			String sDocumentPath, LocalizeString ls) throws ParseException, EvalException,
			IOException {
		Document doc = docView.getDocument();
		String sXpath = "//refAuthor";
		XNode[] results = XPathUtil.evalAsNodeSet(sXpath, doc);
		if (results == null) {
			return 0;
		}

		int iDuplicateAuthorCount = 0;
		showAlert(docView, "Before check for duplicate authors");
		for (XNode node : results) {
			String authorName = node.attributeValue(Name.get("name"));
			authorName = authorName.replaceAll("'", "’");

			String sXpathPreceding = "preceding-sibling::refAuthor[@name='" + authorName + "'][1]";
			XNode[] duplicateResults = XPathUtil.evalAsNodeSet(sXpathPreceding, node);
			for (XNode dupNode : duplicateResults) {
				String sAuthorIsDuplicate = (String) ls.doExecute(docView,
						"java.authorisduplicate", 0, 0);
				String sDuplicatePrevious = (String) ls.doExecute(docView,
						"java.duplicateprevious", 0, 0);
				validationErrors.append((Element) node, sAuthorIsDuplicate,
						String.format("%s", authorName));
				validationErrors.append((Element) dupNode, sDuplicatePrevious, "");
				iDuplicateAuthorCount++;				
			}
		}
		return iDuplicateAuthorCount;
	}

	// For debugging
	private void showAlert(DocumentView docView, String msg) {
		if (m_showAlerts) {
			Alert.showError(docView.getPanel(), msg);
		}
	}
}
