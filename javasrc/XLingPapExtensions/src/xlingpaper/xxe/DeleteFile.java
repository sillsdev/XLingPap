package xlingpaper.xxe;

import java.io.File;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xmledit.view.DocumentView;

import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.MarkManager;

public class DeleteFile extends RecordableCommand {
	public boolean prepare(DocumentView docView, String parameter, int x, int y) {
		//Alert.showError(docView.getPanel(), "In DeleteFile prepare");
		//Alert.showError(docView.getPanel(), "prepare: parameter = |" + parameter + "|");
		MarkManager markManager = docView.getMarkManager();
		if (markManager == null) {
			//Alert.showError(docView.getPanel(), "prepare: markManager is null");
			return false;
		}

		// Selected element is not at issue for this command
//		Element editedElement = docView.getSelectedElement(/* implicit */true);
//		if (editedElement == null) {
//			//Alert.showError(docView.getPanel(), "prepare: returning false");
//			return false;
//		}
//		docView.getElementEditor().editElement(editedElement);
		//Alert.showError(docView.getPanel(), "prepare: returning true");
		return true;
	}

	protected Object doExecute(DocumentView docView, String parameter, int x,
			int y) {
		//Alert.showError(docView.getPanel(), "In DeleteFile doExecute");
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

			// Attempt to delete it
			boolean success = f.delete();

			if (!success) {
				//Alert.showError(docView.getPanel(), "doExecute: FileFailedToDelete");
				return setMessage("FileFailedToDelete");
			}
			else {
				//Alert.showError(docView.getPanel(), "doExecute: FileDeleted");
				return setMessage("FileNotThere");
			}
		} catch (Exception e) {
			Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
			return e.getMessage();
		}
	}

	private String setMessage(String message) {
		return "XLingPaper-" + message + "-XLingPaper";
	}
}
