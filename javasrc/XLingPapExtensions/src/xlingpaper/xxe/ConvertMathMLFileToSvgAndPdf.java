package xlingpaper.xxe;

import java.io.File;
import java.io.IOException;

import org.apache.batik.apps.rasterizer.SVGConverter;
import org.apache.batik.apps.rasterizer.SVGConverterException;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.imagetoolkit.ImageConverter;
import com.xmlmind.xmleditext.jeuclid_imagetoolkit.JEuclidImageToolkit;

public class ConvertMathMLFileToSvgAndPdf extends RecordableCommand {
	boolean m_showAlerts = false; // used for debugging
	static final String kFailure = "";
	ConvertSvgFileToPdf svgConverter;
	
	public boolean prepare(DocumentView docView, String parameter, int x, int y) {
		MarkManager markManager = docView.getMarkManager();
		if (markManager == null) {
			return false;
		}
		return true;
	}

	protected Object doExecute(DocumentView docView, String parameter, int x, int y) {
		try {
			ElementEditor elementEditor = docView.getElementEditor();
			Element editedElement = elementEditor.getEditedElement();
			if (editedElement == null) {
				return kFailure;
			}
			String sDocumentPath = parameter;
			String imageFileMML = editedElement.attributeValue(Name.get("src"));
			imageFileMML = XLingPaperUtils.fixupImageFile(sDocumentPath, imageFileMML);
			if (imageFileMML == null) {
				return kFailure;
			}
			if (!imageFileMML.toLowerCase().endsWith(".mml")) {
				return kFailure;
			}
			svgConverter = new ConvertSvgFileToPdf();
			svgConverter.prepare(docView, parameter, x, y);
			File fMML = new File(imageFileMML.trim());
			if (!fMML.exists()) {
				// try prepending the document path
				String sFileNameTry2 = sDocumentPath + System.getProperty("file.separator")
						+ imageFileMML.trim();
				fMML = new File(sFileNameTry2);
				showAlert(docView, "image file with document path:" + sFileNameTry2);
				if (!fMML.exists()) {
					return kFailure;
				}
				imageFileMML = sFileNameTry2;
			}
			String imageFileSVG = convertMmlToSvgAndPdf(docView, imageFileMML, fMML);
			if (!imageFileSVG.equals(kFailure))
				svgConverter.doExecute(docView, imageFileSVG, x, y);
			return imageFileSVG;
		} catch (Exception e) {
			e.printStackTrace();
			Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
			return e.getMessage();
		}
	}

	public String convertMmlToSvgAndPdf(DocumentView docView, String imageFileMML, File fMML)
			throws Exception {
		showAlert(docView, "image file exists:" + imageFileMML);
		JEuclidImageToolkit jeKit = new JEuclidImageToolkit();
		showAlert(docView, "Created toolkit");
		String imageFileSVG = imageFileMML.substring(0, imageFileMML.length()-4) + ".svg";
		showAlert(docView, "image svg file:" + imageFileSVG);
		// Alert.showError(docView.getPanel(),
		// "Looking for this pdf file: " + imageFilePDF);
		File fSVG = new File(imageFileSVG);
		ImageConverter converter = jeKit.getImageConverter(fMML, fSVG);
		showAlert(docView, "Got converter");
		if (converter != null) {
			jeKit.getImageConverter(fMML, fSVG).convertImage(fMML, fSVG, null, null);
			showAlert(docView, "Converted");
			convertSvgToPDF(docView, fSVG);
			return imageFileSVG;
		}
		else {
			showAlert(docView, "not Converted");
			return kFailure;
		}
	}

	private void convertSvgToPDF(DocumentView docView, File fSVG) {
	    SVGConverter myConv = new SVGConverter();
	    myConv.setDestinationType(org.apache.batik.apps.rasterizer.DestinationType.PDF);
	    try {
	        myConv.setSources(new String[]{fSVG.getCanonicalPath()});

	    } catch (IOException iOException) {
	    	iOException.printStackTrace();
			Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + iOException.getMessage());
			return;
	    }

	    try {
	        myConv.execute();

	    } catch (SVGConverterException sVGConverterException) {
	    	sVGConverterException.printStackTrace();
			Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + sVGConverterException.getMessage());
			return;
	    }
	}
	
	// For debugging
	private void showAlert(DocumentView docView, String msg) {
		if (m_showAlerts) {
			Alert.showError(docView.getPanel(), msg);
		}
	}
}
