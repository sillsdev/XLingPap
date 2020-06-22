package xlingpaper.xxe;

import java.awt.GraphicsEnvironment;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Arrays;

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

public class CheckPresenceOfFontsAndImages extends RecordableCommand {
    boolean m_showAlerts = false; // used for debugging

    public boolean prepare(DocumentView docView, String parameter, int x, int y) {
	// Alert.showError(docView.getPanel(),
	// "In CheckPresenceOfFontsAndImages prepare");
	// Alert.showError(docView.getPanel(), "prepare: parameter = |" +
	// parameter + "|");
	MarkManager markManager = docView.getMarkManager();
	if (markManager == null) {
	    // Alert.showError(docView.getPanel(),
	    // "prepare: markManager is null");
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

	    int iMissingImageCount = findAnyMissingImages(docView, validationErrors, sDocumentPath,
		    ls);
	    int iMissingFontCount = findAnyMissingFonts(docView, validationErrors, ls);
	    if (iMissingFontCount > 0 || iMissingImageCount > 0) {
		showMissingItemsDialog(docView, validationErrors, ls);
		return "hadMissingFontsOrImages";
	    }

	} catch (Exception e) {
	    Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
	    return e.getMessage();
	}
	return "allClear";
    }

    private void showMissingItemsDialog(DocumentView docView, ValidationErrors validationErrors,
	    LocalizeString ls) {
	String sDialogTitle = (String) ls.doExecute(docView, "java.fontImageDialaogTitle", 0, 0);
	CheckValidityDialog validityDialog = new CheckValidityDialog(docView.getPanel(),
		sDialogTitle);
	// "Missing Fonts and/or Image Files"
	validityDialog.setModal(false);
	validityDialog.setLocationRelativeTo(null);
	validityDialog.showDiagnostics(validationErrors.toArray(), docView, 1);
    }

	private int findAnyMissingImages(DocumentView docView, ValidationErrors validationErrors,
			String sDocumentPath, LocalizeString ls) throws ParseException, EvalException,
			IOException {
		Document doc = docView.getDocument();
		String sXpath = "//img";
		XNode[] results = XPathUtil.evalAsNodeSet(sXpath, doc);
		if (results == null) {
			return 0;
		}

		int iMissingImageCount = 0;
		showAlert(docView, "Before check for missing images");
		for (XNode node : results) {
			String imageFile = node.attributeValue(Name.get("src"));
			String originalImageFile = imageFile;
			showAlert(docView, "image file before os check:" + imageFile);
			imageFile = XLingPaperUtils.fixupImageFile(sDocumentPath, imageFile);
			showAlert(docView, "imgage file before checking File: " + imageFile);
			File f = new File(imageFile.trim());

			// Make sure the file or directory exists and isn't write
			// protected
			if (!f.exists()) {
				// try prepending the document path
				String sFileNameTry2 = sDocumentPath + System.getProperty("file.separator")
						+ imageFile.trim();
				f = new File(sFileNameTry2);
				if (!f.exists()) {
					// image file is missing
					String sMissingImageFile1 = (String) ls.doExecute(docView,
							"java.fontImageDialogMissingImageFile1", 0, 0);
					String sMissingImageFile2 = (String) ls.doExecute(docView,
							"java.fontImageDialogMissingImageFile2", 0, 0);
					validationErrors.append((Element) node, sMissingImageFile1,
							String.format(sMissingImageFile2, originalImageFile));
					// "Image file not found on this computer.  Click on the number to the left to see the img element and fix its src attribute.",
					// "Could not find image file: " + originalImageFile);
					iMissingImageCount++;
				}
				if (sFileNameTry2.toLowerCase().endsWith(".svg")) {
					int iName = sFileNameTry2.length() - 4;
					String imageFilePDF = sFileNameTry2.substring(0, iName) + ".pdf";
					// Alert.showError(docView.getPanel(),
					// "Looking for this pdf file: " + imageFilePDF);
					File fPDF = new File(imageFilePDF);
					if (!fPDF.exists()) {
						// No .pdf equivalent of the .svg file
						String sMissingImageFileSvgNeedsPdf1 = (String) ls.doExecute(docView,
								"java.fontImageDialogMissingImageFileSvgNeedsPdf1", 0, 0);
						String sMissingImageFileSvgNeedsPdf2 = (String) ls.doExecute(docView,
								"java.fontImageDialogMissingImageFileSvgNeedsPdf2", 0, 0);
						validationErrors.append((Element) node, sMissingImageFileSvgNeedsPdf1,
								String.format(sMissingImageFileSvgNeedsPdf2, imageFile));
						// "The image file's extension indicates it is an SVG file.  XeLaTeX cannot format an SVG file, but it is possible to convert the SVG file to a PDF file and then XeLaTex will be able to format it.  See section 11.17.1.1 'Known limitations of using XeTeX' of the user documentation for how to convert the SVG file to PDF.",
						// "An SVG file needs to be converted to PDF format: " +
						// imageFile);
						iMissingImageCount++;
					} else if (!fPDF.exists() || fPDF.lastModified() < f.lastModified()) {
						// there is a .pdf equivalent of the .svg file, but it
						// is
						// older than the .svg file
						String sSvgNeedsNewerPdf1 = (String) ls.doExecute(docView,
								"java.fontImageDialogSvgNeedsNewerPdf1", 0, 0);
						String sSvgNeedsNewerPdf2 = (String) ls.doExecute(docView,
								"java.fontImageDialogSvgNeedsNewerPdf2", 0, 0);
						validationErrors.append((Element) node, sSvgNeedsNewerPdf1,
								String.format(sSvgNeedsNewerPdf2, imageFile));
						// "The image file's extension indicates it is an SVG file and there is an equivalent PDF version of the file.  The PDF file, however, is older than the SVG file.  Please convert the SVG to PDF again so it is up-to-date.  See section 11.17.1.1 'Known limitations of using XeTeX' of the user documentation for how to convert the SVG file to PDF.",
						// "An SVG file needs to be converted again to PDF format: "
						// + imageFile);
						iMissingImageCount++;
					}
				}
				if (sFileNameTry2.toLowerCase().endsWith(".pdf")) {
					BufferedReader br = new BufferedReader(new FileReader(sFileNameTry2));
					String line = br.readLine();
					br.close();
					if (line.contains("%PDF-") && line.length() >= 8) {
						String sVersion = line.substring(5);
						int iVersion = Integer.parseInt(sVersion.substring(2));
						if (!sVersion.subSequence(0, 2).equals("1.") || iVersion > 5) {
							String sBadPdfVersion1 = (String) ls.doExecute(docView,
									"java.fontImageDialogBadPdfVersion1", 0, 0);
							String sBadPdfVersion2 = (String) ls.doExecute(docView,
									"java.fontImageDialogBadPdfVersion2", 0, 0);
							validationErrors.append((Element) node,
									String.format(sBadPdfVersion1, sVersion),
									String.format(sBadPdfVersion2, imageFile));
							// "The image file's extension indicates it is a PDF file.  XeLaTeX cannot format a PDF file whose version is greater than 1.5, but this file's version is "
							// + sVersion +
							// "which is newer than 1.5.  See section 11.17.1.1 'Known limitations of using XeTeX' item 15 of the user documentation for how to convert the PDF file to an older version.",
							// "This PDF file needs to be converted to PDF version 1.5: "
							// +
							// imageFile);
							iMissingImageCount++;
						}
					}
				}
			}
			if (imageFile.contains("%") || imageFile.contains("$") || imageFile.contains("~")) {
				// image file has bad file name
				String sBadFileName1 = (String) ls.doExecute(docView,
						"java.fontImageDialogBadFileName1", 0, 0);
				String sBadFileName2 = (String) ls.doExecute(docView,
						"java.fontImageDialogBadFileName2", 0, 0);
				validationErrors.append((Element) node, sBadFileName1,
						String.format(sBadFileName2, imageFile));
				// "Image file name contains one or more %, $ or ~ characters.  Sorry, but you'll need to change the file name to not use any of these characters.  Click on the number to the left to see the img element and fix its src attribute.",
				// "File name contains characters that will not work: " +
				// imageFile);
				iMissingImageCount++;
			}
			if (imageFile.endsWith(".tiff") || imageFile.endsWith(".tif")) {
				// TIFF files cause XeLaTeX to fail
				String sTiffFileBad1 = (String) ls.doExecute(docView,
						"java.fontImageDialogTIFFFormat1", 0, 0);
				String sTiffFileBad2 = (String) ls.doExecute(docView,
						"java.fontImageDialogTIFFFormat2", 0, 0);
				validationErrors.append((Element) node, sTiffFileBad1,
						String.format(sTiffFileBad2, imageFile));
				// "We're sorry, but this graphic file is in TIFF format and this processor cannot handle TIFF format.  You will need to convert the file to a different format.  We suggest using PNG format or JPG format.  Also see section 11.17.1.1 in the XLingPaper user documentation.  Click on the number to the left to see the img element and fix its src attribute.",
				// "File format TIFF will fail to produce PDF: " + imageFile);
				iMissingImageCount++;
			}
		}
		return iMissingImageCount;
	}

    private String fixupImageFile(DocumentView docView, String sDocumentPath, String imageFile) {
	String operatingSystem = System.getProperty("os.name");
	if (operatingSystem.contains("Windows")) {
	    // need to change any '/' to '\' in file name
	    imageFile = imageFile.replace("/", "\\");
	}
	showAlert(docView, "image file after os check:" + imageFile);
	if (imageFile.startsWith("..") || imageFile.startsWith("./") || imageFile.startsWith(".\\")) {
	    imageFile = sDocumentPath + System.getProperty("file.separator") + imageFile;
	}
	showAlert(docView, "imgage file after relative path check: " + imageFile);
	if (imageFile.startsWith("file:\\\\\\")) {
	    imageFile = imageFile.substring(8);
	}
	imageFile = imageFile.replace("%20", " ");
	imageFile = imageFile.replace("%23", "#");
	imageFile = imageFile.replace("%25", "%");
	imageFile = imageFile.replace("%27", "'");
	imageFile = imageFile.replace("%7E", "~");
	imageFile = imageFile.replace("%5B", "[");
	imageFile = imageFile.replace("%5D", "]");
	imageFile = imageFile.replace("%5E", "^");
	imageFile = imageFile.replace("%7B", "{");
	imageFile = imageFile.replace("%7D", "}");
	imageFile = imageFile.replace("%7E", "~");
	return imageFile;
    }

    private int findAnyMissingFonts(DocumentView docView, ValidationErrors validationErrors,
	    LocalizeString ls) throws ParseException, EvalException {
	Document doc = docView.getDocument();
	GraphicsEnvironment env = GraphicsEnvironment.getLocalGraphicsEnvironment();
	String[] installedFontFamilyNames = env.getAvailableFontFamilyNames();
	if (installedFontFamilyNames == null) {
	    return 0;
	}
	int iMissingFontCount = 0;
	String fontName;
	Arrays.sort(installedFontFamilyNames);
	String sXpath = "//*[string-length(normalize-space(@font-family)) > 0] |"
		+ "//defaultFontFamily[string-length(normalize-space(.)) > 0]";
	XNode[] results = XPathUtil.evalAsNodeSet(sXpath, doc);
	if (results == null) {
	    iMissingFontCount = checkForMediaObjectFont(docView, validationErrors, ls, doc,
			installedFontFamilyNames, iMissingFontCount);
	    return iMissingFontCount;
	}
	for (XNode node : results) {
	    Element element = (Element) node;
	    fontName = node.attributeValue(Name.get("font-family"));
	    if (fontName == null) {
		fontName = element.getText();
		if (fontName == null) {
		    continue; // not sure what happened, but let's keep going
		}
	    }
	    showAlert(docView, "Before binary search: fontName = " + fontName + "; element "
		    + element.name().localPart);
	    if ("fixedsys".equalsIgnoreCase(fontName)) {
		// a special case
		String sFixedSysFont = (String) ls.doExecute(docView,
			"java.fontImageDialogFixedSysFont", 0, 0);
		iMissingFontCount = recordMissingFont(docView, validationErrors, iMissingFontCount,
			element, fontName, sFixedSysFont, ls);
		// "  Also, see http://fixedsys.moviecorner.de/?p=download&amp;l=1 for an alternative font that will work.");
	    } else {
		iMissingFontCount = seeIfFontIsMissing(docView, validationErrors, ls,
			installedFontFamilyNames, iMissingFontCount, fontName, element);

	    }
	}

	iMissingFontCount = checkForMediaObjectFont(docView, validationErrors, ls, doc,
		installedFontFamilyNames, iMissingFontCount);
	return iMissingFontCount;
    }

    private int checkForMediaObjectFont(DocumentView docView, ValidationErrors validationErrors,
	    LocalizeString ls, Document doc, String[] installedFontFamilyNames,
	    int iMissingFontCount) throws ParseException, EvalException {
	String fontName;
	//Alert.showError(docView.getPanel(), "Before mediaObject check: iMissingFontCount=" + iMissingFontCount);
	XNode[] results = XPathUtil.evalAsNodeSet("//mediaObject", doc);
	//Alert.showError(docView.getPanel(), "After mediaObject check");
	if (results != null && results.length > 0) {
	    //Alert.showError(docView.getPanel(), "results not null");
	    Element element = (Element) results[0];
	    fontName = "Symbola";
	    iMissingFontCount = seeIfFontIsMissing(docView, validationErrors, ls,
		    installedFontFamilyNames, iMissingFontCount, fontName, element);
	}
	//Alert.showError(docView.getPanel(), "Returning: iMissingFontCount=" + iMissingFontCount);
	return iMissingFontCount;
    }

    private int seeIfFontIsMissing(DocumentView docView, ValidationErrors validationErrors,
	    LocalizeString ls, String[] installedFontFamilyNames, int iMissingFontCount,
	    String fontName, Element element) {
	if (0 > Arrays.binarySearch(installedFontFamilyNames, fontName)) {
	    // font is missing
	    iMissingFontCount = recordMissingFont(docView, validationErrors, iMissingFontCount,
		    element, fontName, ls);
	}
	return iMissingFontCount;
    }

    private int recordMissingFont(DocumentView docView, ValidationErrors validationErrors,
	    int iMissingFontCount, Element element, String fontName, LocalizeString ls) {
	return recordMissingFont(docView, validationErrors, iMissingFontCount, element, fontName,
		null, ls);
    }

    private int recordMissingFont(DocumentView docView, ValidationErrors validationErrors,
	    int iMissingFontCount, Element element, String fontName, String extraMessage,
	    LocalizeString ls) {
	showAlert(docView, "Before appending a validation error, fontName = " + fontName);
	StringBuffer sConstraint = new StringBuffer();
	String sMissingFont1 = (String) ls.doExecute(docView, "java.fontImageDialogMissingFont1",
		0, 0);
	String sMissingFont2 = (String) ls.doExecute(docView, "java.fontImageDialogMissingFont2",
		0, 0);
	sConstraint.append(String.format(sMissingFont1, element.name().localPart));
	// .append("Font not found on this computer. Click on the number to the left to see the ");
	// sConstraint.append(element.name().localPart);
	// sConstraint.append(" element and fix its font-family attribute.");
	if (extraMessage != null) {
	    sConstraint.append(extraMessage);
	}
	validationErrors.append(element, sConstraint.toString(),
		String.format(sMissingFont2, fontName));
	// "Missing font-family: " + fontName);
	iMissingFontCount++;
	return iMissingFontCount;
    }

    // For debugging
    private void showAlert(DocumentView docView, String msg) {
	if (m_showAlerts) {
	    Alert.showError(docView.getPanel(), msg);
	}
    }
}
