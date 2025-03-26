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
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
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
import com.xmlmind.xml.xpath.EvalException;
import com.xmlmind.xml.xpath.ParseException;
import com.xmlmind.xml.xpath.XPathUtil;
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
	Document htmDoc;
	XPath xPath;
	String sAuthor = "";
	String sDocTitle = "";
	String sDocSubtitle = "";
	String sHtmFileName = "";
	String sCssContent = "";
	String sCoverJpg = "";
	String sGuid = "";
	com.xmlmind.xml.doc.Document xmlDoc;
	HashSet<String> fontFiles;
	List<String> imageFiles = new ArrayList<String>();

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
			String[] asFilenames = parameter.split("'\\|'");
			if (asFilenames.length < 2) {
				Alert.showError(docView.getPanel(),
						"ProduceEpubFromXhtml: parameter needs at least two lines.");
			}
			// A File object to represent the filename
			String sParameterFileName = asFilenames[0].trim();
			File fHtmFile = new File(sParameterFileName);

			// Cover.jpg for cover
			sCoverJpg = asFilenames[1].trim();

			// Make sure the file or directory exists and isn't write protected
			if (!fHtmFile.exists()) {
				return setMessage("FileNotThere");
			}
			// If it is a directory, make sure it is empty
			if (fHtmFile.isDirectory()) {
				return setMessage("FileIsADirectory");
			}
			xmlDoc = docView.getDocument();
			sDocTitle = XPathUtil.evalAsString("//frontMatter/title", xmlDoc);
			sGuid = UUID.randomUUID().toString();

			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = factory.newDocumentBuilder();
			htmDoc = builder.parse(fHtmFile);
			xPath = XPathFactory.newInstance().newXPath();

			createDirectoryStructure();
			createMimetypeFile();
			createCssFiles(docView, sParameterFileName);
			createFontFiles(docView);
			createImageFiles(docView, fHtmFile);
			createTextFiles(sParameterFileName);
			createTocNcxFile(docView);
			createContentOpfFile(docView);

			return "success";

		} catch (Exception e) {
			return reportException(docView, e);
		}
	}

	protected void createContentOpfFile(DocumentView docView) {
		// TODO: Removed these two lines after <?xml...:
		// <!--file:///D%3A%2FAll-SIL-Publishing%2F_xrunner2_projects%2F_GPS%2FGPS-ES%2FEXGSUM64JN1-ver2%2Foutput%2FJohn_1-9%2FOEBPS%2FText%2Fcover.xhtml-->
		//	<!--relative%2Fpath%2Ffile.ext-->
		// Why are they there?  What good do they do for the final product?
		// Do we need the Calibre metadata when we're not using Calibre?
		// What about the isbn items?
		StringBuilder sb = new StringBuilder();
		createContentOpfPreamble(sb);
		createContentOpfManifest(sb);
		createContentOpfSpine(sb);
		createContentOpfGuide(sb);
		sb.append("</package>\n");
		try {
			Path contentOpfPath = Paths.get(pOebpsPath.toString() + File.separator + "content.opf");
			Files.write(contentOpfPath, sb.toString().getBytes(), StandardOpenOption.CREATE);
		} catch (IOException e) {
			reportException(docView, e);
		}

	}

	protected void createContentOpfGuide(StringBuilder sb) {
		sb.append("   <guide>\n");
		
		sb.append("   </guide>\n");
	}

	protected void createContentOpfSpine(StringBuilder sb) {
		sb.append("   <spine>\n");
		
		sb.append("   </spine>\n");
	}

	protected void createContentOpfManifest(StringBuilder sb) {
		sb.append("   <manifest>\n");
		createContentOpfCssStyles(sb);
		createContentOpfTexts(sb);
		createContentOpfFonts(sb);
		createContentOpfImages(sb);

		sb.append("      <item id=\"ncx\" href=\"toc.ncx\" media-type=\"application/x-dtbncx+xml\"/>\n");
		sb.append("   </manifest>\n");
	}

	protected void createContentOpfImages(StringBuilder sb) {
		for (String sImage : imageFiles) {
			createContentOpfImage(sb, sImage, "");
		}
		createContentOpfImage(sb, "Cover.jpg", "cover-image");
	}

	protected void createContentOpfImage(StringBuilder sb, String sImageFile, String sProperties) {
		final String kImage1 = "      <item id=\"";
		final String kImage2 = "\" href=\"Images/";
		final String kImage3 = "\" media-type=\"image/";
		final String kImage4 = "\" properties=\"";
		sb.append(kImage1);
		sb.append(sImageFile);
		sb.append(kImage2);
		sb.append(sImageFile);
		sb.append(kImage3);
		int iPeriod = sImageFile.lastIndexOf(".");
		String sType = sImageFile.substring(iPeriod +1);
		sb.append(sType.toLowerCase());
		if (sProperties.length() > 0) {
			sb.append(kImage4);
			sb.append(sProperties);
		}
		sb.append("\"/>\n");
	}

	protected void createContentOpfFonts(StringBuilder sb) {
		for (String ff : fontFiles) {
			int iLastSeparator = ff.lastIndexOf(File.separator);
			String sFileName = ff.substring(iLastSeparator + 1);
			createContentOpfFont(sb, sFileName);
		}
	}

	protected void createContentOpfFont(StringBuilder sb, String sFontFile) {
		final String kFont1 = "      <item id=\"";
		final String kFont2 = "\" href=\"Fonts/";
		final String kFont3 = "\" media-type=\"font/";
		sb.append(kFont1);
		sb.append(sFontFile);
		sb.append(kFont2);
		sb.append(sFontFile);
		sb.append(kFont3);
		int iPeriod = sFontFile.lastIndexOf(".");
		String sType = sFontFile.substring(iPeriod +1);
		sb.append(sType.toLowerCase());
		sb.append("\"/>\n");
	}

	protected void createContentOpfTexts(StringBuilder sb) {
		createContentOpfText(sb, "coverText", "cover.xhtml", "svg");
		createContentOpfText(sb, "titlepageText", "titlepage.xhtml", "");
		createContentOpfText(sb, "thedocumentText", sHtmFileName, "");
	}

	protected void createContentOpfText(StringBuilder sb, String sId, String sTextFile, String sProperties) {
		final String kText1 = "      <item id=\"";
		final String kText2 = "\" href=\"Text/";
		final String kText3 = "\" media-type=\"application/xhtml+xml\"";
		final String kText4 = " properties=\"";
		sb.append(kText1);
		sb.append(sId);
		sb.append(kText2);
		sb.append(sTextFile);
		sb.append(kText3);
		if (sProperties.length() > 0) {
			sb.append(kText4);
			sb.append(sProperties);
			sb.append("\"");
		}
		sb.append("/>\n");
	}

	protected void createContentOpfCssStyles(StringBuilder sb) {
		createContentOpfCssStyle(sb, "coverCss", "cover.css");
		createContentOpfCssStyle(sb, "stylesheetCss", "stylesheet.css");
	}

	protected void createContentOpfCssStyle(StringBuilder sb, String sId, String sCssFile) {
		final String kCss1 = "      <item id=\"";
		final String kCss2 = "\" href=\"Styles/";
		final String kCss3 = "\" media-type=\"text/css\"/>\n";
		sb.append(kCss1);
		sb.append(sId);
		sb.append(kCss2);
		sb.append(sCssFile);
		sb.append(kCss3);
	}

	protected void createContentOpfPreamble(StringBuilder sb) {
		final String kPreamble1 = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
				+ "<package xmlns=\"http://www.idpf.org/2007/opf\"\n"
				+ "         version=\"3.0\"\n"
				+ "         unique-identifier=\"isbn\"\n"
				+ "         xml:lang=\"en\">\n"
				+ "   <metadata xmlns:calibre=\"https://calibre-ebook.com/\"\n"
				+ "             xmlns:dc=\"http://purl.org/dc/elements/1.1/\"\n"
				+ "             xmlns:dcterms=\"http://purl.org/dc/terms/\"\n"
				+ "             xmlns:opf=\"http://www.idpf.org/2007/opf\">\n"
				+ "      <dc:identifier id=\"isbn\">isbn:???1</dc:identifier>\n"
				+ "      <dc:identifier id=\"isbn2\">???1</dc:identifier>\n"
				+ "      <meta refines=\"#isbn2\" property=\"identifier-type\" scheme=\"onix:codelist5\">15</meta>\n"
				+ "      <dc:source id=\"isbn-pbk\">urn:isbn:???2</dc:source>\n"
				+ "      <meta refines=\"#isbn-pbk\" property=\"dcterms:format\">paperback</meta>\n"
				+ "      <dc:language>en</dc:language>\n"
				+ "      <dc:title>";
		final String kPreamble2 = "</dc:title>\n"
				+ "      <dc:source id=\"pg-src\">???2</dc:source>\n"
				+ "      <dc:subject>";
		// TODO: How does the creator and it id work with multiple authors here and in kPreamble4 and 5?
		final String kPreamble3 = "</dc:subject>\n"
				+ "      <dc:creator id=\"id-1\">";
		final String kPreamble4 = "</dc:creator>\n"
				+ "      <meta property=\"file-as\" refines=\"#id-1\">";
		final String kPreamble5 = "</meta>\n"
				+ "      <meta property=\"role\" refines=\"#id-1\" scheme=\"marc:relators\">aut</meta>\n"
				+ "      <dc:date>";
		final String kPreamble6 = "</dc:date>\n"
				+ "      <meta property=\"dcterms:modified\">";
		final String kPreamble7 = "</meta>\n"
				+ "      <meta property=\"a11y:certifiedBy\">???</meta>\n"
				+ "      <meta property=\"dcterms:conformsTo\" id=\"conf\">EPUB Accessibility 1.1 - WCAG 2.2 Level AAA</meta>\n"
				+ "      <dc:description>";
		final String kPreamble8 = "</dc:description>\n"
				+ "      <dc:rights>All rights reserved  |  No part of this publication may be reproduced, stored in a retrieval system, or transmitted in any form or by any means electronic, mechanical, photocopy, recording, or otherwise without the express permission of SIL International. However, short passages, generally understood to be within the limits of fair use, may be quoted without written permission.</dc:rights>\n"
				+ "      <dc:title id=\"title\">";
		final String kPreamble9 = "</dc:title>\n";
		final String kSubtitle1 = "      <meta property=\"file-as\" refines=\"#title\">";
		final String kSubtitle2 = "</meta>\n";
		final String kPreamble10 = "      <meta property=\"title-type\" refines=\"#title\">main</meta>\n"
				+ "      <meta property=\"schema:accessMode\">textual</meta>\n"
				+ "      <meta property=\"schema:accessModeSufficient\">textual</meta>\n"
				+ "      <meta property=\"schema:accessibilityFeature\">structuralNavigation</meta>\n"
				+ "      <meta property=\"schema:accessibilityAPI\">ARIA</meta>\n"
				+ "      <meta property=\"schema:accessibilityFeature\">displayTransformability</meta>\n"
				+ "      <meta property=\"schema:accessibilityFeature\">readingOrder</meta>\n"
				+ "      <meta property=\"schema:accessibilityFeature\">tableOfContents</meta>\n"
				+ "      <meta property=\"schema:accessibilityHazard\">noMotionSimulationHazard</meta>\n"
				+ "      <meta property=\"schema:accessibilityHazard\">noFlashingHazard</meta>\n"
				+ "      <meta property=\"schema:accessibilityHazard\">noSoundHazard</meta>\n"
				+ "      <meta property=\"schema:accessibilitySummary\">In addition to meeting accessibility standards.</meta>\n"
				+ "      <meta name=\"schema:accessibilitySummary\"\n"
				+ "            content=\"This publication meets the EPUB Accessibility requirements and it also meets the Web Content Accessibility Guidelines (WCAG) at the double AA level. This book contains various accessibility features such as table of content, reading order and semantic structure.\"/>\n"
				+ "      <meta name=\"SIL XLingPaper\" content=\"3.16.5\"/>\n"
				+ "   </metadata>\n";
		sb.append(kPreamble1);
		sb.append(sDocTitle);
		sb.append(kPreamble2);
		sb.append("keywords go here");
		sb.append(kPreamble3);
		sb.append(sAuthor);
		sb.append(kPreamble4);
		sb.append(sAuthor);
		String sIso8601Stamp = getISO8601DateTimeStamp(); 
		sb.append(kPreamble5);
		sb.append(sIso8601Stamp);
		sb.append(kPreamble6);
		sb.append(sIso8601Stamp);
		sb.append(kPreamble7);
		sb.append("description goes here; maybee use the content of the abstract?");
		sb.append(kPreamble8);
		sb.append(sDocTitle);
		sb.append(kPreamble9);
		if (sDocSubtitle.length() > 0) {
			sb.append(kSubtitle1);
			sb.append(sDocSubtitle);
			sb.append(kSubtitle2);
		}
		sb.append(kPreamble10);
	}

	protected String getISO8601DateTimeStamp() {
		LocalDateTime localDateTime = LocalDateTime.now();
//		LocalDate localDate = 
		final DateTimeFormatter PARSER = DateTimeFormatter.ofPattern("uuuu-MM-dd HH:mm:ss", Locale.ROOT);
		String formattedDate = localDateTime.atOffset(ZoneOffset.UTC).format(PARSER); 
//		ZoneId zone = ZoneId.of("America/Chicago");
//	    
//	    String dateString = "2021-09-27 16:32:36";
//	    
//	    ZonedDateTime dateTime = LocalDateTime.parse(dateString, PARSER).atZone(zone);
//	    String isoZuluString = dateTime.withZoneSameInstant(ZoneOffset.UTC).toString();
		return formattedDate;
	}

	protected void createTocNcxFile(DocumentView docView) throws ParseException, EvalException {
		StringBuilder sb = new StringBuilder();
		sb = createTocNcxPreamble(sb);
		sb.append("<navMap>\n");
		int iNavPoint = 1;
		sb.append(createTocNcxNavPoint(iNavPoint++, "Cover", "Text/cover.xhtml"));
		sb.append(createTocNcxNavPoint(iNavPoint++, "Title Page", "Text/titlepage.xhtml"));
		sb.append(createTocNcxNavPoint(iNavPoint++, "Contents", "Text/" + sHtmFileName + "/#rXLingPapContents"));
		try {
			NodeList contents = (NodeList) xPath.compile("//div[contains(@id,'rXLingPapContents')]").evaluate(htmDoc, XPathConstants.NODESET);
			Node tocDivs = contents.item(0);
			Node tocDivsNext = tocDivs.getNextSibling();
			NodeList tocItems0 = tocDivsNext.getChildNodes();
			for (int i0 = 0; i0 < tocItems0.getLength(); i0++) {
				Node div0 = tocItems0.item(i0);
				Node a0 = div0.getChildNodes().item(0);
				// need to replace non-breaking spaces with regular spaces
				String sContent0 = a0.getTextContent().replace("\u00a0", " ").trim();
				String sId0 = a0.getAttributes().getNamedItem("href").getNodeValue();
				sb.append(createTocNcxNavPoint(iNavPoint++, sContent0, "Text/" + sHtmFileName + "/" + sId0));
				// TODO: repeat up to the proper level or until there are no nested items
			}
		} catch (XPathExpressionException e1) {
			reportException(docView, e1);
		}
		sb.append("</navMap>\n</ncx>\n");
		try {
			Path tocNcxPath = Paths.get(pOebpsPath.toString() + File.separator + "toc.ncx");
			Files.write(tocNcxPath, sb.toString().getBytes(), StandardOpenOption.CREATE);
		} catch (IOException e) {
			reportException(docView, e);
		}
	}

	protected String createTocNcxNavPoint(int id, String sText, String sSrc) {
		StringBuilder sb = new StringBuilder();
		sb.append("<navPoint id=\"navPoint");
		sb.append(id);
		sb.append("\">\n");
		sb.append("<navLabel>\n");
		sb.append("<text>");
		sb.append(sText);
		sb.append("</text>\n");
		sb.append("</navLabel>\n");
		sb.append("<content src=\"");
		sb.append(sSrc);
		sb.append("\"/>\n");
		sb.append("</navPoint>\n");
		return sb.toString();
	}
	protected StringBuilder createTocNcxPreamble(StringBuilder sb) throws ParseException, EvalException {
		final String sPreamble1 = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
				+ "<ncx xmlns=\"http://www.daisy.org/z3986/2005/ncx/\" version=\"2005-1\">\n"
				+ "   <head>\n"
				+ "      <meta name=\"dtb:uid\" content=\"";
		final String sPreamble2 = "\"/>\n"
				+ "      <meta name=\"dtb:depth\" content=\"";
		final String sPreamble3 = "\"/>\n"
				+ "      <meta name=\"dtb:totalPageCount\" content=\"0\"/>\n"
				+ "      <meta name=\"dtb:maxPageNumber\" content=\"0\"/>\n"
				+ "   </head>\n";
		String sContentLevel = XPathUtil.evalAsString("//frontMatter/contents/@showLevel", xmlDoc);
		if (sContentLevel.equals("")) {
			sContentLevel = "3";
		}
		sb.append(sPreamble1);
		sb.append(sGuid);
		sb.append(sPreamble2);
		sb.append(sContentLevel);
		sb.append(sPreamble3);
		sb.append("<docTitle>\n<text>");
		sAuthor = XPathUtil.evalAsString("//frontMatter/author", xmlDoc);
		sb.append(sAuthor);
		sb.append("</text>\n</docTitle>\n");
		return sb;
	}

	protected void createFontFiles(DocumentView docView) throws NoSuchFieldException,
			IllegalAccessException, IOException {
		fontFiles = collectFontFilesFromCss(docView, sCssContent);
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
			NodeList fontFamilies = (NodeList) xPath.compile("@font-family").evaluate(htmDoc, XPathConstants.NODESET);
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

	protected void createTextFiles(String parameter) throws FileNotFoundException, IOException {
		createHtmFile(parameter);
		createCoverXhtmlFile();
		createTitlePageXhtmlFile();
	}

	protected void createHtmFile(String parameter) throws FileNotFoundException, IOException {
		String sHtmFile = parameter.trim();
		String sHtmContent = documentToString(htmDoc);
		int iSeparator = sHtmFile.lastIndexOf(File.separator) + 1;
		sHtmFileName = sHtmFile.substring(iSeparator);
		String sFileInOepbs = pOebpsTextPath.toString() + File.separator + sHtmFileName;
		writeContentToFile(sHtmContent, sFileInOepbs);
	}

	protected void createTitlePageXhtmlFile() throws FileNotFoundException, IOException {
		// TODO: will need to set the language to es or fr sometimes...
		final String kTitlePage1 = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
				+ "<!DOCTYPE html><html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:epub=\"http://www.idpf.org/2007/ops\" lang=\"en\" xml:lang=\"en\">\n"
				+ "   <head>\n"
				+ "      <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n"
				+ "      <title>Title Page</title>\n"
				+ "      <link href=\"../Styles/stylesheet.css\" type=\"text/css\" rel=\"stylesheet\" />\n"
				+ "   </head>\n" + "   <body>\n" + "      <section id=\"titlepage\">\n";
		final String kTitlePage2 = "      </section>\n"
				+ "  </body>\n"
				+ "</html>\n";
		StringBuilder sb = new StringBuilder();
		// TODO: figure out how to get the order right for all possibilities of
		// title, subtitle, authors, etc.
		// Can we use what's in the htm file?
		sb.append(kTitlePage1);
		sb.append("<p class=\"title\">");
		sb.append(sDocTitle);
		sb.append("</p>\n");
		sb.append("<p class=\"author\">");
		sb.append(sDocTitle);
		sb.append("</p>\n");
		sb.append(kTitlePage2);
		writeContentToFile(sb.toString(), pOebpsTextPath.toString() + File.separator
				+ "titlepage.xhtml");
	}

	protected void createCoverXhtmlFile() throws FileNotFoundException, IOException {
		// XHTML (mostly) taken with gratitude from https://electricbookworks.github.io/ebw-training/making-ebooks/text/7-covers.html
		// on 2025.03.25
		final String sCoverXhtml1 = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
				+ "<!DOCTYPE html\n"
				+ "  PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"
				+ "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n"
				+ "<head>\n"
				+ "	<title>Cover</title>\n"
				+ "	<link rel=\"stylesheet\" type=\"text/css\" href=\"../Styles/cover.css\" />\n"
				+ "</head>\n"
				+ "<body class=\"cover\">\n"
				+ "	<div class=\"cover\">\n"
				+ "		<img class=\"cover\" alt=\"Cover\" src=\"../Images/cover.jpg\" />\n"
				+ "   <div class=\"centered\">";
		final String sCoverXhtml2 = "</div>\n"
				+ "	</div>\n"
				+ "</body>\n"
				+ "</html>\n";
		String sCoverXhtml = sCoverXhtml1 + sDocTitle + sCoverXhtml2;
		writeContentToFile(sCoverXhtml, pOebpsTextPath.toString() + File.separator + "cover.xhtml");
	}

	protected void writeContentToFile(String sHtmContent, String sFileInOepbs)
			throws FileNotFoundException, IOException {
		OutputStreamWriter htmWriter =
		         new OutputStreamWriter(new FileOutputStream(sFileInOepbs), StandardCharsets.UTF_8);
		htmWriter.write(sHtmContent);
		htmWriter.close();
	}

	protected void createImageFiles(DocumentView docView, File fHtmFile) {
		NodeList graphics;
		try {
			graphics = (NodeList) xPath.compile("//img | //embed").evaluate(htmDoc, XPathConstants.NODESET);
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
			imageFiles.add("image" + iImageCount + sExtension);
			Node newSrc = node.getAttributes().getNamedItem("src");
//			Alert.showError(docView.getPanel(), "new src ='" + newSrc.getNodeValue() + "'");
//			src.setTextContent("../Images/" + sFileName);
		} else {
			int iLastSeparator = sSrc.lastIndexOf(File.separator);
//			Alert.showError(docView.getPanel(), "iLastSeparator =" + iLastSeparator);
			String sFileName = sSrc.substring(iLastSeparator + 1);
			imageFiles.add(sFileName);
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

	protected void createCssFiles(DocumentView docView, String parameter) throws IOException {
		final String kStyleSheetName = "stylesheet.css";
		String sCssFile = parameter.trim();
		int extensionIndex = sCssFile.lastIndexOf(".");
		sCssFile = sCssFile.substring(0, extensionIndex) + ".css";
		File fCssFile = new File(sCssFile);
		Path pCss = Paths.get(pOebpsStylesPath.toString() + File.separator + kStyleSheetName);
		Files.copy(fCssFile.toPath(), pCss, StandardCopyOption.REPLACE_EXISTING);
		createCoverCss(docView);
		Path pImage = Paths.get(pOebpsImagesPath.toString() + File.separator + "Cover.jpg");
		Files.copy(Paths.get(sCoverJpg), pImage, StandardCopyOption.REPLACE_EXISTING);
		// Get and keep CSS content for font file processing later
		sCssContent = new String(Files.readAllBytes(fCssFile.toPath()), StandardCharsets.UTF_8);
		try {
			Node styleSheetLink = (Node) xPath.compile("/html/head/link[@rel=\"stylesheet\"]").evaluate(htmDoc, XPathConstants.NODE);
			Node href = styleSheetLink.getAttributes().getNamedItem("href");
			href.setNodeValue("../Styles/" + kStyleSheetName);
		} catch (XPathExpressionException e) {
			reportException(docView, e);
		}
	}

	protected void createCoverCss(DocumentView docView) {
		try {
			// CSS taken with gratitude from https://electricbookworks.github.io/ebw-training/making-ebooks/text/7-covers.html
			// on 2025.03.25
			final String kCoverCss = "/* Styles for cover.xhtml */\n"
					+ "body.cover {\n"
					+ "	margin: 0;\n"
					+ "	padding: 0;\n"
					+ "	text-align: center;\n"
					+ "}\n"
					+ "p.cover {\n"
					+ "	margin: 0;\n"
					+ "	padding: 0;\n"
					+ "	text-align: center;\n"
					+ "}\n"
					+ "img.cover {\n"
					+ "	height: 100%;\n"
					+ "	margin: 0;\n"
					+ "	padding: 0;\n"
					+ "}\n"
					+ ".centered {\n"
					+ "  position: absolute;\n"
					+ "  top: 25%;\n"
					+ "  left: 50%;\n"
					+ "  font-size:300%;\n"
					+ "  transform: translate(-50%, -50%);\n"
					+ "}\n";
			Path coverCssPath = Paths.get(pOebpsStylesPath.toString() + File.separator + "cover.css");
			Files.write(coverCssPath, kCoverCss.getBytes(), StandardOpenOption.CREATE);
		} catch (IOException e) {
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
