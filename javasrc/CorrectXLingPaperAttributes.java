package xlingpaper.xxe;

import java.net.URL;

import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.Traversal;
import com.xmlmind.xml.doc.XNode;

import com.xmlmind.xml.name.Name;

import com.xmlmind.xmleditapp.validatehook.Reason;
import com.xmlmind.xmleditapp.validatehook.ValidateHookBase;

public class CorrectXLingPaperAttributes extends ValidateHookBase {

    /* All we need to look at is before the document is checked. */
    public void checkingDocument(Document doc) {
	checkingDocument(doc, null, null);
    }

    public void checkingDocument(Document doc, Reason reason, URL saveAsURL) {
	doc.beginEdit();
	Traversal.traverse(doc.getRootElement(), new Traversal.HandlerBase() {
	    public Object enterElement(Element element) {
		String exampleInitialId = "x";
		String localName = element.getLocalName();

		if ("interlinear".equals(localName)) {
		    String text = element.getAttribute(Name.get("text"));
		    if (text != null) {
			XNode parent = element.parent();
			if (parent != null) {
			    String sParentName = parent.name().localPart;
			    if ("example".equals(sParentName)
				    || "listInterlinear".equals(sParentName)) {
				element.removeAttribute(Name.get("text"));
			    } else if ("interlinear-text".equals(sParentName)) {
				String sTextRefAttr = "textref";
				String textref = element.getAttribute(Name.get(sTextRefAttr));
				if (!text.equals(textref)) {
				    element.putAttribute(Name.get(sTextRefAttr), text);
				}
			    }
			}
		    }
		}

		if ("example".equals(localName)) {
		    String attr = "num";
		    String id = element.getAttribute(Name.get(attr));
		    XLingPaperUtils.fixID(element, id, attr, exampleInitialId);
		}

		if ("exampleRef".equals(localName)) {
		    // System.err.println("Found exampleRef:" + element);
		    String letterAttr = "letter";
		    String letter = element.getAttribute(Name.get(letterAttr));
		    // System.err.println("\tletter='" + letter + "'");
		    String numAttr = "num";
		    String num = element.getAttribute(Name.get(numAttr));
		    // System.err.println("\tnum='" + num + "'");
		    if ("x".equals(letter) && !"x".equals(num)) {
			element.putAttribute(Name.get(letterAttr), num);
		    }
		}

		if ("listInterlinear".equals(localName)) {
		    String attr = "letter";
		    String id = element.getAttribute(Name.get(attr));
		    XLingPaperUtils.fixID(element, id, attr, exampleInitialId);
		}
		if ("listWord".equals(localName)) {
		    String attr = "letter";
		    String id = element.getAttribute(Name.get(attr));
		    XLingPaperUtils.fixID(element, id, attr, exampleInitialId);
		}
		if ("listDefinition".equals(localName)) {
		    String attr = "letter";
		    String id = element.getAttribute(Name.get(attr));
		    XLingPaperUtils.fixID(element, id, attr, exampleInitialId);
		}
		if ("listSingle".equals(localName)) {
		    String attr = "letter";
		    String id = element.getAttribute(Name.get(attr));
		    XLingPaperUtils.fixID(element, id, attr, exampleInitialId);
		}

		if ("endnote".equals(localName)) {
		    String attr = "id";
		    String id = element.getAttribute(Name.get(attr));
		    XLingPaperUtils.fixID(element, id, attr, "n");
		}

		if ("refWork".equals(localName)) {
		    String attr = "id";
		    String id = element.getAttribute(Name.get(attr));
		    XLingPaperUtils.fixID(element, id, attr, "r");
		}

		if ("figure".equals(localName)) {
		    String attr = "id";
		    String id = element.getAttribute(Name.get(attr));
		    XLingPaperUtils.fixID(element, id, attr, "f");
		}

		if ("tablenumbered".equals(localName)) {
		    String attr = "id";
		    String id = element.getAttribute(Name.get(attr));
		    XLingPaperUtils.fixID(element, id, attr, "nt");
		}

		return null;
	    }
	});
	doc.endEdit();
    }
}
