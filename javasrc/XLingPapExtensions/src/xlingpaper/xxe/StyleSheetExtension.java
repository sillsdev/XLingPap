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

import com.xmlmind.guiutil.Alert;
import com.xmlmind.util.Preferences;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.Node;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.xpath.EvalException;
import com.xmlmind.xml.xpath.ParseException;
import com.xmlmind.xml.xpath.XPathUtil;
import com.xmlmind.xmledit.stylesheet.StyleValue;
import com.xmlmind.xmledit.stylesheet.StyleSpecsBase;
import com.xmlmind.xmledit.styledview.StyledViewFactory;
import com.xmlmind.xmledit.view.DocumentView;

public class StyleSheetExtension extends StyleSpecsBase {

    // -----------------------------------------------------------------------

    public StyleSheetExtension(String[] args, StyledViewFactory viewFactory) {

    }

    // -----------------------------------------------------------------------

    public StyleValue capitalize(StyleValue[] args, Node contextNode, StyledViewFactory viewFactory) {
	if (contextNode.name().localPart != "glossaryTermRef") {
	    return StyleValue.createString("ERROR!");
	}

	try {
	    Element term = (Element) contextNode;
	    String text = term.getText();
	    String capitalizedText = "Original nothing";
	    if (text.length() > 0) {
		// nothing to return; user needs to capitalize it
		return StyleValue.createString("");
	    } else {
		Document doc = contextNode.getDocument();
		String sGlossaryTerm = contextNode.attributeValue(Name.get("glossaryTerm"));
		String sXpath = "(/xlingpaper/styledPaper/lingPaper|/lingPaper)";
		XNode[] results = null;
		try {
		    results = XPathUtil.evalAsNodeSet(sXpath, doc);
		} catch (ParseException e1) {
		    return StyleValue.createString("unexpectedPE for lingPaper element: "
			    + e1.getMessage());
		} catch (EvalException e1) {
		    return StyleValue.createString("unexpectedE for lingPaper element: "
			    + e1.getMessage());
		}
		if (results == null) {
		    return StyleValue.createString("Could not get lingPaper element");
		}
		String sGlossaryTermLang = results[0].attributeValue(Name.get("glossarytermlang"));

		if (sGlossaryTermLang != null && sGlossaryTermLang.length() > 0) {

		    sXpath = "id('" + sGlossaryTerm + "')/glossaryTermInLang[@lang='"
			    + sGlossaryTermLang + "']/glossaryTermTerm";
		    try {
			results = XPathUtil.evalAsNodeSet(sXpath, doc);
		    } catch (ParseException e1) {
			return StyleValue.createString("unexpectedPE: " + e1.getMessage());
		    } catch (EvalException e1) {
			return StyleValue.createString("unexpectedE: " + e1.getMessage());
		    }
		    if (results != null && results.length > 0) {
			term = (Element) results[0];
			capitalizedText = capitalizeString(term.getText());
		    } else {
			capitalizedText = getDefaultTerm(doc, sGlossaryTerm);
		    }
		} else {
		    capitalizedText = getDefaultTerm(doc, sGlossaryTerm);
		}
	    }
	    return StyleValue.createString(capitalizedText);
	} catch (Exception e) {
	    return StyleValue.createString("unexpectedE somewhere: " + e.toString()
		    + e.getMessage());
	}
    }

    private String getDefaultTerm(Document doc, String sGlossaryTerm) {
	Element term;
	XNode[] results = null;
	String sXpath;
	String capitalizedText = "default";
	sXpath = "id('" + sGlossaryTerm + "')/glossaryTermInLang[1]/glossaryTermTerm";
	try {
	    results = XPathUtil.evalAsNodeSet(sXpath, doc);
	} catch (ParseException e1) {
	    capitalizedText = StyleValue.createString("expectedPE: " + e1.getMessage())
		    .stringValue();
	} catch (EvalException e1) {
	    capitalizedText = StyleValue.createString("expectedE: " + e1.getMessage())
		    .stringValue();
	}
	if (results != null) {
	    term = (Element) results[0];
	    capitalizedText = capitalizeString(term.getText());
	}
	return capitalizedText;
    }

    private String capitalizeString(String text) {
	String capitalizedText = "";

	if (text.length() >= 2) {
	    capitalizedText = Character.toUpperCase(text.charAt(0)) + text.substring(1);
	} else if (text.length() == 1) {
	    capitalizedText = Character.toUpperCase(text.charAt(0)) + "";
	}
	return capitalizedText;
    }

    public StyleValue citationRefDateAugment(StyleValue[] args, Node contextNode,
	    StyledViewFactory viewFactory) {
	    String augmentText = "";
	if (contextNode.name().localPart != "citation") {
	    return StyleValue.createString("ERROR:Not a citation element!");
	}

	try {
	    final String alphabet = "abcdefghijklmnopqrstuvwxyz";
	    Element citation = (Element) contextNode;

	    XNode[] results = XPathUtil.evalAsNodeSet("id(@ref)/refDate", citation);
	    if (results == null) {
		return StyleValue.createString("ERROR:Could not get refDate!");
	    }

	    //augmentText = "before results[0]; length=" + results.length; // for debugging
	    if (results.length == 0) {
		return StyleValue.createString(augmentText);
	    }
	    Element thisRefDate = (Element) results[0];
	    String thisDate = thisRefDate.getText();

	    results = XPathUtil.evalAsNodeSet("../preceding-sibling::refWork[refDate='" + thisDate
		    + "']", thisRefDate);
	    if (results != null) {
		int index = Math.min(results.length, 25);
		// augmentText = "index=" + index; // for debugging
		augmentText = alphabet.substring(index, index + 1);
		if (index == 0) {
		    results = XPathUtil.evalAsNodeSet("../following-sibling::refWork[refDate='"
			    + thisDate + "']", thisRefDate);
		    if (results != null && results.length > 0) {
			augmentText = "a";
		    } else {
			augmentText = "";
		    }
		}		
	    }
	    return StyleValue.createString(augmentText);
	} catch (Exception e) {
	    return StyleValue.createString("unexpectedE somewhere: " + e.toString()
		    + e.getMessage() + " text = " + augmentText);
	}
    }

    /*****
     * did not work
     * 
     * public StyleValue localize(StyleValue[] args, Node contextNode,
     * StyledViewFactory viewFactory) { String text; if (args.length != 1 ||
     * (text = args[0].stringValue()) == null) { //
     * System.err.println("usage: content: invoke('localize', text);"); return
     * null; }
     * 
     * // Element root = contextNode.getDocument().getRootElement(); String
     * lang; // = root.getTokenAttribute(Name.XML_LANG, "en");
     * 
     * Preferences preferences = Preferences.getPreferences(); String locale =
     * preferences.getString("locale", "en"); // System.err.println("\tlocale='"
     * + locale + "'"); if (locale.length() < 2) { locale = "en"; } //
     * System.err.println("\tlocale='" + locale + //
     * "' after check for length"); if ("en".equals(locale)) { lang = "en"; }
     * else { lang = locale.substring(0, 2); } // System.err.println("\tlang='"
     * + lang + "'");
     * 
     * ResourceBundle messages = getMessages(lang); //
     * System.err.println("\tmessages='" + messages + "'");
     * 
     * if (messages == null && !"en".equals(lang)) messages = getMessages("en");
     * 
     * String localizedText = null; if (messages != null) { try { localizedText
     * = messages.getString(text); } catch (Exception ignored) { } }
     * 
     * if (localizedText == null) return args[0]; else return
     * StyleValue.createString(localizedText);
     * 
     * }
     * 
     * private static HashMap<String, ResourceBundle> langToMessages = new
     * HashMap<String, ResourceBundle>( 5);
     * 
     * private static ResourceBundle getMessages(String lang) { ResourceBundle
     * messages = langToMessages.get(lang); if (messages == null) { try { //
     * System.err.println("before getBundle"); messages =
     * ResourceBundle.getBundle("localizations/XLingPap", new Locale(lang)); if
     * (messages == null) { //
     * System.err.println("after getBundle and messages is null") // ; messages
     * = ResourceBundle.getBundle("localizations/XLingPap_es.properties"); //
     * System.err.println("trying other getBundle"); } } // catch
     * (MissingResourceException ignored) {} catch (MissingResourceException
     * ignored) { // System.err.println(ignored.getMessage()); //
     * System.err.println(ignored.getLocalizedMessage()); } if (messages !=
     * null) langToMessages.put(lang, messages); } return messages; }
     *****/
}
