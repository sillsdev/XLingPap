package xlingpaper.xxe;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Attribute;
import com.xmlmind.xml.doc.Document;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.doc.Node;
import com.xmlmind.xml.doc.Text;
import com.xmlmind.xml.doc.TextNode;
import com.xmlmind.xml.doc.XNode;
import com.xmlmind.xml.doc.Node.Type;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xml.name.Namespace;
import com.xmlmind.xml.xpath.EvalException;
import com.xmlmind.xml.xpath.ParseException;
import com.xmlmind.xml.xpath.XPathUtil;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmledit.cmd.CommandBase;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.cmd.select.SelectNode;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.edit.TextLocation;

public class BracketedConstituentInserter {
	// used for debugging
	boolean m_showAlerts = false;
	final String m_ksBracketClose = "tBracketClose";
	final String m_ksBracketLabel = "tBracketLabel";
	final String m_ksBracketOpen = "tBracketOpen";

	DocumentView docView;
	Node leftMostNode;
	Node rightMostNode;
	String sLabel;
	boolean fAbbreviationsExist = false;

	public BracketedConstituentInserter(DocumentView docView, Node leftMostNode,
			Node rightMostNode, String sLabel) {
		super();
		this.docView = docView;
		this.leftMostNode = leftMostNode;
		this.rightMostNode = rightMostNode;
		this.sLabel = sLabel;
		String sXpath = "//abbreviations";
		XNode[] results = null;
		try {
			results = XPathUtil.evalAsNodeSet(sXpath, docView.getDocument());
			if (results != null && results.length > 0) {
				fAbbreviationsExist = true;
			}
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (EvalException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void insert() {
		try {
			if (!checkSelectionValidity()) {
				return;
			}

			addBracketTypesIfNeeded();

			Element leftMost = (Element) leftMostNode;
			Element rightMost = (Element) rightMostNode;

			createLeftBracket(leftMost);

			createRightBracket(rightMost);

			createBracketLabel(rightMost, sLabel);

			return;
		} catch (Exception e) {
			Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
			return;
		}
	}

	private boolean checkSelectionValidity() {
		if (leftMostNode == null || !"wrd".equals(leftMostNode.name().localPart)
				|| leftMostNode.getType() != Type.ELEMENT) {
			showAlert(docView, "leftMostNode null or not wrd");
			return false;
		}
		if (rightMostNode == null || !"wrd".equals(rightMostNode.name().localPart)
				|| rightMostNode.getType() != Type.ELEMENT) {
			showAlert(docView, "rightMostNode null or not wrd");
			return false;
		}
		return true;
	}

	private void addBracketTypesIfNeeded() throws ParseException, EvalException {
		Document doc = docView.getDocument();
		String sXpath = "//types";
		XNode[] results;
		results = XPathUtil.evalAsNodeSet(sXpath, doc);
		if (results == null) {
			return;
		}
		Element types = (Element) results[0];
		results = getTypes(m_ksBracketClose, types);
		if (results.length == 0) {
			Element newType = new Element(Name.get(Namespace.NONE, "type"));
			newType.putAttribute(Name.get(Namespace.NONE, "id"), m_ksBracketClose);
			newType.putAttribute(Name.get(Namespace.NONE, "after"), "]");
			types.appendChild(newType);
		}
		results = getTypes(m_ksBracketLabel, types);
		if (results.length == 0) {
			Element newType = new Element(Name.get(Namespace.NONE, "type"));
			newType.putAttribute(Name.get(Namespace.NONE, "id"), m_ksBracketLabel);
			newType.putAttribute(Name.get(Namespace.NONE, "XeLaTeXSpecial"), "subscript");
			newType.putAttribute(Name.get(Namespace.NONE, "cssSpecial"), "vertical-align:sub;");
			// seemed too small for my taste
			// newType.putAttribute(Name.get(Namespace.NONE, "font-size"),
			// "65%");
			newType.putAttribute(Name.get(Namespace.NONE, "xsl-foSpecial"), "baseline-shift='sub'");
			types.appendChild(newType);
		}
		results = getTypes(m_ksBracketOpen, types);
		if (results.length == 0) {
			Element newType = new Element(Name.get(Namespace.NONE, "type"));
			newType.putAttribute(Name.get(Namespace.NONE, "id"), m_ksBracketOpen);
			newType.putAttribute(Name.get(Namespace.NONE, "before"), "[");
			types.appendChild(newType);
		}
	}

	private void createBracketLabel(Element rightMost, String parameter) throws ParseException,
			EvalException {
		Element labelObject = new Element(Name.get(Namespace.NONE, "object"));
		labelObject.forceText(parameter);
		labelObject.putAttribute(Name.get(Namespace.NONE, "type"), m_ksBracketLabel);
		rightMost.appendChild(labelObject);
		if (fAbbreviationsExist) {
			ConvertAnyAbbreviationsToAbbrRefs converter = new ConvertAnyAbbreviationsToAbbrRefs();
			converter.convertAnyAbbreviations(docView, labelObject, rightMost);
			docView.executeCommand("selectNode", "self[implicitNode]", 0, 0);
		}
	}

	private void createRightBracket(Element rightMost) {
		Element rightObject = new Element(Name.get(Namespace.NONE, "object"));
		rightObject.putAttribute(Name.get(Namespace.NONE, "type"), m_ksBracketClose);
		rightMost.appendChild(rightObject);
	}

	private void createLeftBracket(Element leftMost) {
		Element leftObject = new Element(Name.get(Namespace.NONE, "object"));
		leftObject.putAttribute(Name.get(Namespace.NONE, "type"), m_ksBracketOpen);
		leftMost.insertChild(leftMost.getFirstChild(), leftObject);
	}

	private XNode[] getTypes(String sType, XNode types) throws ParseException, EvalException {
		final String ksXPathPrefix = "type[@id='";
		final String ksXPathPostfix = "']";

		String sXPath = ksXPathPrefix + sType + ksXPathPostfix;
		// showAlert(docView, "getTypes: sXPath='" + sXPath + "'");
		XNode[] results = XPathUtil.evalAsNodeSet(sXPath, types);
		// showAlert(docView, "getTypes: results length=" + results.length);
		return results;
	}

	// For debugging
	private void showAlert(DocumentView docView, String msg) {
		if (m_showAlerts) {
			Alert.showError(docView.getPanel(), msg);
		}
	}
}
