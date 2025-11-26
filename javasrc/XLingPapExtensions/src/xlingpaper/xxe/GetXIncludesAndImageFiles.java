package xlingpaper.xxe;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.xpath.EvalException;
import com.xmlmind.xml.xpath.ParseException;
import com.xmlmind.xml.xpath.XPathUtil;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.MarkManager;

public class GetXIncludesAndImageFiles extends RecordableCommand {
    boolean m_showAlerts = false; // used for debugging
    final int kMaxFiles = 10000;
    final String sHref = "href=\"";
    final String sSrc = "src=\"";
    final String sHyphenationExceptionsFile = "hyphenationExceptionsFile=\"";
    boolean fLanguagesInIncludedFile = false;
    String[] asFileNames = new String[kMaxFiles];

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
	try {
	    int iCount = 0;

	    showAlert(docView, "parameter = " + parameter);
	    String[] files = parameter.split("\\|");
	    String sDocument = files[0];
	    final String sDocumentPath = files[1];
	    showAlert(docView, "sDocument = " + sDocument);
	    showAlert(docView, "sDocumentPath = " + sDocumentPath);

	    iCount = findAnyIncludedFiles(iCount, sDocument, sDocumentPath, docView);

	    iCount = findAnyImageFiles(docView, iCount, sDocumentPath);
	    // showAlert(docView, "Final iCount = " + iCount);

	    iCount = findAnyLinkedSoundFiles(docView, iCount, sDocumentPath);
	    
	    iCount = findAnyHyphenationExceptionFiles(docView, iCount, sDocumentPath);

	    if (iCount > 0) {
		StringBuilder sb = new StringBuilder();
		List<String> lsFoundFileNames = new ArrayList<String>();
		for (int i = 0; i < iCount; i++) {
		    // showAlert(docView, "sFileName = " + asFileNames[i]);
		    if (!lsFoundFileNames.contains(asFileNames[i]))
			lsFoundFileNames.add(asFileNames[i]);
		}
		Collections.sort(lsFoundFileNames);
		for (String filename : lsFoundFileNames) {
		    sb.append(filename);
		    sb.append("|");
		}
		showAlert(docView, "Returning: " + sb.toString());
		return sb.toString(); // asFoundFileNames;
	    } else {
		return null;
	    }

	} catch (Exception e) {
	    Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
	    return e.getMessage();
	}
    }

    private int findAnyIncludedFiles(int iCount, String sIncludedFilePath, String sDocumentPath,
	    DocumentView docView) throws FileNotFoundException, IOException {
	// A File object to represent the filename
	File f = new File(sIncludedFilePath.trim());

	// Make sure the file or directory exists and isn't write protected
	if (!f.exists()) {
	    // Alert.showError(docView.getPanel(),
	    // "doExecute: FileNotThere");
	    asFileNames[iCount++] = setMessage("FileNotThere");
	    return iCount;
	}
	// If it is a directory, make sure it is empty
	if (f.isDirectory()) {
	    // Alert.showError(docView.getPanel(),
	    // "doExecute: FileIsADirectory");
	    asFileNames[iCount++] = setMessage("FileIsADirectory");
	    return iCount;
	}

	BufferedReader br = new BufferedReader(new FileReader(sIncludedFilePath));
	try {
	    String line = br.readLine();
	    while (line != null) {
		if (line.contains("<xi:include")) {
		    if (line.contains(sHref)) {
			iCount = getFileName(iCount, line, sHref, sDocumentPath, docView);
			// look for any embedded files
			iCount = findAnyIncludedFiles(iCount, asFileNames[iCount - 1],
				sDocumentPath, docView);
		    } else {
			line = br.readLine();
			if (line != null && line.contains(sHref)) {
			    iCount = getFileName(iCount, line, sHref, sDocumentPath, docView);
			    // look for any embedded files
			    String sNewFile = asFileNames[iCount - 1];
			    String sNewDocumentPath = sNewFile.substring(0,
				    sNewFile.lastIndexOf(File.separator));
			    showAlert(docView, "Before checking for embedded file: sNewFile = '"
				    + sNewFile + "'");
			    showAlert(docView,
				    "Before checking for embedded file: sNewDocumentPath = '"
					    + sNewDocumentPath + "'");
			    iCount = findAnyIncludedFiles(iCount, sNewFile, sNewDocumentPath,
				    docView);
			}
		    }
		}
		if (line.contains("<img")) {
		    if (line.contains(sSrc)) {
			iCount = getFileName(iCount, line, sSrc, sDocumentPath, docView);
			iCount = handleSVGFile(iCount, sDocumentPath, asFileNames[iCount - 1]);
		    } else {
			while (!line.contains("</img")) {
				line = br.readLine();
				if (line != null && line.contains(sSrc)) {
				    iCount = getFileName(iCount, line, sSrc, sDocumentPath, docView);
				    iCount = handleSVGFile(iCount, sDocumentPath, asFileNames[iCount - 1]);
				}
			}
		    }
		}
		if (line.contains("<language") && !line.contains("<languages")) {
			fLanguagesInIncludedFile = true;
		    if (line.contains(sHyphenationExceptionsFile)) {
			iCount = getFileName(iCount, line, sHyphenationExceptionsFile,
				sDocumentPath, docView);
		    } else {
			line = br.readLine();
			while (line != null && !line.contains("</language")) {
				if (line != null && line.contains(sHyphenationExceptionsFile)) {
				    iCount = getFileName(iCount, line, sHyphenationExceptionsFile,
					    sDocumentPath, docView);
				}
				line = br.readLine();
			}
		    }
		}
		line = br.readLine();
	    }
	} finally {
	    br.close();
	}
	return iCount;
    }

    private int getFileName(int iCount, String line, String sFileRefAttribute,
	    String sDocumentPath, DocumentView docView) {
	 showAlert(docView, "line = '" + line + "'");
	int iBegin = line.indexOf(sFileRefAttribute) + sFileRefAttribute.length();
	int iEnd = line.substring(iBegin).indexOf('"') + sFileRefAttribute.length();
	 showAlert(docView, "iBegin = " + iBegin + " and iEnd = " + iEnd);
	String sFilePath = line.substring(iBegin, iEnd);
	 showAlert(docView, "sFilePath = '" + sFilePath + "'");
	asFileNames[iCount++] = sDocumentPath + File.separator
		+ fixupImageFile(sDocumentPath, sFilePath);
	 showAlert(docView, "asFileNames[iCount] = '" + asFileNames[iCount-1] + "'");
	return iCount;
    }

    private int findAnyImageFiles(DocumentView docView, int iCount, String sDocumentPath)
	    throws ParseException, EvalException {
	Document doc = docView.getDocument();
	String sXpath = "//img | //mediaObject";
	XNode[] results = XPathUtil.evalAsNodeSet(sXpath, doc);
	if (results == null) {
	    return 0;
	}

	showAlert(docView, "Before check for missing images");
	for (XNode node : results) {
	    String imageFile = node.attributeValue(Name.get("src"));
	    iCount = processImageFile(iCount, sDocumentPath, imageFile);
	}
	return iCount;
    }

	private String fixupImageFile(String sDocumentPath, String imageFile) {
		String operatingSystem = System.getProperty("os.name");
		if (operatingSystem.contains("Windows")) {
			// need to change any '/' to '\' in file name
			imageFile = imageFile.replace("/", "\\");
		}
		/*
		 * if (imageFile.startsWith("..")) { imageFile = sDocumentPath +
		 * System.getProperty("file.separator") + imageFile; }
		 */
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
		return imageFile;
	}

	private int processImageFile(int iCount, String sDocumentPath, String imageFile) {
		imageFile = fixupImageFile(sDocumentPath, imageFile);
		// showAlert(docView, "image file before checking File: " +
		// imageFile);
		asFileNames[iCount++] = sDocumentPath + File.separator + imageFile;
		iCount = handleSVGFile(iCount, sDocumentPath, imageFile);
		return iCount;
	}

    private int handleSVGFile(int iCount, String sDocumentPath, String imageFile) {
	if (imageFile.endsWith(".svg")) {
	    String pdfVersion = sDocumentPath + File.separator
		    + imageFile.substring(0, imageFile.length() - 4) + ".pdf";
	    // showAlert(docView, "image file as pdf version:" +
	    // pdfVersion);
	    File f = new File(pdfVersion);
	    if (f.exists()) {
		asFileNames[iCount++] = pdfVersion;
		// showAlert(docView, "added pdf version");
	    }
	}
	return iCount;
    }

    private int findAnyLinkedSoundFiles(DocumentView docView, int iCount, String sDocumentPath)
	    throws ParseException, EvalException {
	Document doc = docView.getDocument();
	String sXpath = "//link";
	XNode[] results = XPathUtil.evalAsNodeSet(sXpath, doc);
	if (results == null) {
	    return 0;
	}

	showAlert(docView, "Before check for linked sound files");
	for (XNode node : results) {
	    String linkedHref = node.attributeValue(Name.get("href"));
	    if (linkedHref.startsWith("http")) {
		continue;  // skip these
	    }
	    int iLen = linkedHref.length();
	    String suffix = linkedHref.substring(iLen - 4, iLen).toLowerCase();
	    if (suffix.endsWith(".mp3") || suffix.endsWith("mp4") || suffix.endsWith("wav") || suffix.endsWith("swf")) {
		iCount = processImageFile(iCount, sDocumentPath, linkedHref);
	    }
	}
	return iCount;
    }

    private int findAnyHyphenationExceptionFiles(DocumentView docView, int iCount,
	    String sDocumentPath) throws ParseException, EvalException {
    	if (fLanguagesInIncludedFile) {
    		// Already looked for them
    		return iCount;
    	}
	Document doc = docView.getDocument();
	String sXpath = "//language/@hyphenationExceptionsFile";
	XNode[] results = XPathUtil.evalAsNodeSet(sXpath, doc);
	if (results == null) {
	    return 0;
	}

	showAlert(docView, "Before check for hyphenation exceptions files");
	for (XNode node : results) {
	    String hyphenationExceptionsFile = node.data();
	    // showAlert(docView, "image file before os check:" + imageFile);
	    hyphenationExceptionsFile = fixupImageFile(sDocumentPath, hyphenationExceptionsFile);
	    // showAlert(docView, "image file before checking File: " +
	    // imageFile);
	    asFileNames[iCount++] = sDocumentPath + File.separator + hyphenationExceptionsFile;
	}
	return iCount;
    }

    // For debugging
    private void showAlert(DocumentView docView, String msg) {
	if (m_showAlerts) {
	    Alert.showError(docView.getPanel(), msg);
	}
    }

    private String setMessage(String message) {
	return "XLingPaper-" + message + "-XLingPaper";
    }
}
