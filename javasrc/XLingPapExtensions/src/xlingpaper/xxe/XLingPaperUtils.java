package xlingpaper.xxe;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xmledit.view.DocumentView;

public final class XLingPaperUtils {
    final static char cSeparator = '|';

    final static public String firstParameter(String parameter) {
	int separatorIndex = parameter.indexOf(cSeparator);
	return parameter.substring(0, separatorIndex);
    }
    final static public String secondParameter(String parameter) {
	int separatorIndex = parameter.indexOf(cSeparator);
	return parameter.substring(separatorIndex + 1);
    }
    final static public void showAlert(Boolean showAlerts, DocumentView docView, String msg) {
	if (showAlerts) {
	    Alert.showError(docView.getPanel(), msg);
	}
    }
    final static public String fixupImageFile(String sDocumentPath, String imageFile) {
	String operatingSystem = System.getProperty("os.name");
	if (operatingSystem.contains("Windows")) {
		// need to change any '/' to '\' in file name
		imageFile = imageFile.replace("/", "\\");
	}
	if (imageFile.startsWith("..") || imageFile.startsWith("./") || imageFile.startsWith(".\\")) {
		imageFile = sDocumentPath + System.getProperty("file.separator") + imageFile;
	}
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
    final static public void fixID(Element element, String id, String idName, String initialId) {
	if (id != null && initialId.equals(id)) {
	    // System.err.println(
	    // "Found example/listInterlinear with num/letter=x:" + element);
	    // System.err.println("   xpath=" + element.getXPath());
	    String sMyId = element.getXPath();
	    String sMyId2 = sMyId.replace('[', '.');
	    // System.err.println("   new id=" + sMyId2);
	    String sMyId3 = sMyId2.replace(']', '.');
	    // System.err.println("   new id=" + sMyId3);
	    String sMyId4 = sMyId3.replace('/', '.');
	    /*
	     * String sMyId4 = element.getXPath().replace('[', '.').replace(']',
	     * '.').replace('/', '.');
	     */
	    // System.err.println("   new id=" + sMyId4);
	    element.putAttribute(Name.get(idName), initialId + "-NeedsALabel-" + sMyId4);
	    /*
	     * try { element.putAttribute(Name.get(idName), "x-NeedsALabel-" +
	     * XPathUtil.evalAsString("generate-id()", element)); } catch
	     * (ParseException e) { System.err.println("ParseException thrown:"
	     * + element);
	     * 
	     * } catch (EvalException e) {
	     * System.err.println("EvalException thrown:" + element); }
	     */
	}

    }

}
