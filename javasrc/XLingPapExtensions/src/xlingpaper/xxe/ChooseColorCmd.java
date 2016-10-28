package xlingpaper.xxe;

import java.awt.Color;
import java.lang.reflect.Field;

import javax.swing.JColorChooser;

import com.xmlmind.guiutil.AWTUtil;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xml.name.Name;
import com.xmlmind.xmledit.view.DocumentView;

import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.ElementEditor;
import com.xmlmind.xmledit.edit.MarkManager;

public class ChooseColorCmd extends RecordableCommand {
    public boolean prepare(DocumentView docView, 
                           String parameter, int x, int y) {
		MarkManager markManager = docView.getMarkManager();
		if (markManager == null)
		{
			/* Alert.showError(docView.getPanel(), "makrManager is null"); */
			return false;
		}

		Element editedElement = docView.getSelectedElement(/* implicit */true);
		if (editedElement == null) {
			return false;
		}
		docView.getElementEditor().editElement(editedElement);
		return true;
    }

    protected Object doExecute(DocumentView docView, 
                               String parameter, int x, int y) {
    	String ksColor = "color";

		ElementEditor elementEditor = docView.getElementEditor();
		Element editedElement = elementEditor.getEditedElement();

		Name attrName = Name.fromString(ksColor);
		String sColor = elementEditor.getAttribute(attrName);
		/* Alert.showError(docView.getPanel(), "old color = " + sColor); */
		Color oldColor = getColorFromString(sColor);

		LocalizeString ls = new LocalizeString();
		ls.prepare(docView, parameter, x, y);
		String sChooseAColor = (String)ls.doExecute(docView, "java.colorDialogTitle", x, y);
		Color newColor = JColorChooser.showDialog(AWTUtil.getDialogAnchor(docView.getPanel()), sChooseAColor, oldColor);
		if (newColor == null)
			return null;
		String sValue = "#" + Integer.toHexString(newColor.getRGB()).substring(2);
		if (elementEditor.canPutAttribute(attrName, sValue))
		{
			elementEditor.putAttribute(attrName, sValue);
			elementEditor.setEditedElement(editedElement);
		}

		return null;
    }
	private Color getColorFromString(String sColor)
	{
		int rgb = 0;
		if (sColor != null)
		{
			boolean bFound = false;
			try
			{ /* see if it's in #hhhhhh form */
				rgb = Integer.valueOf(sColor.substring(1), 16).intValue();
				bFound = true;
			}
			catch (Exception e)
			{  /* it's not */
			}
			if (!bFound)
			{  /* it was not in #hhhhhh form; try it as a color name */
				try
				{
					// Find the field and value of colorName
					Field field = Class.forName("java.awt.Color").getField(sColor);
					return (Color)field.get(null);
				}
				catch (Exception e)
				{  /* it's not; just use black (rgb == 0) */
				}
			}
		}
		/* Alert.showError(docView.getPanel(), "rgb = " + Integer.toHexString(rgb)); */
		return new Color(rgb);
	}
}
