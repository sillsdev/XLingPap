package xlingpaper.xxe;

import java.util.HashMap;
import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.util.Preferences;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.view.DocumentView;

public class LocalizeString extends RecordableCommand {
    boolean m_showAlerts = false; // used for debugging
    String lang;
    String locale;
    ResourceBundle messages;

    public boolean prepare(DocumentView docView, String parameter, int x, int y) {
	// Alert.showError(docView.getPanel(), "In DeleteFile prepare");
	// Alert.showError(docView.getPanel(), "prepare: parameter = |" +
	// parameter + "|");
	//// MarkManager markManager = docView.getMarkManager();
	//// if (markManager == null) {
	    // Alert.showError(docView.getPanel(),
	    // "prepare: markManager is null");
	//// return false;
	//// }

	//// Element editedElement = docView.getSelectedElement(/* implicit */true);
	//// if (editedElement == null) {
	    // Alert.showError(docView.getPanel(), "prepare: returning false");
	//// return false;
	//// }
	//// docView.getElementEditor().editElement(editedElement);
	// Alert.showError(docView.getPanel(), "prepare: returning true");
	return true;
    }

    protected Object doExecute(DocumentView docView, String parameter, int x, int y) {
	try {
	    showAlert(docView, "parameter =|" + parameter + "|");
	    String localizedText = null;
	    Preferences preferences = Preferences.getPreferences();
	    String locale = preferences.getString("locale", "en");
	    // System.err.println("\tlocale='" + locale + "'");
	    if (locale.length() < 2) {
		locale = "en";
	    }
	    //System.err.println("\tlocale='" + locale + "' after check for length");
	    if ("en".equals(locale)) {
		lang = "en";
	    } else {
		lang = locale.substring(0, 2);
	    }
	    //System.err.println("\tlang='" + lang + "'");

	    ResourceBundle messages = getMessages(lang);
	    //System.err.println("\tmessages='" + messages + "'");

	    if (messages == null && !"en".equals(lang)) {
		messages = getMessages("en");
		//System.err.println("\tmessages(en)='" + messages + "'");
	    }

	    if (messages != null) {
		try {
		    localizedText = messages.getString(parameter);
		} catch (Exception ignored) {}
	    } else {
		showAlert(docView, "messages is null");
	    }

	    if (localizedText == null)
		return parameter;
	    else
		return localizedText;

	} catch (Exception e) {
	    if (null != docView) {
		Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
	    }
	    return null;
	}
    }

    private static HashMap<String, ResourceBundle> langToMessages = new HashMap<String, ResourceBundle>(
	    5);

    private static ResourceBundle getMessages(String lang) {
	ResourceBundle messages = langToMessages.get(lang);
	if (messages == null) {
	    try {
		//System.err.println("before getBundle");
		messages = ResourceBundle.getBundle("localizations/XLingPap", new Locale(lang));
		if (messages == null) {
		    //System.err.println("after getBundle and messages is null");
		    messages = ResourceBundle.getBundle("localizations/XLingPap_es.properties");
		    //System.err.println("trying other getBundle");
		}
	    } // catch (MissingResourceException ignored) {}
	    catch (MissingResourceException ignored) {
		//System.err.println(ignored.getMessage());
		//System.err.println(ignored.getLocalizedMessage());
	    }
	    if (messages != null)
		langToMessages.put(lang, messages);
	}
	return messages;
    }

    // For debugging
    protected void showAlert(DocumentView docView, String msg) {
	if (m_showAlerts && null != docView) {
	    Alert.showError(docView.getPanel(), msg);
	}
    }
}
