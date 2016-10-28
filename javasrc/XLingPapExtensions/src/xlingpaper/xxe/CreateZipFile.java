package xlingpaper.xxe;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.zip.ZipOutputStream;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.util.Zip;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xmledit.view.DocumentView;

import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.MarkManager;

public class CreateZipFile extends RecordableCommand {
    public boolean prepare(DocumentView docView, String parameter, int x, int y) {
	// Alert.showError(docView.getPanel(), "In CreateZipFile prepare");
	// Alert.showError(docView.getPanel(), "prepare: parameter = |" +
	// parameter + "|");
	MarkManager markManager = docView.getMarkManager();
	if (markManager == null) {
	    // Alert.showError(docView.getPanel(),
	    // "prepare: markManager is null");
	    return false;
	}

	Element editedElement = docView.getSelectedElement(/* implicit */true);
	if (editedElement == null) {
	    // Alert.showError(docView.getPanel(), "prepare: returning false");
	    return false;
	}
	docView.getElementEditor().editElement(editedElement);
	// Alert.showError(docView.getPanel(), "prepare: returning true");
	return true;
    }

    protected Object doExecute(DocumentView docView, String parameter, int x, int y) {
	// Alert.showError(docView.getPanel(), "In CreateZipFile doExecute");
	// Try to remember file name for exception, so user knows which file causes a problem
	String sCurrentFileName = "unknown";

	String[] asFilenames = parameter.split("\\|");
	if (asFilenames.length < 3) {
	    Alert.showError(docView.getPanel(),
		    "CreateZipFile: parameter needs at least three lines.");
	}
	try {
	    sCurrentFileName = asFilenames[0] + File.separator + asFilenames[1];
	    File archive = new File(sCurrentFileName);
	    sCurrentFileName = asFilenames[0];
	    File baseDir = new File(asFilenames[0]);
	    if (asFilenames.length > 3) {
		// have more than just the main document file.
		// Look for highest directory which will be the first one if any
		int i = asFilenames[3].lastIndexOf(File.separator + "..");
		if (i >= 0) {
		    String sTopDir = asFilenames[3].substring(0, i + 3);
		    sCurrentFileName = sTopDir;
		    baseDir = new File(sTopDir);
		    // convert to canonical path so we get the true directory,
		    // not one with ..
		    sTopDir = baseDir.getCanonicalPath();
		    sCurrentFileName = sTopDir;
		    baseDir = new File(sTopDir);
		}
	    }

	    HashSet<String> filesAddedToZip = new HashSet<String>();
	    ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(archive));
	    Zip.Archive za = new Zip.Archive(zos);

	    for (int i = 2; i < asFilenames.length; i++) {
		sCurrentFileName = asFilenames[i];
		File f = new File(asFilenames[i]);
		// convert to canonical path so we get the true directory, not
		// one with ..
		String sCanonicalPath = f.getCanonicalPath();
		if (!filesAddedToZip.contains(sCanonicalPath)) {
		    // avoid adding the same file when the non-canonical paths are different
		    sCurrentFileName = sCanonicalPath;
		    f = new File(sCanonicalPath);
		    if (f.exists()) {
			    filesAddedToZip.add(sCanonicalPath);
			    za.add(f, baseDir);
		    }
		}
	    }

	    za.close();
	} catch (Exception e) {
	    Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage() + "\nProblematic file/directory name was: " + sCurrentFileName);
	    return e.getMessage();
	}
	return null;
    }

    private String setMessage(String message) {
	return "XLingPaper-" + message + "-XLingPaper";
    }
}
