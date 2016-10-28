package xlingpaper.xxe;

import java.awt.Font;
import java.text.AttributedCharacterIterator.Attribute;
import java.util.Map;
import xlingpaper.xxe.*;

public class XLingPaperFontInfo extends Font {
    Boolean isPlain;
    Boolean useStyleDefault;
    Boolean isItalic;
    Boolean useWeightDefault;
    Boolean isBold;
    Boolean useSizeDefault;
    Boolean useFamilyDefault;
    Boolean usePoints;
    String sFontSize;
    String sFontFamily;
    int fontStyleToShow;
    int fontSizeToShow;
    

    public XLingPaperFontInfo(String name, int style, int size) {
	super(name, style, size);
	usePoints = true;
	useSizeDefault = false;
	useStyleDefault = false;
	fontStyleToShow = style;
	fontSizeToShow = size;
    }

    public int getFontStyleToShow() {
	return fontStyleToShow;
    }
    public void setFontStyleToShow(int value) {
	fontStyleToShow= value;
    }
    public int getFontSizeToShow() {
	return fontSizeToShow;
    }
    public void setFontSizeToShow(int value) {
	fontSizeToShow= value;
    }
    public String getFontFamily() {
	return sFontFamily;
    }
    public void setFontFamily(String value) {
	sFontFamily = value;
    }
    public String getFontSize() {
	return sFontSize;
    }
    public void setFontSize(String value) {
	sFontSize = value;
    }
    public Boolean getStyleBold() {
	return isBold;
    }
    public void setStyleBold(Boolean value) {
	isBold = value;
    }
    public Boolean getStyleItalic() {
	return isItalic;
    }
    public void setStyleItalic(Boolean value) {
	isItalic = value;
    }
    public Boolean getStylePlain() {
	return isPlain;
    }
    public void setStylePlain(Boolean value) {
	isPlain = value;
    }
    public Boolean getUsePoints() {
	return usePoints;
    }
    public void setUsePoints(Boolean value) {
	usePoints = value;
    }
    public Boolean getUsePercentage() {
	return !usePoints;
    }
    public void setUsePercentage(Boolean value) {
	usePoints = !value;
    }
    public Boolean getUseSizeDefault() {
	return useSizeDefault;
    }
    public void setUseSizeDefault(Boolean value) {
	useSizeDefault = value;
    }
    public Boolean getUseStyleDefault() {
	return useStyleDefault;
    }
    public void setUseStyleDefault(Boolean value) {
	useStyleDefault = value;
    }
    public Boolean getUseWeightDefault() {
	return useWeightDefault;
    }
    public void setUseWeightDefault(Boolean value) {
	useWeightDefault = value;
    }
    public Boolean getUseFamilyDefault() {
	return useFamilyDefault;
    }
    public void setUseFamilyDefault(Boolean value) {
	useFamilyDefault = value;
    }
    /**
     * 
     */
    private static final long serialVersionUID = 7962328756677635002L;


}
