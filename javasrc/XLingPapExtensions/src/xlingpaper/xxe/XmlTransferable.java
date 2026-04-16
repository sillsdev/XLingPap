package xlingpaper.xxe;
import java.awt.datatransfer.*;

public class XmlTransferable implements Transferable {

    private final String xmlData;
    private final DataFlavor[] supportedFlavors;

    public XmlTransferable(String xmlData) {
        this.xmlData = xmlData;
        
        // Define the flavors exactly as the source app did
        this.supportedFlavors = new DataFlavor[] {
            new DataFlavor("application/x-xe-eraax+xml; class=java.lang.String", "application/x-xe-eraax+xml"),
            new DataFlavor("application/xml; class=java.lang.String", "application/xml"),
            new DataFlavor("text/xml; class=java.lang.String", "text/xml")
        };
    }

    @Override
    public DataFlavor[] getTransferDataFlavors() {
        return supportedFlavors;
    }

    @Override
    public boolean isDataFlavorSupported(DataFlavor flavor) {
        for (DataFlavor f : supportedFlavors) {
            if (f.equals(flavor)) return true;
        }
        return false;
    }

    @Override
    public Object getTransferData(DataFlavor flavor) throws UnsupportedFlavorException {
        if (isDataFlavorSupported(flavor)) {
            return xmlData;
        }
        throw new UnsupportedFlavorException(flavor);
    }
}
