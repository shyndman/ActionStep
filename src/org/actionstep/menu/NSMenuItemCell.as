/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.ASGlyphImage;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.menu.NSMenuView;
import org.actionstep.NSAttributedString;
import org.actionstep.NSButtonCell;
import org.actionstep.NSColor;
import org.actionstep.NSImage;
import org.actionstep.NSMenuItem;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeColorNames;
import org.actionstep.themes.ASThemeProtocol;

/**
 * <p>Handles the measurement and display of an instance of <code>NSMenuItem</code>.
 * It works in conjunction with an instance of <code>NSMenuView</code>, to
 * control the overall appearance of the menu.</p>
 *
 * <p>Please note that cell masks in <code>highlightsBy</code> and display-related
 * properties like <code>isBezeled</code> are ignored.</p>
 *
 * <p>The following methods override their NSCell counterparts, to prevent the
 * user from thinking that they are different from the menu item; they are
 * not:</p>
 *
 * @see #image
 * @see #title
 * @see #keyEquivalent
 *
 * @see org.actionstep.NSButtonCell#highlightsBy
 * @see org.actionstep.NSCell#isBezeled
 *
 * @author Tay Ray Chuan
 */
class org.actionstep.menu.NSMenuItemCell extends NSButtonCell {

	//******************************************************
	//*                 Class Members
	//******************************************************

	/** Images to indicate the presence of submenus. */
	private static var g_arrowImage:NSImage;
	private static var g_highlightedArrowImage:NSImage;

	/**
	 * Dimensions of the images. Please note that it is assumed that they are
	 * of the same size.
	 */
	private static var g_arrowWidth:Number;
	private static var g_arrowHeight:Number;

	/**
	 * Returns the width of the arrow(s) image(s). The method uses a singleton-
	 * like way to cache the values. Thus it is assumed that the images does
	 * not change at runtime.
	 *
	 * Please note there is no similar method of accessing the arrow height,
	 * since it is not needed for calculation.
	 */
	public static function arrowWidth():Number {
		if(g_arrowImage==null) {
			g_arrowImage = NSImage.imageNamed("NSMenuArrow");
			g_highlightedArrowImage = NSImage.imageNamed("NSHighlightedMenuArrow");
			var size:NSSize = g_arrowImage.size();
			g_arrowWidth = size.width;
			g_arrowHeight = size.height;
		}
		return g_arrowWidth;
	}

	/**
	 * The width between title and key equivalent. Please note that when
	 * displayed, this is seen as the space between the longest item title and
	 * its key equivalent.
	 */
	public static function tabSpacing():Number {
		return 20;
	}

	/**
	 * The amount of padding surrounding the cell, in pixels.
	 */
	public static function insetPadding():Number {
		return 0;
	}

	public static function cellPadding():Number {
		return 5;
	}

	//******************************************************
	//*                 Members Variables
	//******************************************************

	private var m_menuItem:NSMenuItem;
	private var m_menuView:NSMenuView;
	private var m_imageToDisplay:NSImage;
	private var m_titleToDisplay:String;
	private var m_needsSizing:Boolean;

	// Cache
	private var m_imageWidth:Number;
	private var m_titleWidth:Number;
	private var m_titleHeight:Number;
	private var m_keyEqImageWidth:Number;
	private var m_keyEqWidth:Number;
	private var m_stateImageWidth:Number;
	private var m_menuItemHeight:Number;

	private var m_width:Number;

	/**
	 * Pleae not that colors are set by
	 * <code>drawInteriorWithFrameInView</code>, and are set to
	 * <code>null</code> once they have been used.
	 */
	private var m_textColor:NSColor;
	private var m_backgroundColor:NSColor;

	//******************************************************
	//*                 Construction
	//******************************************************

	public function init():NSMenuItemCell {
		super.init();
		arrowWidth();

		setHighlighted(false);
		setAlignment(NSTextAlignment.NSLeftTextAlignment);
		setFont(ASTheme.current().menuFontOfSize(0));

		m_imageWidth = 0;
		m_titleWidth = 0;
		m_titleHeight = 0;
		m_keyEqImageWidth = 0;
		m_keyEqWidth = 0;
		m_stateImageWidth = 0;
		m_menuItemHeight = 0;

		return this;
	}

	//******************************************************
	//*                 Properties
	//******************************************************

	/**
	 * Sets the menu item of the receiver to <code>i</code>.
	 */
	public function setMenuItem(i:NSMenuItem):Void {
		m_menuItem = i;
		setEnabled(m_menuItem.isEnabled());
	}

	/**
	 * Returns the menu item associated with the receiver.
	 */
	public function menuItem():NSMenuItem {
		return m_menuItem;
	}

	/**
	 * Sets the menu view of the reciever to <code>v</code>.
	 */
	public function setMenuView(v:NSMenuView):Void {
		m_menuView = v;
	}

	/**
	 * Returns the menu view associated with the receiver.
	 */
	public function menuView():NSMenuView {
		return m_menuView;
	}

	/**
	 * @see org.actionstep.NSMenuItem#image
	 */
	public function image():NSImage {
		return m_menuItem.image();
	}

	/**
	 * @see org.actionstep.NSMenuItem#title
	 */
	public function title():String {
		return m_menuItem.title();
	}

	/**
	 * Convenience function to return the string required for display,
	 * since the textfield will display both the title and key equivalent
	 */
	public function titleAndKeyEquivalent():String {
		return m_menuItem.title() + "\t" + m_menuItem.keyEquivalent();
	}

	public function keyEquivalentImageWidth():Number {
		return m_keyEqImageWidth;
	}

	/**
	 * @see org.actionstep.NSMenuItem#keyEquivalent
	 */
	public function keyEquivalent():String {
		return m_menuItem.keyEquivalent();
	}

	/**
	 * If <code>flag</code> is <code>true</code>, this cell will be marked
	 * as needing caculation of size, which will be triggered by the cell at the next
	 * opportunity.
	 */
	public function setNeedsSizing(flag:Boolean):Void {
		m_needsSizing = flag;
	}

	/**
	 * Returns <code>true</code> if the cell needs sizing.
	 */
	public function needsSizing():Boolean {
		return m_needsSizing;
	}

	//******************************************************
	//*                 Calculation and Retrieval of Size(s)
	//******************************************************

	/**
	 * Calculates the minimum required height of the cell.
	 *
	 * The calculated values are cached for future use. This method also
	 * calculates the sizes of individual components of the cell’s menu item
	 * and caches those values.
	 */
	public function calcSize():Void {
		var componentSize:NSSize = new NSSize(0,0);
		var anImage:NSImage = image();
		var neededMenuItemHeight:Number = 0;

		// State Image
		if (m_menuItem.changesState() && !m_menuItem.menu().isRoot()) {
			var states:Array = ["onStateImage", "offStateImage", "mixedStateImage"];
			var x:Number = states.length;
			while(x--) {
				if(m_menuItem[states[x]]()!=null) {
					componentSize = NSSize( NSImage( m_menuItem[states[x]]()).size());
					if (componentSize.width > m_stateImageWidth) {
						m_stateImageWidth = componentSize.width;
					}
					if (componentSize.height > neededMenuItemHeight) {
						neededMenuItemHeight = componentSize.height;
					}
				}
			}
		} else {
			m_stateImageWidth = 0;
		}

		// Image
		if (anImage!=null) {
			componentSize = anImage.size();
			m_imageWidth = componentSize.width;
			if (componentSize.height > neededMenuItemHeight) {
				neededMenuItemHeight = componentSize.height;
			}
		} else {
			m_imageWidth = 0;
		}

		// Title and Key Equivalent
		componentSize = font().getTextExtent(m_menuItem.title());
		m_titleWidth = componentSize.width;
		m_titleHeight = componentSize.height;
		if (componentSize.height > neededMenuItemHeight) {
			neededMenuItemHeight = componentSize.height;
		}

		if (keyEquivalent()!="") {
			componentSize = font().getTextExtent(m_menuItem.keyEquivalent());
			m_keyEqWidth = componentSize.width;
		} else {
			m_keyEqWidth = 0;
		}

		componentSize = ASGlyphImage.glyphForKeyMask(
			m_menuItem.keyEquivalentModifierMask()).size();
		if (!isNaN(componentSize.width)) {
			m_keyEqImageWidth = componentSize.width;
		} else {
			m_keyEqImageWidth = 0;
		}
		if (componentSize.height > neededMenuItemHeight) {
			neededMenuItemHeight = componentSize.height;
		}

		// Submenu Arrow
		if (m_menuItem.hasSubmenu() && !m_menuItem.menu().isRoot()) {
			if (g_arrowHeight > neededMenuItemHeight) {
				neededMenuItemHeight = g_arrowHeight;
			}
		}

		// Cache definitive height
		m_menuItemHeight = neededMenuItemHeight;

		// At the end we set sizing to false.
		m_needsSizing = false;
	}

	/**
	 * Returns the width of the image associated with a menu item.
	 */
	public function imageWidth():Number {
		if (m_needsSizing) {
			calcSize();
		}
		return m_imageWidth;
	}

	/**
	 * Returns the width of the menu item text.
	 */
	public function titleWidth():Number {
		if (m_needsSizing) {
			calcSize();
		}
		return m_titleWidth;
	}

	/**
	 * Returns the height of the menu item text.
	 */
	public function titleHeight ():Number {
		if (m_needsSizing) {
			calcSize();
		}
		return m_titleHeight;
	}

	/**
	 * Returns the width of the key equivalent  associated with a menu item.
	 */
	public function keyEquivalentWidth():Number {
		if (m_needsSizing) {
			calcSize();
		}
		return m_keyEqWidth;
	}

	/**
	 * Returns the width of the image used to indicate the state of the menu item.
	 */
	public function stateImageWidth():Number {
		if (m_needsSizing) {
			calcSize();
		}
		return m_stateImageWidth;
	}

	/**
	 * Returns the minimum needed height to display all the items.
	 */
	public function menuItemHeight():Number {
		if (m_needsSizing) {
			calcSize();
		}
		return m_menuItemHeight;
	}

	public function cellWidth():Number {
		if(m_width == null) {
			var w:Number = m_menuView.horizontalEdgePadding();
			m_width = w+
			m_imageWidth+w+
			m_titleWidth;
		}
		return m_width;
	}

	//******************************************************
	//*                 Retrieval of Drawing Rectangles
	//******************************************************

	/**
	 * Returns the rectangle into which the menu item’s image should be drawn.
	 */
	public function imageRectForBounds(rect:NSRect):NSRect {
		var cellFrame:NSRect = NSRect(rect.copy());

		var size:NSSize = m_menuItem.image().size();
		var w:Number = size.width;
		w = isNaN(w) ? 0 : w;

		cellFrame.origin.x += 
			(!m_menuView.isHorizontal() 
				? m_menuView.imageOffset() + (m_menuView.imageWidth() - w) / 2 
				: m_menuView.horizontalEdgePadding() / 2);
		cellFrame.origin.y = cellFrame.origin.y + (cellFrame.size.height - size.height)/2;
		cellFrame.size.width = w;

		return cellFrame;
	}

	/**
	 * Returns the rectangle into which the menu item’s state image should be
	 * drawn.
	 */
	public function stateImageRectForBounds(rect:NSRect):NSRect {
		var cellFrame:NSRect = NSRect(rect.copy());

		var size:NSSize = m_menuItem.stateImage().size();
		var w:Number = size.width;
		w = isNaN(w) ? 0 : w;

		cellFrame.origin.x += m_menuView.stateImageOffset() + (m_menuView.stateImageWidth() - w)/2;
		cellFrame.origin.y = cellFrame.origin.y + (cellFrame.size.height - size.height)/2;
		cellFrame.size.width = m_menuItem.stateImage().size().width;

		return cellFrame;
	}

	/**
	 * Returns the rectangle into which the menu item’s title and key
	 * equivalent should be drawn.
	 */
	public function titleAndKeyEquivalentRectForBounds(rect:NSRect):NSRect {
		var cellFrame:NSRect = NSRect(rect.copy());

		cellFrame.origin.x += 
			(!m_menuView.isHorizontal() 
				? m_menuView.titleAndKeyEquivalentOffset() 
				: imageRectForBounds(rect).maxX()) 
			+ m_menuView.horizontalEdgePadding() / 2
			- cellFrame.origin.x;
		cellFrame.origin.y = rect.origin.y + (rect.size.height - titleHeight())/2;
		cellFrame.size.width = !m_menuView.isHorizontal() ?
		m_menuView.titleAndKeyEquivalentWidth() :
		m_titleWidth;

		return cellFrame;
	}

	//******************************************************
	//*                 Drawing of Components
	//******************************************************

	/**
	 * This is the main entry point for drawing, which will be invoked by
	 * <code>drawRect</code>.
	 *
	 * @see org.actionstep.NSMenuView#drawRect
	 */
	public function drawWithFrameInView(cellFrame:NSRect, controlView:NSView):Void {
		// Save last view drawn to
		if (m_controlView != controlView) {
			m_controlView = controlView;
		}
		// Transparent buttons never draw
		if (m_bcellTransparent) {
			return;
		}
		// Do nothing if cell's frame rect is zero
		if (cellFrame.isEmptyRect()) {
			return;
		}
		drawInteriorWithFrameInView(cellFrame, controlView);
	}

	/**
	 * This function delegates the drawing of different components to the
	 * respective drawing methods associated with them.
	 */
	public function drawInteriorWithFrameInView(cellFrame:NSRect, 
			controlView:NSView):Void {
		
		var theme:ASThemeProtocol = ASTheme.current();
		
		//
		// If we're a separator, let's draw that way
		//
		if (menuItem().isSeparatorItem()) {
			theme.drawMenuSeparatorWithRectInView(cellFrame, menuView());
			return;
		}
		
		//! FIXME add drawing to theme
		
		if(isHighlighted()) {
			if (m_menuItem.isEnabled()) {
  				m_textColor = theme.colorWithName(
					ASThemeColorNames.ASMenuItemSelectedText);
				m_backgroundColor = theme.colorWithName(
					ASThemeColorNames.ASMenuItemSelectedBackground);
  			} else {
				m_textColor = theme.colorWithName(
					ASThemeColorNames.ASMenuItemDisabledText);

  			}
		} else {
			m_backgroundColor = null;
			if (m_menuItem.isEnabled()) {
  				m_textColor = theme.colorWithName(
					ASThemeColorNames.ASMenuItemText);
  			} else {
  				m_textColor = theme.colorWithName(
					ASThemeColorNames.ASMenuItemDisabledText);
  			}
		}

		m_imageToDisplay = m_alternateImage;
		if (m_imageToDisplay==null) {
			m_imageToDisplay = m_menuItem.image();
		}
		m_titleToDisplay = m_alternateTitle;
		if (m_titleToDisplay == null || m_titleToDisplay=="") {
			m_titleToDisplay = m_menuItem.title();
		}

		if (m_imageToDisplay!=null) {
			m_imageWidth = m_imageToDisplay.size().width;
		}

		//
		// Draw border and background first
		//
		drawBorderAndBackgroundWithFrameInView(cellFrame, m_controlView);
		drawStateImageWithFrameInView(cellFrame, controlView);

		// Draw the title
		if (m_titleWidth > 0) {
			drawTitleAndKeyEquivalentWithFrameInView(cellFrame, controlView);
		}

		// Draw the image, using overridden one
		if (m_imageWidth > 0) {
			drawImageWithFrameInView(cellFrame, controlView);
		}

		if (m_menuItem.hasSubmenu() && !m_menuView.isHorizontal()) {
			drawSubmenuArrowWithFrameInView(cellFrame, controlView);
		}
	}

	/**
	 * Draws the borders and background associated with the receiver’s menu item (if any).
	 *
	 * This method invokes <code>imageRectForBounds</code>, passing it
	 * <code>cellFrame</code>, to calculate the rectangle in which to draw the
	 * image. The <code>controlView</code> parameter specifies the view that
	 * contains this cell.
	 *
	 * Note: The cell invokes this method <em>before</em> invoking the methods
	 * to draw the other menu item components.<br/>
	 * (Note and emphasis added by author)
	 */
	public function drawBorderAndBackgroundWithFrameInView
	(cellFrame:NSRect, controlView:NSView):Void {
		if(!m_menuView.isHorizontal()) {
			cellFrame.insetRect(insetPadding(),insetPadding());
		} else {
			cellFrame.size.width = cellWidth();
		}
		ASDraw.fillRectWithRect(
		controlView.mcBounds(),
		cellFrame,
		m_backgroundColor.value);
		m_backgroundColor = null;
	}

	/**
	 * Draws the title associated with the menu item.
	 *
	 *  This method invokes <code>titleRectForBounds</code>, passing it
	 *  <code>cellFrame</code>, to calculate the rectangle in which to draw the
	 *  title. The <code>controlView</code> parameter specifies the view that
	 *  contains this cell.
	 *
	 *  Note: This method is invoked by the cell’s <code>drawWithFrame</code> method.
	 *  You should not need to invoke it directly.
	 */
	public function drawTitleAndKeyEquivalentWithFrameInView(cellFrame:NSRect, controlView:NSView):Void {
		super.drawTitleWithFrameInView(
		(new NSAttributedString()).initWithString(titleAndKeyEquivalent()), controlView);

		m_fontColor = NSColor(m_textColor.copy());
		m_textFormat.color = m_fontColor.value;
		if(!m_menuView.isHorizontal()) {
		m_textFormat.tabStops = [
			m_menuView.keyEquivalentImageOffset()+
			m_menuView.keyEquivalentImageWidth()+
			m_menuView.horizontalEdgePadding()
			];

			m_textField.autosize = false;
		}
		m_textField.setTextFormat(m_textFormat);

		var rect:NSRect = titleAndKeyEquivalentRectForBounds(cellFrame);
		m_textField._x = rect.origin.x;
		m_textField._y = rect.origin.y;
		m_textField._width = rect.size.width;
		m_textField._height = rect.size.height;

		if (keyEquivalent()!="") {
			var img:NSImage = ASGlyphImage.glyphForKeyMask(m_menuItem.keyEquivalentModifierMask());
			var pt:NSPoint = new NSPoint(
			m_menuView.keyEquivalentImageOffset()+
			m_menuView.titleAndKeyEquivalentOffset(),
			cellFrame.origin.y + (cellFrame.size.height - img.size().height)/2);

			if(img!=null) {
				img.lockFocus(controlView.mcBounds());
				img.drawAtPoint(pt);
				img.unlockFocus();
			}
		}
	}

	/**
	 * Draws the state image associated with the menu item.
	 */
	public function drawStateImageWithFrameInView(cellFrame:NSRect, controlView:NSView):Void {
		var pt:NSPoint = stateImageRectForBounds(cellFrame).origin;

		//note: flipped views are ignored
		var img:NSImage = m_menuItem.stateImage();
		var mc:MovieClip = controlView.mcBounds();
		if(img!=null) {
			img.lockFocus(mc);
			img.drawAtPoint(pt);
			img.unlockFocus();
		}
	}

	/**
	 * Draws the image associated with the menu item.
	 */
	public function drawImageWithFrameInView(cellFrame:NSRect, controlView:NSView):Void {
		var pt:NSPoint = imageRectForBounds(cellFrame).origin;

		//note: flipped views are ignored
		var img:NSImage = m_imageToDisplay;
		var mc:MovieClip = controlView.mcBounds();
		if(img!=null) {
			img.lockFocus(mc);
			img.drawAtPoint(pt);
			img.unlockFocus();
		}
	}

	/**
	 * Draws an arrow to indicate the presence of a submenu.
	 *
	 * Please note that 2 different images are drawn, depending on the current
	 * state of the cell:
	 * <ul>
	 * <li>NSMenuArrow -- for non-highlighted state</li>
	 * <li>NSHighlightedMenuArrow -- for highlighted state</li>
	 * </ul>
	 *
	 * @see org.actionstep.ASTheme#registerDefaultImages
	 */
	private function drawSubmenuArrowWithFrameInView
	(cellFrame:NSRect, controlView:NSView):Void {
		var img:NSImage = isHighlighted() ? g_highlightedArrowImage : g_arrowImage;
		var pt:NSPoint = new NSPoint(m_menuView.submenuArrowOffset(),
		cellFrame.origin.y + (cellFrame.size.height - img.size().height)/2);

		var mc:MovieClip = controlView.mcBounds();
		if(img!=null) {
			img.lockFocus(mc);
			img.drawAtPoint(pt);
			img.unlockFocus();
		}
	}

	//! TODO: NSCopying protocol

	public function description():String {
		return "NSMenuItemCell("+m_menuItem.title()+")";
	}
}
