package xlingpaper.xxe;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.MarkManager;

public class SavePublisherStyleSheetToNewLocation extends RecordableCommand {
    boolean m_showAlerts = false; // used for debugging
    final String sHref = "href=\"";
    String sIncludedFile = "";
    String sOriginalMainDirectory = "";
    
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
			String sPath = docView.getDocument().getSourceURL().getFile();
			int i = sPath.lastIndexOf('/');
			final String sNewDocumentName = sPath.substring(i+1);
			final String sNewDirectoryURL = "file://" + sPath.substring(0,i);
			URL url = new URL(sNewDirectoryURL);
			String sNewDirectory = url.toURI().getPath().substring(1).replace("/", File.separator);
			showAlert(docView, "sNewDocumentName = " + sNewDocumentName);
			showAlert(docView, "sNewDirectory = " + sNewDirectory);

			processAnyIncludedFiles(sNewDocumentName, sNewDirectory, docView);
			return null;
		} catch (Exception e) {
			Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
			return e.getMessage();
		}
	}

	private void processAnyIncludedFiles(String sNewDocumentName, String sNewDirectory,
			DocumentView docView) throws FileNotFoundException, IOException, URISyntaxException {
		final String sTempFileExtension = ".tmp";
		// A File object to represent the filename
		String sNewName = sNewDirectory + File.separator + sNewDocumentName;
		showAlert(docView, "file name trying: '" + sNewName + "'");
		File f = new File(sNewName);
		
		// Make sure the file or directory exists and isn't write protected
		if (!f.exists()) {
			Alert.showError(docView.getPanel(), "doExecute: FileNotThere: '" + sNewName + "'");
			return;
		}
		// If it is a directory, make sure it is empty
		if (f.isDirectory()) {
			Alert.showError(docView.getPanel(), "doExecute: FileIsADirectory");
			return;
		}

		BufferedReader br = new BufferedReader(new FileReader(sNewName));
		BufferedWriter bw = new BufferedWriter(new FileWriter(sNewName + sTempFileExtension));
		try {
			String line = br.readLine();
			while (line != null) {
				String newLine = line;
				if (line.contains("<xi:include")) {
					if (line.contains(sHref)) {
						newLine = copyIncludedFileToNewDirectory(line, sNewDirectory, docView);
						// look for any embedded files
						processAnyIncludedFiles(sIncludedFile, sNewDirectory, docView);
					} else {
						bw.write(newLine);
						bw.write("\n");
						line = br.readLine();
						newLine = line;
						if (line != null && line.contains(sHref)) {
							newLine = copyIncludedFileToNewDirectory(line, sNewDirectory, docView);
							// look for any embedded files
							processAnyIncludedFiles(sIncludedFile, sNewDirectory, docView);
						}
					}
				}
				bw.write(newLine);
				bw.write("\n");
				line = br.readLine();
			}
		} finally {
			br.close();
			bw.close();
			Path source = Paths.get(sNewName + sTempFileExtension);
			Path target = Paths.get(sNewName);
			showAlert(docView, "All done processing; copying file: source ='" + source + "' and target='" + target);
			Files.copy(source, target, StandardCopyOption.REPLACE_EXISTING);
			Files.delete(source);
		}
	}

	private String copyIncludedFileToNewDirectory(String line, String sNewDirectory, DocumentView docView) throws IOException {
		showAlert(docView, "line = '" + line + "'");
		int iBegin = line.indexOf(sHref) + sHref.length();
		int iEnd = line.substring(iBegin).indexOf('"') + sHref.length();
		showAlert(docView, "iBegin = " + iBegin + " and iEnd = " + iEnd);
		sIncludedFile = line.substring(iBegin, iEnd).replace("/", File.separator);
		showAlert(docView, "sIncludedFile = '" + sIncludedFile + "'");
		
		String sNewFile = sIncludedFile;
		int i = sNewFile.lastIndexOf(File.separator);
		if (i > -1) {
			sNewFile = sIncludedFile.substring(i + 1);
			if (sOriginalMainDirectory.length() == 0) {
				sOriginalMainDirectory = sIncludedFile.substring(0, i);
				showAlert(docView, "sOriginalMainDirectory = '" + sOriginalMainDirectory + "'");
			}
		}
		showAlert(docView, "sNewFile = '" + sNewFile + "'");
		String adjustedLine = line.substring(0,iBegin-1) + "\"" + sNewFile + line.substring(iEnd);
		showAlert(docView, "line result = '" + adjustedLine + "'");

		Path source = null;
		if (sOriginalMainDirectory.length() == 0) {
			source = Paths.get(sNewDirectory + File.separator + sIncludedFile);
			showAlert(docView, "original not set: source ='" + source);
		} else {
			source = Paths.get(sNewDirectory + File.separator + sOriginalMainDirectory + File.separator + sNewFile);
			showAlert(docView, "original set: source ='" + source);
		}
		Path target = Paths.get(sNewDirectory + File.separator + sNewFile);
		showAlert(docView, "Copying file: source ='" + source + "' and target='" + target);
		Files.copy(source, target, StandardCopyOption.REPLACE_EXISTING);
		return adjustedLine;
	}

	// For debugging
	private void showAlert(DocumentView docView, String msg) {
		if (m_showAlerts) {
			Alert.showError(docView.getPanel(), msg);
		}
	}

}
