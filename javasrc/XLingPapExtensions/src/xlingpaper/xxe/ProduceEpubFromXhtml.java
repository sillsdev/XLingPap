package xlingpaper.xxe;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.OpenOption;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.util.stream.IntStream;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.util.FileUtil;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.MarkManager;

public class ProduceEpubFromXhtml extends RecordableCommand {
	final String kContainerXml = "<?xml version=\"1.0\"?>\n"
			+ "<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">\n"
			+ "<rootfiles>\n"
			+ "<rootfile full-path=\"content.opf\" media-type=\"application/oebps-package+xml\"/>\n"
			+ "</rootfiles>\n"
			+ "</container>\n";
	Path pOebpsPath;
	Path pOebpsFontsPath;
	Path pOebpsImagesPath;
	Path pOebpsStylesPath;
	Path pOebpsTextPath;
	Document document;
	XPath xPath;

	public boolean prepare(DocumentView docView, String parameter, int x, int y) {
		MarkManager markManager = docView.getMarkManager();
		if (markManager == null) {
			return false;
		}

		return true;
	}

	protected Object doExecute(DocumentView docView, String parameter, int x,
			int y) {
		try {
			// Alert.showError(docView.getPanel(), "parameter ='" + parameter + "'");
			// A File object to represent the filename
			File fHtmFile = new File(parameter.trim());

			// Make sure the file or directory exists and isn't write protected
			if (!fHtmFile.exists()) {
				return setMessage("FileNotThere");
			}
			// If it is a directory, make sure it is empty
			if (fHtmFile.isDirectory()) {
				return setMessage("FileIsADirectory");
			}

			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = factory.newDocumentBuilder();
			document = builder.parse(fHtmFile);
			xPath = XPathFactory.newInstance().newXPath();

			createDirectoryStructure();
			createMimetypeFile();

			createCssFile(docView, parameter);
			createImageFiles(docView, fHtmFile);
			createTextFile(parameter);

			return "success";

		} catch (Exception e) {
			return reportException(docView, e);
		}
	}

	protected void createMimetypeFile() throws FileNotFoundException, IOException {
		String sMimeTypeFile = pOebpsPath + File.separator + "mimetype";
		OutputStreamWriter writer =
		         new OutputStreamWriter(new FileOutputStream(sMimeTypeFile), StandardCharsets.UTF_8);
		writer.write("application/epub+zip");
		writer.close();
	}

	protected void createTextFile(String parameter) throws FileNotFoundException, IOException {
		String sHtmFile = parameter.trim();
		String sHtmContent = documentToString(document);
		int iSeparator = sHtmFile.lastIndexOf(File.separator);
		String sFileName = sHtmFile.substring(iSeparator);
		String sFileInOepbs = pOebpsTextPath.toString() + File.separator + sFileName;
		OutputStreamWriter writer =
		         new OutputStreamWriter(new FileOutputStream(sFileInOepbs), StandardCharsets.UTF_8);
		writer.write(sHtmContent);
		writer.close();
	}

	protected void createImageFiles(DocumentView docView, File fHtmFile) {
		
		NodeList graphics;
		try {
			graphics = (NodeList) xPath.compile("//img | //embed").evaluate(document, XPathConstants.NODESET);
			int iImageCount = 1;
			for (int i = 0; i < graphics.getLength(); i++) {
				Node node = graphics.item(i);
				createImageFile(docView, fHtmFile, iImageCount, node, true);
				iImageCount++;
			}
		} catch (XPathExpressionException e) {
			reportException(docView, e);
			}
	}

	protected void createImageFile(DocumentView docView, File fHtmFile, int iImageCount, Node node, boolean changeName) {
		Node src = node.getAttributes().getNamedItem("src");
		Path pSrc = Paths.get(fHtmFile.getParent() + File.separator + src.getNodeValue());
//		Alert.showError(docView.getPanel(), "image path = '" + pSrc.toString() + "'");
		String sSrc = pSrc.toString();
		Path pImage;
		if (changeName) {
			int iExtension = sSrc.lastIndexOf(".");
			String sExtension = sSrc.substring(iExtension);
			pImage = Paths.get(pOebpsImagesPath.toString() + File.separator + "image" + iImageCount + sExtension);

			int iLastSeparator = sSrc.lastIndexOf(File.separator);
//			Alert.showError(docView.getPanel(), "iLastSeparator =" + iLastSeparator);
			String sFileName = sSrc.substring(iLastSeparator + 1);
//			Alert.showError(docView.getPanel(), "sFileName ='" + sFileName + "'");
			src.setNodeValue("../Images/" + "image" + iImageCount + sExtension);
			Node newSrc = node.getAttributes().getNamedItem("src");
//			Alert.showError(docView.getPanel(), "new src ='" + newSrc.getNodeValue() + "'");
//			src.setTextContent("../Images/" + sFileName);

		
		} else {
			int iLastSeparator = sSrc.lastIndexOf(File.separator);
//			Alert.showError(docView.getPanel(), "iLastSeparator =" + iLastSeparator);
			String sFileName = sSrc.substring(iLastSeparator + 1);
//			Alert.showError(docView.getPanel(), "sFileName ='" + sFileName + "'");
			pImage = Paths.get(pOebpsImagesPath.toString() + File.separator + sFileName);
			src.setTextContent("../Images/" + sFileName);
//			Alert.showError(docView.getPanel(), "after setting src");
		}
//		Alert.showError(docView.getPanel(), "image path = '" + pImage.toString() + "'");
		try {
			Files.copy(pSrc, pImage, StandardCopyOption.REPLACE_EXISTING);
		} catch (Exception e) {
			reportException(docView, e);
		}
	}

	protected void createCssFile(DocumentView docView, String parameter) throws IOException {
		final String kStyleSheetName = "stylesheet.css";
		String sCssFile = parameter.trim();
		int extensionIndex = sCssFile.lastIndexOf(".");
		sCssFile = sCssFile.substring(0, extensionIndex) + ".css";
		File fCssFile = new File(sCssFile);
		Path pCss = Paths.get(pOebpsStylesPath.toString() + File.separator + kStyleSheetName);
		Files.copy(fCssFile.toPath(), pCss, StandardCopyOption.REPLACE_EXISTING);
		Node styleSheetLink;
		try {
			styleSheetLink = (Node) xPath.compile("/html/head/link[@rel=\"stylesheet\"]").evaluate(document, XPathConstants.NODE);
			Node href = styleSheetLink.getAttributes().getNamedItem("href");
			href.setNodeValue("../Styles/" + kStyleSheetName);
		} catch (XPathExpressionException e) {
			reportException(docView, e);
		}

	}

	protected void createDirectoryStructure() throws IOException {
		Path pEepubTempPath = Files.createTempDirectory("XLingPaperEpub");
		Path pMetaPath = Paths.get(pEepubTempPath.toString() + File.separator + "META-INF");
		Files.createDirectory(pMetaPath);
		Path containerXmlPath = Paths.get(pMetaPath.toString() + File.separator + "container.xml");
		Files.write(containerXmlPath, kContainerXml.getBytes(), StandardOpenOption.CREATE);
		pOebpsPath = Paths.get(pEepubTempPath.toString() + File.separator + "OEBPS");
		Files.createDirectory(pOebpsPath);
		pOebpsFontsPath = Paths.get(pOebpsPath.toString() + File.separator + "Fonts");
		Files.createDirectory(pOebpsFontsPath);
		pOebpsImagesPath = Paths.get(pOebpsPath.toString() + File.separator + "Images");
		Files.createDirectory(pOebpsImagesPath);
		pOebpsStylesPath = Paths.get(pOebpsPath.toString() + File.separator + "Styles");
		Files.createDirectory(pOebpsStylesPath);
		pOebpsTextPath = Paths.get(pOebpsPath.toString() + File.separator + "Text");
		Files.createDirectory(pOebpsTextPath);
	}

	protected String documentToString(Document doc) {
	    try {
	        StringWriter sw = new StringWriter();
	        TransformerFactory tf = TransformerFactory.newInstance();
	        Transformer transformer = tf.newTransformer();
	        transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "no");
	        transformer.setOutputProperty(OutputKeys.METHOD, "xml");
	        transformer.setOutputProperty(OutputKeys.INDENT, "yes");
	        transformer.setOutputProperty(OutputKeys.DOCTYPE_SYSTEM, "");
	        transformer.setOutputProperty(OutputKeys.DOCTYPE_PUBLIC, "\"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\"");
	        transformer.setOutputProperty(OutputKeys.ENCODING, "utf-8");

	        transformer.transform(new DOMSource(doc), new StreamResult(sw));
	        return sw.toString();
	    } catch (Exception ex) {
	        throw new RuntimeException("Error converting to String", ex);
	    }
	}
	private String setMessage(String message) {
		return "XLingPaper-" + message + "-XLingPaper";
	}

	protected Object reportException(DocumentView docView, Exception e) {
		Alert.showError(docView.getPanel(), "doExecute: Exception caught:" + e.getMessage());
		return e.getMessage();
	}
}
