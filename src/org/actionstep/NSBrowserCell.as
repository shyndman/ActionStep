/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.NSCell;
import org.actionstep.NSColor;
import org.actionstep.NSControl;
import org.actionstep.NSFont;
import org.actionstep.NSImage;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeColorNames;
import org.actionstep.themes.ASThemeImageNames;
import org.actionstep.themes.ASThemeProtocol;

/**
 * <p>
 * NSBrowserCell is the subclass of NSCell used by default to display data in 
 * the columns of an <code>NSBrowser</code>. (Each column contains an NSMatrix 
 * filled with NSBrowserCells.)
 * </p>
 * <p>
 * It implements the user interface of {@link org.actionstep.NSBrowser}.
 * </p>
 * <p>
 * The branch, and highlighted branch images are provided by the current
 * {@link ASTheme}. Their names are 
 * <code>ASThemeImageNames#NSBrowserBranchImage</code> and
 * <code>ASThemeImageNames#NSHighlightedBrowserBranchImage</code> 
 * respectively.
 * </p>
 * 
 * <h3>Subclassing notes:</h3>
 * <p>
 * {@link #branchImage()} and {@link #highlightedBranchImage()} must be
 * overridden in every descendant class (subclasses of NSBrowserCell as well
 * as sub-subclasses).
 * </p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSBrowserCell extends NSCell {
		
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_altImage:NSImage;
	private var m_isLeaf:Boolean;
	private var m_isLoaded:Boolean;
	private var m_textField:TextField;
	private var m_textFormat:TextFormat;
  
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSBrowserCell</code> class.
	 */
	public function NSBrowserCell() {
		m_isLeaf = false;
		m_isLoaded = false;
		m_font = NSFont.fontWithNameSize("Verdana", 12);
	}
	
	/**
	 * Initializes the browser cell with the text <code>text</code>.
	 */
	public function initTextCell(aString:String):NSBrowserCell {
		super.initTextCell(aString);		
		return this;
	}
	
	/**
	 * Initializes the browser cell as an image cell with an image of 
	 * <code>image</code>.
	 */
	public function initImageCell(anImage:NSImage):NSBrowserCell {
		super.initImageCell(anImage);	
		return this;
	}
	
	//******************************************************
	//*         Releasing the object from memory
	//******************************************************
	
	public function release():Boolean {
		super.release();
		m_textField.removeTextField();
		return true;
	}
	
	//******************************************************
	//*               Describing the cell
	//******************************************************
	
	/**
	 * Returns a string representation of the NSBrowserCell instance.
	 */
	public function description():String {
		return "NSBrowserCell(" +
			"isLoaded=" + isLoaded() + "," +
			"isLeaf=" + isLeaf() + "," +
			"stringValue=" + stringValue() + ")";
	}
	
	//******************************************************
	//*             Accessing graphics images
	//******************************************************
	
	/**
	 * <p>Returns the default image for branch NSBrowserCells (a right-pointing 
	 * triangle).</p>
	 * 
	 * <p>This method must be overridden in subclasses.</p>
	 */
	public static function branchImage():NSImage {
		return NSImage.imageNamed(ASThemeImageNames.NSBrowserBranchImage);
	}
	
	/**
	 * <p>Returns the default NSImage for branch NSBrowserCells that are 
	 * highlighted (a lighter version of the image returned by 
	 * {@link #branchImage}).</p>
	 * 
	 * <p>This method must be overridden in subclasses.</p>
	 */
	public static function highlightedBranchImage():NSImage {
		return NSImage.imageNamed(ASThemeImageNames.NSHighlightedBrowserBranchImage);
	}
	
	/**
	* <p>
	* Returns the image displayed by the receiver (if any).
	* </p>
	*
	* @see #setImage()
	*/
	public function image():NSImage {
		return m_image;
	}
	
	/**
	 * <p>Sets the receiver’s image.</p>
	 * 
	 * <p>If <code>newImage</code> is <code>null</code>, it removes the image 
	 * for the receiver. <code>newImage</code> is drawn vertically centered on 
	 * the left edge of the browser cell. Note that <code>newImage</code> is 
	 * drawn at the given size of the image. <code>NSBrowserCell</code> does not 
	 * set the size of the image, nor does it clip the drawing of the image. 
	 * Make sure <code>newImage</code> is the correct size for drawing in the 
	 * browser cell.</p>
	 */
	public function setImage(newImage:NSImage):Void {		
		super.setImage(newImage);
	}
	
	/**
	 * Returns this receiver’s image for the highlighted state or nil if no 
	 * image is set.
	 * 
	 * @see #setAlternateImage()
	 */
	public function alternateImage():NSImage {
		return m_altImage;
	}
	
	/**
	 * <p>Sets the receiver’s image for the highlighted state.</p>
	 * 
	 * <p>If <code>newAltImage</code> is <code>null</code>, it removes the 
	 * alternate image for the receiver. <code>newAltImage</code> is drawn 
	 * vertically centered on the left edge of the browser cell. Note that 
	 * <code>newAltImage</code> is drawn at the given size of the image. 
	 * <code>NSBrowserCell</code> does not set the size of the image, nor does 
	 * it clip the drawing of the image. Make sure <code>newAltImage</code> is 
	 * the correct size for drawing in the browser cell.</p>
	 */
	public function setAlternateImage(newAltImage:NSImage):Void {		
		var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
		
		//
		// Stop observing old image
		//
		if (m_altImage != null) {
			nc.removeObserverNameObject(this, NSImage.NSImageDidLoadNotification, 
				m_altImage);
		}
		
		m_altImage = newAltImage;
		
		//
		// Begin observing new image
		//
		if (m_altImage != null && !m_altImage.isRepresentationLoaded()) {
			nc.addObserverSelectorNameObject(this, "altImageDidLoad", 
			NSImage.NSImageDidLoadNotification, m_altImage);
		} else {
			if (m_controlView != null) {
				if (m_controlView instanceof NSControl) {
					NSControl(m_controlView).updateCell(this);
				} else {
					m_controlView.setNeedsDisplay(true);
				}
			}	
		}
	}
	
	/**
	 * Calls setAlternateImage() with the newly loaded image. The observer will 
	 * be removed, and <code>ActionCell</code> subclasses will tell their 
	 * controls to update.
	 */
	private function altImageDidLoad(ntf:NSNotification):Void {
		setAlternateImage(m_altImage);
	}
	
	//******************************************************
	//*                  Setting state
	//******************************************************
	
	/**
	 * Unhighlights the receiver and unsets its state.
	 * 
	 * @see #set()
	 */
	public function reset():Void {
		setHighlighted(false);
		setState(NSCell.NSOffState);
	}
	
	/**
	 * Highlights the receiver and sets its state.
	 * 
	 * @see #reset()
	 */
	public function set():Void {
		setHighlighted(true);
		setState(NSCell.NSOnState);
	}
	
	/**
	 * Overridden to do nothing.
	 */
	public function setType(aType:Number):Void {
		//
		// We do nothing here (we match the Mac OS X behavior) because with
		// NSBrowserCell GNUstep implementation the cell may contain an image 
		// and text at the same time. 
		//
	}
	
	//******************************************************
	//*            Determining cell attributes
	//******************************************************
	
	/**
	 * <p>Returns whether the receiver is a leaf or a branch cell.</p>
	 * 
	 * <p>A branch NSBrowserCell has an image near its right edge indicating 
	 * that more, hierarchically related information is available; when the 
	 * user selects the cell, the NSBrowser displays a new column of 
	 * NSBrowserCells. A leaf NSBrowserCell has no image, indicating that the 
	 * user has reached a terminal piece of information; it doesn’t point to 
	 * additional information.</p>
	 * 
	 * @see #setLeaf()
	 */
	public function isLeaf():Boolean {
		return m_isLeaf;
	}
	
	/**
	 * <p>Sets whether the receiver is a leaf or a branch cell, depending on the 
	 * Boolean value <code>flag</code>.</p>
	 * 
	 * @see #isLeaf()
	 */
	public function setLeaf(flag:Boolean):Void {
		m_isLeaf = flag;
	}
	
	/**
	 * Returns <code>true</code> if the receiver’s state has been set and the 
	 * cell is ready to display.
	 * 
	 * @see #setLoaded()
	 */
	public function isLoaded():Boolean {
		return m_isLoaded;
	}
	
	/**
	 * Sets whether the receiver’s state has been set and the cell is ready to 
	 * display, depending on the Boolean value <code>flag</code>.
	 */
	public function setLoaded(flag:Boolean):Void {
		m_isLoaded = flag;
	}
	
	//******************************************************
	//*               Graphical properties
	//******************************************************
	
	public function isOpaque():Boolean {
		return true;
	}
	
	public function setFont(font:NSFont):Void {
		super.setFont(font);
		m_textFormat = m_font.textFormat();
		if (m_textField != null) {
			m_textField.embedFonts = m_font.isEmbedded();
		}
	}
  
	/**
	 * Returns the cell's textfield. Will build if necessary.
	 */
	private function textField():TextField {
		if (m_textField == null || m_textField._parent == undefined) {
			//
			// Build the text format and textfield
			//
			m_textField = m_controlView.createBoundsTextField();
			m_textFormat = m_font.textFormatWithAlignment(m_alignment);
			m_textField.self = this;
			m_textField.text = stringValue();
			m_textField.embedFonts = m_font.isEmbedded();
			m_textField.selectable = false;
			m_textField.type = "dynamic";
			
			//
			// Assign the textformat.
			//
			m_textField.setTextFormat(m_textFormat);
		}
		
		return m_textField;
	}

	private function validateTextField(cellFrame:NSRect, textColor:NSColor) {
		var mc:MovieClip = m_controlView.mcBounds();
		var colorChanged:Boolean = false;
		var width:Number = cellFrame.size.width - 1;
		var height:Number = cellFrame.size.height - 1;
		var x:Number = cellFrame.origin.x;
		var y:Number = cellFrame.origin.y;
		var text:String = stringValue();
		var fontHeight:Number = m_font.getTextExtent("Why").height;
		
		//
		// Get the textfield. Will be build if necessary.
		//
		var tf:TextField = textField();
		
		//
		// Position the text field.
		//
		tf._x = x;
		tf._y = y + (height - fontHeight)/2;
		tf._width = width-1;
		tf._height = fontHeight;
    	
    	//
    	// Set the text
    	//	
		if (tf.text != text) {
			tf.text = text;
		}
		
		//
		// Set the font and text format if necessary.
		//
		if (m_textFormat.color != textColor.value) {
			m_textFormat.color = textColor.value;
			colorChanged = true;
		}
		
		if (tf.getTextFormat() != m_textFormat || colorChanged) {
			tf.setTextFormat(m_textFormat);
		}		
	}
  
	//******************************************************
	//*               Drawing the cell
	//******************************************************
	
	public function drawInteriorWithFrameInView(cellFrame:NSRect, 
			controlView:NSView):Void {
		setControlView(controlView);
		var theme:ASThemeProtocol = ASTheme.current();
		var showsFp:Boolean = showsFirstResponder();
		var mc:MovieClip = controlView.mcBounds();
		var tf:TextField = textField();
		var title_rect:NSRect = cellFrame.clone();
		var branch_image:NSImage = null;
		var cell_image:NSImage = null;
		var textColor:NSColor;
		var backColor:NSColor;
		
		//
		// Determine colors and images
		//
		if (isHighlighted() || state()) {
			if (!showsFp) {
				textColor = theme.colorWithName(
					ASThemeColorNames.ASBrowserSelectionText);
				backColor = theme.colorWithName(
					ASThemeColorNames.ASBrowserSelectionBackground);
			}
			
			//
			// Default to first responder colors
			//
			if (showsFp || textColor == null) {
				textColor = theme.colorWithName(
					ASThemeColorNames.ASBrowserFirstResponderSelectionText);	
			}
			if (showsFp || backColor == null) {
				backColor = theme.colorWithName(
					ASThemeColorNames.ASBrowserFirstResponderSelectionBackground);
			}
			
			//
			// Get a branch image if we aren't a leaf
			//
			if (!m_isLeaf) {
				branch_image = getClass().highlightedBranchImage();
			}
			
			cell_image = alternateImage();
		} else {
			textColor = theme.colorWithName(ASThemeColorNames.ASBrowserText);
			backColor = theme.colorWithName(ASThemeColorNames.ASBrowserMatrixBackground);

			if (!m_isLeaf) {
				branch_image = getClass().branchImage();
			}
			
			cell_image = image();
		}
		
		//
		// Fill the background
		//
		ASDraw.fillRectWithRect(mc, cellFrame, backColor.value, 100);
		
		//
		// Draw the branch image if there is one
		//
		if (branch_image != null) {
			var size:NSSize;
			var position:NSPoint = NSPoint.ZeroPoint;
			
			size = branch_image.size();
			position.x = Math.max(title_rect.maxX() - size.width - 4.0, 0.);
			position.y = Math.max(title_rect.midY() - (size.height/2.), 0.);
			
			branch_image.lockFocus(mc);
			branch_image.drawAtPoint(position);
			branch_image.unlockFocus();
			
			title_rect.size.width -= size.width + 8;
		}
		
		//
		// Skip 2 points from the left border
		//
		title_rect.origin.x += 2;
		title_rect.size.width -= 2;
		
		//
		// Draw the cell image if there is one
		//
		if (cell_image != null) {
			var size:NSSize;
			var position:NSPoint = NSPoint.ZeroPoint;
			
			size = cell_image.size();
			position.x = title_rect.minX();
			position.y = Math.max(title_rect.midY() - (size.height/2.),0.);

			cell_image.lockFocus(mc);
			cell_image.drawAtPoint(position);
			cell_image.unlockFocus();
			
			title_rect.origin.x += size.width + 4;
			title_rect.size.width -= size.width + 4;
		}
		
		// Draw the body of the cell
		tf.text = stringValue();
		validateTextField(title_rect, textColor);
	}
}