package xlingpaper.xxe;

import java.awt.Container;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;

import javax.swing.*;
import javax.swing.border.Border;
import javax.swing.border.EmptyBorder;

public class XLingPaperSetTableSizeDialog extends javax.swing.JDialog {
    /**
     * 
     */
    private int iHeaderRows = 0;
    private int iNonHeaderRows = 2;
    private int iColumns = 2;

    private static final long serialVersionUID = 120110809L;
    /** A return status code - returned if Cancel button has been pressed */
    public static final int RET_CANCEL = 0;
    /** A return status code - returned if OK button has been pressed */
    public static final int RET_OK = 1;

    // Constructors
    public XLingPaperSetTableSizeDialog(java.awt.Frame parent) {
	super(parent);
	initComponents();
    }

    public XLingPaperSetTableSizeDialog() {
	super((javax.swing.JFrame) null);
	initComponents();
    }

    public void setIHeaderRows(int iHeaderRows) {
	this.iHeaderRows = iHeaderRows;
	headerRowsModel.setValue(iHeaderRows);
    }

    public int getIHeaderRows() {
	return iHeaderRows;
    }

    public void setINonHeaderRows(int iNonHeaderRows) {
	this.iNonHeaderRows = iNonHeaderRows;
	nonHeaderRowsModel.setValue(iNonHeaderRows);
    }

    public int getINonHeaderRows() {
	return iNonHeaderRows;
    }

    public void setIColumns(int iColumns) {
	this.iColumns = iColumns;
	columnsModel.setValue(iColumns);
    }

    public int getIColumns() {
	return iColumns;
    }

    private void initComponents() {
	final LocalizeString ls = new LocalizeString();
	ls.prepare(null, null, 0, 0);

	tableSizePanel = new javax.swing.JPanel();
	buttonPanel = new javax.swing.JPanel();
	okButton = new javax.swing.JButton();
	cancelButton = new javax.swing.JButton();

	String sHeaderRows = (String) ls.doExecute(null, "java.setTableSizeDialogHeaderRows", 0, 0);
	headerRowsModel = new SpinnerNumberModel(iHeaderRows, // initial value
		0, // minimum
		100, // max
		1); // step
	JSpinner spinner = addLabeledSpinner(tableSizePanel, sHeaderRows, headerRowsModel);

	String sNonHeaderRows = (String) ls.doExecute(null, "java.setTableSizeDialogNonHeaderRows",
		0, 0);
	nonHeaderRowsModel = new SpinnerNumberModel(iNonHeaderRows, // initial
		// value
		0, // minimum
		10000, // max
		1); // step
	spinner = addLabeledSpinner(tableSizePanel, sNonHeaderRows, nonHeaderRowsModel);

	String sColumns = (String) ls.doExecute(null, "java.setTableSizeDialogColumns", 0, 0);
	columnsModel = new SpinnerNumberModel(iColumns, // initial value
		0, // minimum
		100, // max
		1); // step
	spinner = addLabeledSpinner(tableSizePanel, sColumns, columnsModel);

	String sTitleString = (String) ls.doExecute(null, "java.setTableSizeDialogTitle", 0, 0);
	setTitle(sTitleString); // "Choose Font Information"
	setModal(true);
	setResizable(true);
	addWindowListener(new java.awt.event.WindowAdapter() {
	    public void windowClosing(java.awt.event.WindowEvent evt) {
		closeDialog(evt);
	    }
	});

	tableSizePanel.setLayout(new java.awt.GridLayout(4, 1));

	buttonPanel.setLayout(new java.awt.FlowLayout(java.awt.FlowLayout.RIGHT));

	String sOKString = (String) ls.doExecute(null, "java.dialogOK", 0, 0);
	okButton.setText(sOKString); // "OK"
	okButton.addActionListener(new java.awt.event.ActionListener() {
	    public void actionPerformed(java.awt.event.ActionEvent evt) {
		okButtonActionPerformed(evt);
	    }
	});

	buttonPanel.add(okButton);

	String sCancelString = (String) ls.doExecute(null, "java.dialogCancel", 0, 0);
	cancelButton.setText(sCancelString); // "Cancel"
	cancelButton.addActionListener(new java.awt.event.ActionListener() {
	    public void actionPerformed(java.awt.event.ActionEvent evt) {
		cancelButtonActionPerformed(evt);
	    }
	});

	buttonPanel.add(cancelButton);

	Border emptyBorder = BorderFactory.createEmptyBorder(15, 45, 15, 45);
	tableSizePanel.setBorder(emptyBorder);
	getContentPane().add(tableSizePanel, java.awt.BorderLayout.CENTER);
	getContentPane().add(buttonPanel, java.awt.BorderLayout.SOUTH);

	getRootPane().setDefaultButton(okButton);
	addCancelByEscapeKey();

	pack();
	java.awt.Dimension screenSize = java.awt.Toolkit.getDefaultToolkit().getScreenSize();
	Dimension dialogSize = this.getSize();
	setLocation((screenSize.width - dialogSize.width) / 2,
		(screenSize.height - dialogSize.height) / 2);
    }

    private void addCancelByEscapeKey() {
	String CANCEL_ACTION_KEY = "CANCEL_ACTION_KEY";
	int noModifiers = 0;
	KeyStroke escapeKey = KeyStroke.getKeyStroke(KeyEvent.VK_ESCAPE, noModifiers, false);
	InputMap inputMap = getRootPane()
		.getInputMap(JComponent.WHEN_ANCESTOR_OF_FOCUSED_COMPONENT);
	inputMap.put(escapeKey, CANCEL_ACTION_KEY);
	AbstractAction cancelAction = new AbstractAction() {
	    public void actionPerformed(ActionEvent e) {
		closeDialog();
	    }
	};
	getRootPane().getActionMap().put(CANCEL_ACTION_KEY, cancelAction);
    }

    private void closeDialog() {
	dispose();
    }

    private void okButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-
	// FIRST
	// :
	// event_okButtonActionPerformed
	doClose(RET_OK);
    }// GEN-LAST:event_okButtonActionPerformed

    private void cancelButtonActionPerformed(java.awt.event.ActionEvent evt) {// GEN
	// -
	// FIRST
	// :
	// event_cancelButtonActionPerformed
	doClose(RET_CANCEL);
    }// GEN-LAST:event_cancelButtonActionPerformed

    /** Closes the dialog */
    private void closeDialog(java.awt.event.WindowEvent evt) {// GEN-FIRST:
	// event_closeDialog
	doClose(RET_CANCEL);
    }// GEN-LAST:event_closeDialog

    private void doClose(int retStatus) {
	iHeaderRows = ((Number) headerRowsModel.getValue()).intValue();
	iNonHeaderRows = ((Number) nonHeaderRowsModel.getValue()).intValue();
	iColumns = ((Number) columnsModel.getValue()).intValue();

	returnStatus = retStatus;
	setVisible(false);
    }

    static protected JSpinner addLabeledSpinner(Container container, String sLabel,
	    SpinnerModel model) {
	JLabel label = new JLabel(sLabel);
	container.add(label);

	JSpinner spinner = new JSpinner(model);
	label.setLabelFor(spinner);
	container.add(spinner);
	spinner.setEditor(new JSpinner.NumberEditor(spinner, "#"));

	JFormattedTextField ftf = null;
	// Tweak the spinner's formatted text field.
	ftf = getTextField(spinner);
	if (ftf != null) {
	    ftf.setColumns(6); // specify more width than we need
	    ftf.setHorizontalAlignment(JTextField.RIGHT);
	}

	return spinner;
    }

    /**
     * Return the formatted text field used by the editor, or null if the editor
     * doesn't descend from JSpinner.DefaultEditor.
     */
    public static JFormattedTextField getTextField(JSpinner spinner) {
	JComponent editor = spinner.getEditor();
	if (editor instanceof JSpinner.DefaultEditor) {
	    return ((JSpinner.DefaultEditor) editor).getTextField();
	} else {
	    System.err.println("Unexpected editor type: " + spinner.getEditor().getClass()
		    + " isn't a descendant of DefaultEditor");
	    return null;
	}
    }

    /** @return the return status of this dialog - one of RET_OK or RET_CANCEL */
    public int getReturnStatus() {
	return returnStatus;
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JPanel tableSizePanel;
    private javax.swing.JButton okButton;
    private javax.swing.JButton cancelButton;
    private javax.swing.JPanel buttonPanel;
    SpinnerModel headerRowsModel;
    SpinnerModel nonHeaderRowsModel;
    SpinnerModel columnsModel;

    // End of variables declaration//GEN-END:variables

    private int returnStatus = RET_CANCEL;

    /*
     * Portions of this code borrowed from
     * http://download.oracle.com/javase/tutorial
     * /uiswing/examples/components/SpinnerDemoProject
     * /src/components/SpinnerDemo.java
     */
    /*
     * Copyright (c) 1995, 2008, Oracle and/or its affiliates. All rights
     * reserved.
     * 
     * Redistribution and use in source and binary forms, with or without
     * modification, are permitted provided that the following conditions are
     * met:
     * 
     * - Redistributions of source code must retain the above copyright notice,
     * this list of conditions and the following disclaimer.
     * 
     * - Redistributions in binary form must reproduce the above copyright
     * notice, this list of conditions and the following disclaimer in the
     * documentation and/or other materials provided with the distribution.
     * 
     * - Neither the name of Oracle or the names of its contributors may be used
     * to endorse or promote products derived from this software without
     * specific prior written permission.
     * 
     * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
     * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
     * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
     * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
     * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
     * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
     * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
     * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
     * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
     * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
     * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
     */

}
