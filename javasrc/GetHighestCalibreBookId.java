package xlingpaper.xxe;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.Charset;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xmledit.view.DocumentView;

import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.MarkManager;

public class GetHighestCalibreBookId extends RecordableCommand {
	public boolean prepare(DocumentView docView, String parameter, int x, int y) {
		//Alert.showError(docView.getPanel(), "In DeleteFile prepare");
		//Alert.showError(docView.getPanel(), "prepare: parameter = |" + parameter + "|");
		MarkManager markManager = docView.getMarkManager();
		if (markManager == null) {
			//Alert.showError(docView.getPanel(), "prepare: markManager is null");
			return false;
		}

		Element editedElement = docView.getSelectedElement(/* implicit */true);
		if (editedElement == null) {
			//Alert.showError(docView.getPanel(), "prepare: returning false");
			return false;
		}
		docView.getElementEditor().editElement(editedElement);
		//Alert.showError(docView.getPanel(), "prepare: returning true");
		return true;
	}

	protected Object doExecute(DocumentView docView, String parameter, int x,
			int y) {
		//Alert.showError(docView.getPanel(), "In GetHighestCalibreBookId doExecute");
		//Alert.showError(docView.getPanel(), "doExecute: parameter = |" + parameter + "|");
		try {
			// A File object to represent the filename
			File f = new File(parameter.trim());

			// Make sure the file or directory exists and isn't write protected
			if (!f.exists()) {
				//Alert.showError(docView.getPanel(), "doExecute: FileNotThere");
				return setMessage("FileNotThere");
			}
			if (!f.canWrite()) {
				//Alert.showError(docView.getPanel(), "doExecute: FileWriteProtected");
				return setMessage("FileWriteProtected");
			}
			// If it is a directory, make sure it is empty
			if (f.isDirectory()) {
				//Alert.showError(docView.getPanel(), "doExecute: FileIsADirectory");
				return setMessage("FileIsADirectory");
			}

			InputStream    fis;
			BufferedReader br;
			String         line;

			fis = new FileInputStream(f);
			br = new BufferedReader(new InputStreamReader(fis, Charset.forName("UTF-8")));
			String lastLine = null;
			String nextTolastLine = null;
			while ((line = br.readLine()) != null) {
				//Alert.showError(docView.getPanel(), "doExecute: line = |" + line + "|");
			    nextTolastLine = lastLine;
			    lastLine = line;
			}
				//Alert.showError(docView.getPanel(), "doExecute: lastLine = |" + nextTolastLine + "|");
			String[] contents = nextTolastLine.split(" ");
				//Alert.showError(docView.getPanel(), "doExecute: contents[0] = |" + contents[0] + "|");
			fis.close();
			return contents[0];
		} catch (Exception e) {
			Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
			return e.getMessage();
		}
	}

	private String setMessage(String message) {
		return "XLingPaper-" + message + "-XLingPaper";
	}
}
