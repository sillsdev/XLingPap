package xlingpaper.xxe;

import java.awt.Font;
import java.awt.Frame;

import javax.swing.JDialog;
import javax.swing.JFrame;

import com.xmlmind.guiutil.AWTUtil;
import com.xmlmind.guiutil.Alert;
import com.xmlmind.guiutil.FontChooserDialog;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.name.Name;
import xlingpaper.xxe.*;

public class ChooseFontCmd extends RecordableCommand {
    final String ksBold = "bold";
    final String ksItalic = "italic";
    final String ksNormal = "normal";
    final String ksFontFamily = "font-family";
    final String ksFontSize = "font-size";
    final String ksFontStyle = "font-style";
    final String ksFontWeight = "font-weight";
    String sUseDefault = "Use default";
    final String ksDefaultFontFamily = "Times New Roman";

    public boolean prepare(DocumentView docView, String parameter, int x, int y) {
	if (docView.getDocument() == null) {
	    // Alert.showError(docView.getPanel(),
	    // "docView.getDocument() is null");
	    return false;
	}

	MarkManager markManager = docView.getMarkManager();
	if (markManager == null) {
	    // Alert.showError(docView.getPanel(), "markManager is null");
	    return false;
	}

	Element editedElement = docView.getSelectedElement(/* implicit */true);
	if (editedElement == null) {
	    // Alert.showError(docView.getPanel(), "edited element is null");
	    return false;
	}
	docView.getElementEditor().editElement(editedElement);

	// Alert.showError(docView.getPanel(), "returning true");
	return true;
    }

    protected Object doExecute(DocumentView docView, String parameter, int x, int y) {

	LocalizeString ls = new LocalizeString();
	if (ls.prepare(docView, "java.fontDialogUseDefaultFontFamily", x, y)) {
	    sUseDefault = (String) ls.doExecute(docView, "java.fontDialogUseDefaultFontFamily", x, y);    
	}
	
	ElementEditor elementEditor = docView.getElementEditor();
	Element editedElement = elementEditor.getEditedElement();

	XLingPaperFontInfo oldFontInfo = prepareChooser(elementEditor);

	XLingPaperFontInfoChooserDialog chooser = new XLingPaperFontInfoChooserDialog(oldFontInfo);
	chooser.setVisible(true);
	if (chooser.getReturnStatus() == XLingPaperFontInfoChooserDialog.RET_CANCEL) {
	    return null;
	}
	XLingPaperFontInfo fontInfo = chooser.getFontInfo();
	if (fontInfo == null)
	    return null;

	recordChooserResults(docView, editedElement, fontInfo);

	return null;
    }

    private void recordChooserResults(DocumentView docView, Element editedElement,
	    XLingPaperFontInfo fontInfo) {
	setNewFontFamily(docView, editedElement, fontInfo);
	setNewFontSize(docView, editedElement, fontInfo);
	setNewFontWeightAndStyle(docView, editedElement, fontInfo);
    }

    private XLingPaperFontInfo prepareChooser(ElementEditor elementEditor) {
	String sFamily = getOldFontFamily(elementEditor);
	String sStyle = getOldFontStyle(elementEditor);
	String sWeight = getOldFontWeight(elementEditor);
	String sSize = getOldFontSize(elementEditor);
	int style = setOldFontStyleToShow(sStyle, sWeight);
	int size = setOldFontSizeToShow(sSize);
	XLingPaperFontInfo oldFontInfo = createOldFontInfo(sFamily, sStyle, sWeight, style, sSize,
		size);
	return oldFontInfo;
    }

    private void setNewFontWeightAndStyle(DocumentView docView, Element editedElement,
	    XLingPaperFontInfo fontInfo) {
	// if it got changed to italic, need to override the default
	if (fontInfo.getUseStyleDefault() && !fontInfo.getStyleItalic() && !fontInfo.getStylePlain()) {
	    removeAnAttribute(ksFontStyle, editedElement, docView);
	} else {
	    if (fontInfo.getStyleItalic()) {
		setAnAttribute(ksFontStyle, ksItalic, editedElement, docView);
	    } else {
		setAnAttribute(ksFontStyle, ksNormal, editedElement, docView);
	    }
	}
	// if it got changed to bold, need to override the default
	if (fontInfo.getUseWeightDefault() && !fontInfo.getStyleBold() && !fontInfo.getStylePlain()) {
	    removeAnAttribute(ksFontWeight, editedElement, docView);
	} else {
	    if (fontInfo.getStyleBold()) {
		setAnAttribute(ksFontWeight, ksBold, editedElement, docView);
	    } else {
		setAnAttribute(ksFontWeight, ksNormal, editedElement, docView);
	    }
	}
    }

    private void setNewFontSize(DocumentView docView, Element editedElement,
	    XLingPaperFontInfo fontInfo) {
	if (fontInfo.getUseSizeDefault()) {
	    removeAnAttribute(ksFontSize, editedElement, docView);
	} else {
	    String sFontSize = fontInfo.getFontSize().trim();
	    if (sFontSize.length() > 0) {
		String sSizeKind = "%";
		if (fontInfo.getUsePoints()) {
		    sSizeKind = "pt";
		}
		if (sFontSize.endsWith("pt") || sFontSize.endsWith("%")) {
		    sSizeKind = "";
		}
		setAnAttribute(ksFontSize, sFontSize + sSizeKind, editedElement, docView);
	    }
	}
    }

    private void setNewFontFamily(DocumentView docView, Element editedElement,
	    XLingPaperFontInfo fontInfo) {
	if (fontInfo.getUseFamilyDefault()) {
	    removeAnAttribute(ksFontFamily, editedElement, docView);
	} else {
	    String sFamily = fontInfo.getFontFamily();
	    setAnAttribute(ksFontFamily, sFamily, editedElement, docView);
	}
    }

    private XLingPaperFontInfo createOldFontInfo(String sFamily, String sStyle, String sWeight,
	    int style, String sSize, int size) {
	String sFamilyToShow = sFamily;
	if (sUseDefault.equals(sFamilyToShow)) {
	    sFamilyToShow = ksDefaultFontFamily;
	}
	XLingPaperFontInfo oldFontInfo = new XLingPaperFontInfo(sFamilyToShow, style, size);
	setFamilyDefault(sFamily, oldFontInfo);
	setStyleDefault(sStyle, oldFontInfo);
	setWeightDefault(sWeight, oldFontInfo);
	setFontSize(sSize, oldFontInfo);
	return oldFontInfo;
    }

    private void setFamilyDefault(String sFamily, XLingPaperFontInfo oldFontInfo) {
	if (sFamily == null || sFamily.length() == 0 || sUseDefault.equals(sFamily)) {
	    oldFontInfo.setUseFamilyDefault(true);
	    oldFontInfo.setFontFamily(sUseDefault);
	} else {
	    oldFontInfo.setUseFamilyDefault(false);
	    oldFontInfo.setFontFamily(sFamily);
	}
    }

    private void setFontSize(String sSize, XLingPaperFontInfo oldFontInfo) {
	oldFontInfo.setUsePercentage(true);
	if (sSize == null || sSize.length() == 0) {
	    oldFontInfo.setUseSizeDefault(true);
	    oldFontInfo.setFontSize(sUseDefault);
	} else {
	    if (sSize != null) {
		if (sSize.endsWith("%")) {
		    oldFontInfo.setFontSize(sSize.substring(0, sSize.length() - 1));
		    oldFontInfo.setUsePercentage(true);
		} else {
		    if (sSize.endsWith("pt")) {
			oldFontInfo.setFontSize(sSize.substring(0, sSize.length() - 2));
			oldFontInfo.setUsePoints(true);
		    }
		}
	    }
	}
    }

    private void setWeightDefault(String sWeight, XLingPaperFontInfo oldFontInfo) {
	oldFontInfo.setUseWeightDefault(true);
	if (sWeight != null && sWeight.length() > 0) {
	    oldFontInfo.setUseWeightDefault(false);
	}
    }

    private void setStyleDefault(String sStyle, XLingPaperFontInfo oldFontInfo) {
	oldFontInfo.setUseStyleDefault(true);
	if (sStyle != null && sStyle.length() > 0) {
	    oldFontInfo.setUseStyleDefault(false);
	}
    }

    private int setOldFontSizeToShow(String sSize) {
	int size = 12; // set default
	if (sSize != null) {
	    int i = sSize.indexOf("pt");
	    if (i > -1) {
		size = (int) Double.valueOf(sSize.substring(0, i)).intValue();
	    } else {
		i = sSize.indexOf("%");
		if (i > -1) {
		    size = (int) Double.valueOf(sSize.substring(0, i)).intValue();
		    size = (int) (size * .01 * 12);
		}
	    }
	}
	return size;
    }

    private String getOldFontSize(ElementEditor elementEditor) {
	Name attrName;
	attrName = Name.fromString(ksFontSize);
	String sSize = elementEditor.getAttribute(attrName);
	if (sSize != null) {
	    sSize = sSize.trim();
	}
	return sSize;
    }

    private int setOldFontStyleToShow(String sStyle, String sWeight) {
	int style = Font.PLAIN;
	if (sStyle != null && sStyle.equals(ksItalic)) {
	    if (sWeight != null && sWeight.equals(ksBold))
		style = Font.ITALIC + Font.BOLD;
	    else
		style = Font.ITALIC;
	} else {
	    if (sWeight != null && sWeight.equals(ksBold))
		style = Font.BOLD;
	}
	return style;
    }

    private String getOldFontWeight(ElementEditor elementEditor) {
	Name attrName;
	attrName = Name.fromString(ksFontWeight);
	String sWeight = elementEditor.getAttribute(attrName);
	if (sWeight != null) {
	    sWeight = sWeight.trim();
	}
	return sWeight;
    }

    private String getOldFontStyle(ElementEditor elementEditor) {
	Name attrName;
	attrName = Name.fromString(ksFontStyle);
	String sStyle = elementEditor.getAttribute(attrName);
	if (sStyle != null) {
	    sStyle = sStyle.trim();
	}
	return sStyle;
    }

    private String getOldFontFamily(ElementEditor elementEditor) {
	Name attrName = Name.fromString(ksFontFamily);
	String sFamily = elementEditor.getAttribute(attrName);
	if (sFamily == null || sFamily.length() == 0) {
	    sFamily = sUseDefault;
	}
	return sFamily;
    }

    protected void setAnAttribute(String sName, String sValue, Element editedElement,
	    DocumentView docView) {
	ElementEditor elementEditor = docView.getElementEditor();
	Name attrName = Name.fromString(sName);
	if (elementEditor.canPutAttribute(attrName, sValue)) {
	    elementEditor.putAttribute(attrName, sValue);
	    elementEditor.setEditedElement(editedElement);

	}
    }

    protected void removeAnAttribute(String sName, Element editedElement, DocumentView docView) {
	/*
	 * Alert.showError(m_docView.getPanel(), "can put attr: " + sName +
	 * " to " + sValue);
	 */
	ElementEditor elementEditor = docView.getElementEditor();
	Name attrName = Name.fromString(sName);

	if (elementEditor.canRemoveAttribute(attrName)) {
	    elementEditor.removeAttribute(attrName);
	    elementEditor.setEditedElement(editedElement);

	}
    }
}
