package xlingpaper.xxe;

import java.io.UnsupportedEncodingException;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.MarkManager;
import com.xmlmind.xmledit.view.DocumentView;

public class ConvertFileNameToURI extends RecordableCommand {
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
	String sFileName = parameter;
	//Alert.showError(docView.getPanel(), "in doExecute; parameter = " + sFileName);
	try {
	    String sResult = encodeOthers(sFileName);
	    //Alert.showError(docView.getPanel(), "result = " + sResult);
	    return sResult;
	} catch (Exception e) {
	    return "Failed to produce URI";
	}
    }

    
    // Following taken from: http://www.jarvana.com/jarvana/view/org/apache/axis2/axis2-kernel/1.4/axis2-kernel-1.4-sources.jar!/org/apache/axis2/transport/http/util/URIEncoderDecoder.java?format=ok
    // It's been modified to also convert space to %20
/**
 *    Copyright 2011 SIL International

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
    /**
     * Other characters, which are Unicode chars that are not US-ASCII, and are
     * not ISO Control or are not ISO Space chars are not preserved. They are
     * converted into their hexidecimal value prepended by '%'.
     * <p/>
     * For example: Euro currency symbol -> "%E2%82%AC".
     * <p/>
     * Called from URI.toASCIIString()
     * <p/>
     *
     * @param s java.lang.String the string to be converted
     * @return java.lang.String the converted string
     */
    private String encodeOthers(String s) throws UnsupportedEncodingException {
	   final String digits = "0123456789ABCDEF"; //$NON-NLS-1$

	    final String encoding = "UTF8"; //$NON-NLS-1$


        StringBuffer buf = new StringBuffer();
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            if (ch == 32) {
        	buf.append("%20");
            } else if (ch <= 127) {
                buf.append(ch);
            } else {
                byte[] bytes = new String(new char[]{ch}).getBytes(encoding);
                for (int j = 0; j < bytes.length; j++) {
                    buf.append('%');
                    buf.append(digits.charAt((bytes[j] & 0xf0) >> 4));
                    buf.append(digits.charAt(bytes[j] & 0xf));
                }
            }
        }
        return buf.toString();
    }

}
