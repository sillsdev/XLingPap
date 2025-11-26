package xlingpaper.xxe;

import java.io.File;
import java.io.IOException;

import org.apache.batik.apps.rasterizer.SVGConverter;
import org.apache.batik.apps.rasterizer.SVGConverterException;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.MarkManager;

public class ConvertSvgFileToPdf extends RecordableCommand {
	boolean m_showAlerts = false; // used for debugging
	static final String kFailure = "Failure";
	static final String kSuccess = "Success";

	public boolean prepare(DocumentView docView, String parameter, int x, int y) {
		MarkManager markManager = docView.getMarkManager();
		if (markManager == null) {
			return false;
		}
		return true;
	}

	protected Object doExecute(DocumentView docView, String parameter, int x, int y) {
		try {
			showAlert(docView, "parameter=:" + parameter);
			String imageFileSVG = parameter;
			if (imageFileSVG == null) {
				Alert.showError(docView.getPanel(), "imageFleSVG is null");
				return kFailure;
			}
			if (!imageFileSVG.toLowerCase().endsWith(".svg")) {
				showAlert(docView, "imageFileSVG does not end with .svg");
				return kFailure;
			}
			File fSVG = new File(imageFileSVG.trim());
			if (!fSVG.exists()) {
					return kFailure;
				}
			convertSvgToPDF(docView, fSVG);
			return kSuccess;
		} catch (Exception e) {
			e.printStackTrace();
			Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
			return e.getMessage();
		}
	}

	private void convertSvgToPDF(DocumentView docView, File fSVG) {
	    SVGConverter myConv = new SVGConverter();
	    myConv.setDestinationType(org.apache.batik.apps.rasterizer.DestinationType.PDF);
	    try {
	        myConv.setSources(new String[]{fSVG.getCanonicalPath()});

	    } catch (IOException iOException) {
	    	iOException.printStackTrace();
			Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + iOException.getMessage());
			return;
	    }

	    try {
	        myConv.execute();

	    } catch (SVGConverterException sVGConverterException) {
	    	sVGConverterException.printStackTrace();
			Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + sVGConverterException.getMessage());
			return;
	    }
	}
	
	// For debugging
	private void showAlert(DocumentView docView, String msg) {
		if (m_showAlerts) {
			Alert.showError(docView.getPanel(), msg);
		}
	}
}
