package xlingpaper.xxe;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Attribute;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.Node;
import com.xmlmind.xml.doc.Text;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xml.doc.Node.Type;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.name.Namespace;
import com.xmlmind.xml.xpath.EvalException;
import com.xmlmind.xml.xpath.ParseException;
import com.xmlmind.xml.xpath.XPathUtil;
import com.xmlmind.xmledit.view.DocumentView;

import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;

public class ConvertAnyAbbreviationsToAbbrRefs extends RecordableCommand {
    	// used for debugging
    boolean m_showAlerts = false; 
    	// the delimiters that separate potential abbreviations
    String m_delims = "-=~<>\\._;:\\\\  \\[\\]\\(\\)"; 
    String m_sAbbreviationLang = "";
    String m_fontissmallcaps = "";

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
	ElementEditor elementEditor = docView.getElementEditor();
	Element editedElement = elementEditor.getEditedElement();

	if (editedElement == null) {
	    return null;
	}

	try {
	    Element gloss = editedElement;
	    if (gloss == null || (!"gloss".equals(gloss.name().localPart) && !"object".equals(gloss.name().localPart) && !"item".equals(gloss.name().localPart))) {
		return null;
	    }

	    Element parent = gloss.getParentElement();
	    if (parent == null)
		return null;

	    return convertAnyAbbreviations(docView, gloss, parent);
	} catch (Exception e) {
	    Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
	    return e.getMessage();
	}
    }

    protected Object convertAnyAbbreviations(DocumentView docView, Element gloss, Element parent)
	    throws ParseException, EvalException {
	Document doc = docView.getDocument();
	
	String sXpath = "(/xlingpaper/styledPaper/lingPaper|/lingPaper)";
	XNode[] results = null;
	try {
	    results = XPathUtil.evalAsNodeSet(sXpath, doc);
	} catch (ParseException e1) {
	    return null;
	} catch (EvalException e1) {
	    return null;
	}
	if (results == null) {
	    return null;
	}
	m_sAbbreviationLang = results[0].attributeValue(Name.get("abbreviationlang"));

	sXpath = "//abbreviations";
	results = XPathUtil.evalAsNodeSet(sXpath, doc);
	if (results == null) {
	    return null;
	}

	XNode abbreviations = results[0];
	m_fontissmallcaps = abbreviations.attributeValue(Name.get("fontissmallcaps"));
	showAlert(docView, "fontissmallcaps = " + m_fontissmallcaps);
	
	Element newGloss = createNewGloss(gloss);
	Node[] children = gloss.getChildren();
	for (Node node : children) {
	    showAlert(docView, "Children node loop: node = " + node.toString());
	    if (node.getType() == Type.TEXT) {
		String origGlossText = node.data().trim();
		showAlert(docView, "have text node; is = '" + origGlossText + "'");
		String[] potentialAbbreviations = origGlossText.split("[" + m_delims + "]");
		if (potentialAbbreviations == null) {
		    continue;
		}
		int indexInOrigGlossText = 0;
		// handle any word-initial delimiters
		showAlert(docView, "Before word-initial handleDelimiter: index = "
			+ indexInOrigGlossText);
		indexInOrigGlossText = handleDelimiter(docView, newGloss, origGlossText,
			indexInOrigGlossText);
		showAlert(docView, "After word-initial handleDelimiter: index = "
			+ indexInOrigGlossText);
		for (String abbr : potentialAbbreviations) {
		    convertAnAbbreviation(docView, newGloss, abbr, abbreviations);
		    indexInOrigGlossText += abbr.length();
		    showAlert(docView, "Before handleDelimiter: index = " + indexInOrigGlossText);
		    indexInOrigGlossText = handleDelimiter(docView, newGloss, origGlossText,
			    indexInOrigGlossText);
		    showAlert(docView, "After handleDelimiter: index = " + indexInOrigGlossText);
		}
		while (indexInOrigGlossText < origGlossText.length()) {
		    showAlert(docView, "After working on potential abbreviations: Before handleDelimiter: index = " + indexInOrigGlossText);
		    indexInOrigGlossText = handleDelimiter(docView, newGloss, origGlossText,
			    indexInOrigGlossText);   
		    showAlert(docView, "After handleDelimiter: index = " + indexInOrigGlossText);
		}
	    } else {
		showAlert(docView, "Non-text node");
		if (node.getType() == Type.ELEMENT) {
		    // need to create a copy of the embedded element and put it
		    // in a new parent so the
		    // converted element can replace it
		    Element newParent = new Element(gloss.name()); // new Element(Name.get(Namespace.NONE, "gloss"));
		    copyAndAppendNode(docView, newParent, node, "Element node found");
		    convertAnyAbbreviations(docView, (Element) newParent.getFirstChildElement(),
			    newParent);
		    // now we need to put the converted embedded gloss into the
		    // current new gloss
		    copyAndAppendNode(docView, newGloss, newParent.getFirstChildElement(),
			    "setting embedded gloss");
		} else {
		    copyAndAppendNode(docView, newGloss, node, "Appending non-element node");
		}
	    }
	}
	showAlert(docView, "before replace child: gloss = " + gloss + " newGloss = " + newGloss
		+ newGloss.getChildCount() + " parent = " + parent);
	try {
	    parent.replaceChild(gloss, newGloss);
	} catch (Exception e) {
	    // TODO: handle exception
	    // can get null exception here if the original gloss element was
	    // selected; not sure why; ignore it
	}
	showAlert(docView, "after replace child");
	return null;
    }

    private void copyAndAppendNode(DocumentView docView, Element newGloss, Node node, String sMsg) {
	showAlert(docView, sMsg);
	Node newNode = node.copy();
	newGloss.appendChild(newNode);
    }

    private int handleDelimiter(DocumentView docView, Element newGloss, String origGlossText,
	    int indexInOrigGlossText) {
	if (indexInOrigGlossText >= origGlossText.length())
	    return indexInOrigGlossText;
	int i = m_delims.indexOf(origGlossText.charAt(indexInOrigGlossText));
	if (i > -1) {
	    setText(docView, newGloss, m_delims.substring(i, i + 1));
	    indexInOrigGlossText++;
	}
	return indexInOrigGlossText;
    }

    private void convertAnAbbreviation(DocumentView docView, Element newGloss, String abbr,
	    XNode abbreviations) throws ParseException, EvalException {

	// look for the entire abbreviation
	// if not found and using small caps, make it lower case and look again
	// if still not found, see if first character is a digit (1-3).
	// if so, see if that can be found and also if what is left can be found
	// if so, use the digit and what comes after as two abbrRefs
	boolean fIsUppercase = false;

	XNode[] results = getAbbreviations(abbr, abbreviations, docView);
	if (((m_fontissmallcaps == null) || "yes".equals(m_fontissmallcaps)) && ((results == null) || (results.length == 0))) {
	    showAlert(docView, "inside small caps if: abbr lowered = " + abbr.toLowerCase());
	    fIsUppercase = true;
	    results = getAbbreviations(abbr.toLowerCase(), abbreviations, docView);
	}
	if ((results != null) && (results.length > 0)) {
	    createAndAppendAbbrRef(docView, newGloss, results);
	    return;
	}
	if (abbr.length() > 1) {
	    if (abbr.startsWith("1") || abbr.startsWith("2") || abbr.startsWith("3")) {
		results = getAbbreviations(abbr.substring(0, 1), abbreviations, docView);
		if ((results != null) && (results.length > 0)) {
		    String abbrNoInitialDigit = abbr.substring(1);
		    if (fIsUppercase) {
			abbrNoInitialDigit = abbrNoInitialDigit.toLowerCase();
		    }
		    XNode[] resultsRest = getAbbreviations(abbrNoInitialDigit, abbreviations, docView);
		    if ((resultsRest != null) && (resultsRest.length > 0)) {
			createAndAppendAbbrRef(docView, newGloss, results);
			createAndAppendAbbrRef(docView, newGloss, resultsRest);
			return;
		    }
		}
	    }
	}
	setText(docView, newGloss, abbr);
	showAlert(docView, "newGloss = " + newGloss.getText());
    }

    private void createAndAppendAbbrRef(DocumentView docView, Element newGloss, XNode[] results) {
	String id = ((Element) results[0]).getAttribute(Name.get("id"));
	if (id != null) {
	    Element abbrRef = new Element(Name.get(Namespace.NONE, "abbrRef"));
	    abbrRef.putAttribute(Name.get(Namespace.NONE, "abbr"), id);
	    showAlert(docView, "before appending abbrRef");
	    newGloss.appendChild(abbrRef);
	}
    }

    private XNode[] getAbbreviations(String abbr, XNode abbreviations, DocumentView docView) throws ParseException,
	    EvalException {
	final String ksXPathPrefix = "abbreviation[descendant::abbrTerm[.='";
	final String ksXPathPostfix = "]]";

	if (abbr.contains("'")) {
	    // if the potential abbreviation contains an apostrophe, the XPath will fail to parse
	    // we skip this abbreviation
	    XNode[] nothing = new XNode[0];
	    return nothing;
	}
	String sAbbrInLang = "'";
	if (m_sAbbreviationLang != null && m_sAbbreviationLang.length() > 0) {
	    sAbbrInLang = "' and parent::abbrInLang[@lang='" + m_sAbbreviationLang + "']";
	}
	String sXPath = ksXPathPrefix + abbr + sAbbrInLang + ksXPathPostfix;
	showAlert(docView, "getAbbreviations: sXPath='" + sXPath + "'");
	XNode[] results = XPathUtil.evalAsNodeSet(sXPath, abbreviations);
	showAlert(docView, "getAbbreviations: results length=" + results.length);
	return results;
    }

    private void setText(DocumentView docView, Element newGloss, String abbr) {
	Text textnode = new Text(abbr);
	if (newGloss.lastChild() instanceof Text) {
	    showAlert(docView, "before appending textnode: " + textnode.getText());
	    ((Text) newGloss.lastChild()).appendText(textnode.getText());
	} else {
	    showAlert(docView, "before creating textnode: " + textnode.getText());
	    newGloss.appendChild(textnode);
	}
    }

    private Element createNewGloss(Element gloss) {
	Attribute[] glossAttrs = gloss.getAllAttributes();
	Element newGloss = new Element(gloss.name());
	for (Attribute attribute : glossAttrs) {
	    newGloss.putAttribute(attribute.name, attribute.value);
	}
	return newGloss;
    }

    // For debugging
    private void showAlert(DocumentView docView, String msg) {
	if (m_showAlerts) {
	    Alert.showError(docView.getPanel(), msg);
	}
    }
}
