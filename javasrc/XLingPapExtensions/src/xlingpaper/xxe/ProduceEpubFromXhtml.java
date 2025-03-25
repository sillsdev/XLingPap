package xlingpaper.xxe;

import java.awt.Font;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.OpenOption;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.stream.Collector;
import java.util.stream.Collectors;
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











import sun.font.Font2D;
import sun.font.FontManager;
import sun.font.PhysicalFont;

import com.xmlmind.guiutil.Alert;
import com.xmlmind.util.FileUtil;
import com.xmlmind.xml.doc.Element;
import com.xmlmind.xmledit.view.DocumentView;
import com.xmlmind.xmledit.cmd.RecordableCommand;
import com.xmlmind.xmledit.edit.MarkManager;

public class ProduceEpubFromXhtml extends RecordableCommand {
	final String kContainerXml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
			+ "<container xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\" version=\"1.0\">\n"
			+ "  <rootfiles>\n"
			+ "      <rootfile full-path=\"OEBPS/content.opf\"\n"
			+ "                media-type=\"application/oebps-package+xml\"/>\n"
			+ "   </rootfiles>\n"
			+ "</container>\n";
	final String kNormal = "normal";
	Path pOebpsPath;
	Path pOebpsFontsPath;
	Path pOebpsImagesPath;
	Path pOebpsStylesPath;
	Path pOebpsTextPath;
	Document document;
	XPath xPath;
	String sCssContent = "";

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
			createFontFiles(docView);
			createImageFiles(docView, fHtmFile);
			createTextFile(parameter);

			return "success";

		} catch (Exception e) {
			return reportException(docView, e);
		}
	}

	protected void createFontFiles(DocumentView docView) throws NoSuchFieldException,
			IllegalAccessException, IOException {
		HashSet<String> fontFiles = collectFontFilesFromCss(docView, sCssContent);
		collectFontFilesFromHtm(docView, fontFiles);
		for (String ff : fontFiles) {
			Path pSrc = Paths.get(ff);
			int iLastSeparator = ff.lastIndexOf(File.separator);
			String sFileName = ff.substring(iLastSeparator + 1);
			Path pImage = Paths.get(pOebpsFontsPath.toString() + File.separator + sFileName);
			Files.copy(pSrc, pImage, StandardCopyOption.REPLACE_EXISTING);
		}
	}

	protected void collectFontFilesFromHtm(DocumentView docView, HashSet<String> fontFiles)
			throws NoSuchFieldException, IllegalAccessException {
		try {
			final String kFontStyle = "font-style";
			final String kFontWeight = "font-weight";
			NodeList fontFamilies = (NodeList) xPath.compile("@font-family").evaluate(document, XPathConstants.NODESET);
			for (int i = 0; i < fontFamilies.getLength(); i++) {
				Node fontFamily = fontFamilies.item(i);
				String sFontFamilyName = fontFamily.getNodeValue();
				String sStyle = kNormal;
				String sWeight = kNormal;
				boolean fStyleFound = false;
				boolean fWeightFound = false;
				// find last style and weight sibling
				Node sibling = fontFamily.getNextSibling();
				while (sibling != null) {
					if (sibling.getLocalName().equals(kFontStyle)) {
						sStyle = sibling.getNodeValue();
						fStyleFound = true;
					}
					if (sibling.getLocalName().equals(kFontWeight)) {
						sWeight = sibling.getNodeValue();
						fWeightFound = true;
					}
					sibling = sibling.getNextSibling();
				}
				// if did not find any following style sibling, get first preceding style sibling
				if (!fStyleFound) {
					sibling = fontFamily.getPreviousSibling();
					while (sibling != null) {
						if (sibling.getLocalName().equals(kFontStyle)) {
							sStyle = sibling.getNodeValue();
							break;
						}
						sibling = sibling.getPreviousSibling();
					}
				}
				// if did not find any following weight sibling, get first preceding weight sibling
				if (!fWeightFound) {
					sibling = fontFamily.getPreviousSibling();
					while (sibling != null) {
						if (sibling.getLocalName().equals(kFontWeight)) {
							sWeight = sibling.getNodeValue();
							break;
						}
						sibling = sibling.getPreviousSibling();
					}
				}
				Font font = createFont(sFontFamilyName, sStyle, sWeight);
				String sFontPath = findFontFilePath(docView, font);
				fontFiles.add(sFontPath);
			}
		} catch (XPathExpressionException e) {
			reportException(docView, e);
		}
	}

	protected HashSet<String> collectFontFilesFromCss(DocumentView docView, String sHere)
			throws NoSuchFieldException, IllegalAccessException {
		HashSet<String> fontFiles = new HashSet<String>();
		final String kFontFamily = "font-family:";
		final String kFontStyle = "font-style:";
		final String kFontWeight = "font-weight:";
		int index = sHere.indexOf(kFontFamily);
		while (index > -1) {
			index += kFontFamily.length();
			sHere = sHere.substring(index);
//			Alert.showError(docView.getPanel(), "sHere = '" + sHere + "'");
			int indexEOL = sHere.indexOf(";");
//			Alert.showError(docView.getPanel(), "indexEOL = '" + indexEOL + "'");
			if (indexEOL > -1) {
				String sFontFamilyName = sHere.substring(0, indexEOL).trim();
//					Alert.showError(docView.getPanel(), "sFontFamilyName = '" + sFontFamilyName + "'");
				sFontFamilyName = sFontFamilyName.replaceAll("\"", "");
//				Alert.showError(docView.getPanel(), "sFontFamilyName = '" + sFontFamilyName + "'");
				int indexEndOfDefinition = sHere.indexOf("}");
				String sRestOfDefinition = sHere.substring(indexEOL + 1, indexEndOfDefinition);
				String sStyle = kNormal;
//				Alert.showError(docView.getPanel(), "sRestOfDefiniton = '" + sRestOfDefinition + "'");
				int indexStyle = sRestOfDefinition.indexOf(kFontStyle);
				if (indexStyle > -1) {
					indexStyle += kFontStyle.length();
					sRestOfDefinition = sRestOfDefinition.substring(indexStyle);
					int indexStyleEOL = sRestOfDefinition.indexOf(";");
//					Alert.showError(docView.getPanel(), "indexStyle = " + indexStyle + "; indexStyleEOL = " + indexStyleEOL);
					sStyle = sRestOfDefinition.substring(0, indexStyleEOL).trim();
//					Alert.showError(docView.getPanel(), "sStyle = '" + sStyle + "'");
					sRestOfDefinition = sRestOfDefinition.substring(indexStyleEOL + 1);
				}
				String sWeight = kNormal;
				int indexWeight = sRestOfDefinition.indexOf(kFontWeight);
				if (indexWeight > -1) {
					indexWeight += kFontWeight.length();
					sRestOfDefinition = sRestOfDefinition.substring(indexWeight);
					int indexWeightEOL = sRestOfDefinition.indexOf(";");
					sWeight = sRestOfDefinition.substring(0, indexWeightEOL).trim();
//					Alert.showError(docView.getPanel(), "sWeight = '" + sWeight + "'");
				}
				Font font = createFont(sFontFamilyName, sStyle, sWeight);
				String sFontPath = findFontFilePath(docView, font);
				fontFiles.add(sFontPath);
//				Alert.showError(docView.getPanel(), "font path ='" + sFontPath + "'");
			}
			index = sHere.indexOf(kFontFamily);
		}
		return fontFiles;
	}

	protected Font createFont(String sFontFamilyName, String sStyle, String sWeight) {
		int iStyleWeight = Font.PLAIN;
		if (sStyle.equals("italic")) {
			iStyleWeight += Font.ITALIC;
		}
		if (sWeight.equals("bold")) {
			iStyleWeight += Font.BOLD;
		}
//				Alert.showError(docView.getPanel(), "sFontFamilyName = '" + sFontFamilyName + "'; iStyleWeight = " + iStyleWeight);
		Font font = new Font(sFontFamilyName, iStyleWeight, 10);
		return font;
	}

	protected String findFontFilePath(DocumentView docView, Font font) throws NoSuchFieldException,
			IllegalAccessException {
		// Following is from https://stackoverflow.com/questions/2019249/get-font-file-as-a-file-object-or-get-its-path
		// Note that this uses sun.font which may go away in a later version of Java.
		// use reflection on Font2D (<B>PhysicalFont.platName</B>) e.g.
//		Alert.showError(docView.getPanel(), "findFontFilePath: font = '" + font.getFontName() + "'");

		Font2D f2d = sun.font.FontUtilities.getFont2D(font);
		Field platName = PhysicalFont.class.getDeclaredField("platName");
		platName.setAccessible(true);
		String fontPath = (String)platName.get(f2d);
		platName.setAccessible(false);
		return fontPath;
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
		// Get and keep CSS content for processing later
		sCssContent = new String(Files.readAllBytes(fCssFile.toPath()), StandardCharsets.UTF_8);
		try {
			Node styleSheetLink = (Node) xPath.compile("/html/head/link[@rel=\"stylesheet\"]").evaluate(document, XPathConstants.NODE);
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
