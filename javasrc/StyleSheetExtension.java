package xlingpaper.xxe;

/*
 * Based on the sample done by Pixware.
 * This version is much simpler and, rather than getting the locale from the document,
 * it gets the locale from the XXE preferences.
 * 
 * Copyright (c) 2003-2008 Pixware. 
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind XML Editor project.
 * For conditions of distribution and use, see the accompanying legal.txt file.
 */

import java.util.HashMap;
import java.util.Locale;
import java.util.ResourceBundle;
import java.util.MissingResourceException;
import com.xmlmind.util.Preferences;
import com.xmlmind.xml.doc.Node;
import com.xmlmind.xmledit.stylesheet.StyleValue;
import com.xmlmind.xmledit.stylesheet.StyleSpecsBase;
import com.xmlmind.xmledit.styledview.StyledViewFactory;

public class StyleSheetExtension extends StyleSpecsBase {

    // -----------------------------------------------------------------------

    public StyleSheetExtension(String[] args, StyledViewFactory viewFactory) {

    }

    // -----------------------------------------------------------------------

    public StyleValue localize(StyleValue[] args, Node contextNode, StyledViewFactory viewFactory) {
	String text;
	if (args.length != 1 || (text = args[0].stringValue()) == null) {
	    // System.err.println("usage: content: invoke('localize', text);");
	    return null;
	}

	// Element root = contextNode.getDocument().getRootElement();
	String lang; // = root.getTokenAttribute(Name.XML_LANG, "en");

	Preferences preferences = Preferences.getPreferences();
	String locale = preferences.getString("locale", "en");
	// System.err.println("\tlocale='" + locale + "'");
	if (locale.length() < 2) {
	    locale = "en";
	}
	// System.err.println("\tlocale='" + locale +
	// "' after check for length");
	if ("en".equals(locale)) {
	    lang = "en";
	} else {
	    lang = locale.substring(0, 2);
	}
	// System.err.println("\tlang='" + lang + "'");

	ResourceBundle messages = getMessages(lang);
	// System.err.println("\tmessages='" + messages + "'");

	if (messages == null && !"en".equals(lang))
	    messages = getMessages("en");

	String localizedText = null;
	if (messages != null) {
	    try {
		localizedText = messages.getString(text);
	    } catch (Exception ignored) {
	    }
	}

	if (localizedText == null)
	    return args[0];
	else
	    return StyleValue.createString(localizedText);

    }

    private static HashMap<String, ResourceBundle> langToMessages = new HashMap<String, ResourceBundle>(
	    5);

    private static ResourceBundle getMessages(String lang) {
	ResourceBundle messages = langToMessages.get(lang);
	if (messages == null) {
	    try {
		// System.err.println("before getBundle");
		messages = ResourceBundle.getBundle("localizations/XLingPap", new Locale(lang));
		if (messages == null) {
		    //System.err.println("after getBundle and messages is null")
		    // ;
		    messages = ResourceBundle.getBundle("localizations/XLingPap_es.properties");
		    // System.err.println("trying other getBundle");
		}
	    } // catch (MissingResourceException ignored) {}
	    catch (MissingResourceException ignored) {
		// System.err.println(ignored.getMessage());
		// System.err.println(ignored.getLocalizedMessage());
	    }
	    if (messages != null)
		langToMessages.put(lang, messages);
	}
	return messages;
    }

}
