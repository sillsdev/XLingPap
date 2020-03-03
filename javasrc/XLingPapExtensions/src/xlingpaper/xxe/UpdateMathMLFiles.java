package xlingpaper.xxe;

import java.io.File;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.xpath.EvalException;
import com.xmlmind.xml.xpath.ParseException;
import com.xmlmind.xml.xpath.XPathUtil;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.MarkManager;

public class UpdateMathMLFiles extends RecordableCommand {
	boolean m_showAlerts = false; // used for debugging
	ConvertMathMLFileToSvgAndPdf convertMmlToSvgAndPdf;

	public boolean prepare(DocumentView docView, String parameter, int x, int y) {
		MarkManager markManager = docView.getMarkManager();
		if (markManager == null) {
			return false;
		}

		return true;
	}

	protected Object doExecute(DocumentView docView, String parameter, int x, int y) {
		try {
			String sDocumentPath = parameter;
			LocalizeString ls = new LocalizeString();
			ls.prepare(docView, null, x, y);

			convertMmlToSvgAndPdf = new ConvertMathMLFileToSvgAndPdf();
			convertMmlToSvgAndPdf.prepare(docView, parameter, x, y);

			findAndUpdateMmlFiles(docView, sDocumentPath);
			return null;
		} catch (Exception e) {
			Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
			return e.getMessage();
		}
	}

	private void findAndUpdateMmlFiles(DocumentView docView, String sDocumentPath)
			throws Exception {
		Document doc = docView.getDocument();
		String sXpath = "//img[contains(@src,'.mml')]";
		XNode[] results = XPathUtil.evalAsNodeSet(sXpath, doc);
		if (results == null) {
			return;
		}
		for (XNode node : results) {
			String imageFileMML = node.attributeValue(Name.get("src"));
			if (!imageFileMML.endsWith(".mml"))
				continue;
			imageFileMML = XLingPaperUtils.fixupImageFile(sDocumentPath, imageFileMML);
			showAlert(docView, "imgage file before checking File: " + imageFileMML);
			File fMML = new File(imageFileMML.trim());
			if (!fMML.exists()) {
				// try prepending the document path
				imageFileMML = sDocumentPath + System.getProperty("file.separator") + imageFileMML.trim();
				fMML = new File(imageFileMML);
				if (!fMML.exists()) {
					// image file is missing
					continue;
				}
			}
			int iName = imageFileMML.length() - 4;
			String imageFileSVG = imageFileMML.substring(0, iName) + ".svg";
			File fSVG = new File(imageFileSVG);
			if (!fSVG.exists() || fSVG.lastModified() < fMML.lastModified()) {
				// need to create or update .svg and .pdf versions
				convertMmlToSvgAndPdf.convertMmlToSvgAndPdf(docView, imageFileMML, fMML);
			}
		}
	}

	// For debugging
	private void showAlert(DocumentView docView, String msg) {
		if (m_showAlerts) {
			Alert.showError(docView.getPanel(), msg);
		}
	}
}
