/* See LICENSE for copyright and terms of use */

import org.actionstep.NSAttributedString;
import org.actionstep.NSImage;
import org.actionstep.NSMenu;
import org.actionstep.NSObject;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSStatusBar;
import org.actionstep.statusBar.ASStatusItemView;
import org.actionstep.NSView;

/**
 * @author Scott Hyndman
 */
class org.actionstep.NSStatusItem extends NSObject 
{
	private var m_statusBar:NSStatusBar;
	private var m_altImage:NSImage;
	private var m_image:NSImage;
	private var m_title:String;
	private var m_attTitle:NSAttributedString;
	private var m_highlightMode:Boolean;
	private var m_length:Number;
	private var m_toolTip:String;
	private var m_actionMask:Number;
	private var m_action:String;
	private var m_doubleAction:String;
	private var m_enabled:Boolean;
	private var m_menu:NSMenu;
	private var m_target:Object;
	private var m_defView:ASStatusItemView;
	private var m_view:NSView;
	
	//******************************************************															 
	//*                  Construction
	//******************************************************
	
	/**
	 * Never call this directly. To create a status item, use
	 * <code>NSStatusBar#statusItemWithLength</code>.
	 */
	public function NSStatusItem(statusBar:NSStatusBar)
	{
		m_statusBar = statusBar;
		m_highlightMode = false;
		m_length = 0;
		m_defView = (new ASStatusItemView()).initWithStatusItem(this);
	}
	
	//******************************************************															 
	//*          Getting the item’s status bar
	//******************************************************
	
	/**
	 * Returns this item's status bar.
	 */
	public function statusBar():NSStatusBar
	{
		return m_statusBar;
	}
	
	//******************************************************															 
	//*              Appearance Properties           
	//******************************************************
	
	/**
	 * Sets an alternate image to be displayed when a status bar item is 
	 * highlighted.
	 */
	public function setAlternateImage(image:NSImage):Void
	{
		m_altImage = image;
		m_defView.setAlternateImage(image);
	}
	
	/**
	 * Returns the alternate image that is displayed when a status bar item is
	 * highlighted.
	 */
	public function alternateImage():NSImage
	{
		return m_altImage;
	}
	
	/**
	 * Sets the title that is displayed in the status bar. If this item contains
	 * an image, the title is displayed to the right of the image.
	 */
	public function setTitle(title:String):Void
	{
		m_title = title;
		m_attTitle = (new NSAttributedString()).initWithString(title);
		m_defView.setTitle(title);
	}
	
	/**
	 * Returns the title that is displayed in the status bar.
	 */
	public function title():String
	{
		return m_title;
	}
	
	/**
	 * Sets the attributed string title that is displayed in the status bar. If 
	 * this item contains an image, the title is displayed to the right of the 
	 * image.
	 */
	public function setAttributedTitle(title:NSAttributedString):Void
	{
		m_attTitle = title;
		m_title = title.string();
		m_defView.setAttributedTitle(title);
	}

	/**
	 * Returns the attributed title that is displayed in the status bar.
	 */	
	public function attributedTitle():NSAttributedString
	{
		return m_attTitle;
	}
	
	/**
	 * Sets whether the status bar item is highlighted when clicked. The default 
	 * is <code>false</code>.
	 */
	public function setHighlightMode(flag:Boolean):Void
	{
		m_highlightMode = flag;
		
		// TODO
	}
	
	/**
	 * Returns whether the status bar item is highlighted when clicked.
	 */
	public function highlightMode():Boolean
	{
		return m_highlightMode;
	}
	
	/**
	 * Sets the image that is displayed in the status bar. If the status bar 
	 * item also has a title set, the image is displayed to the left of the 
	 * title.
	 */
	public function setImage(image:NSImage):Void
	{
		m_image = image;
		m_defView.setImage(image);
	}
	
	/**
	 * Returns the image that is displayed in the status bar.
	 */
	public function image():NSImage
	{
		return m_image;
	}
	
	/**
	 * Sets the length allocated to this status bar item in the status bar.
	 * 
	 * <code>length</code> can be a pixel value,  
	 * <code>NSStatusBar.NSSquareStatusItemLength</code>, or 
	 * <code>NSStatusBar.NSVariableStatusItemLength</code>.
	 */
	public function setLength(length:Number):Void
	{
		var oldLength:Number = m_length;
		
		if (length == NSStatusBar.NSSquareStatusItemLength) {
			length = statusBar().thickness();	
		}
		
		m_length = length;
		view().setFrameSize((new NSSize(length, statusBar().thickness()
			)).subtractSize(new NSSize(0, 2)));
		
		//
		// Shift other status items
		//
		var delta:Number = oldLength - m_length;
		statusBar().shiftUpToItemByLength(this, delta);
	}
	
	/**
	 * Returns the length of this status bar item.
	 */
	public function length():Number
	{
		return m_length;
	}

	/**
	 * Sets the tooltip shown when the cursor is paused over this status
	 * bar item.
	 */
	public function setToolTip(toolTip:String):Void
	{
		m_toolTip = toolTip;
		m_defView.setToolTip(toolTip);
	}

	/**
	 * Returns the tooltip shown when the cursor is paused over this status
	 * bar item.
	 */	
	public function toolTip():String
	{
		return m_toolTip;
	}
	
	//******************************************************															 
	//*                     Behaviour
	//******************************************************
	
	public function sendActionOn(mask:Number):Void
	{
		m_actionMask = mask;
		m_defView.sendActionOn(mask);
	}
	
	/**
	 * Returns the method that is called on the status bar items target when 
	 * it is clicked.
	 */
	public function setAction(action:String):Void
	{
		m_action = action;
		m_defView.setAction(action);
	}
	
	/**
	 * Returns the method that is called on the status bar items target when 
	 * it is clicked.
	 */
	public function action():String
	{
		return m_action;
	}
	
	/**
	 * Sets the method that is called on the status bar items target when 
	 * it is double clicked.
	 */
	public function setDoubleAction(doubleAction:String):Void
	{
		m_doubleAction = doubleAction;
		m_defView.setDoubleAction(doubleAction);
	}

	/**
	 * Returns the method that is called on the status bar items target when 
	 * it is double clicked.
	 */	
	public function doubleAction():String
	{
		return m_doubleAction;
	}
	
	/**
	 * Sets whether the status bar item responds to click events.
	 */
	public function setEnabled(flag:Boolean):Void
	{
		m_enabled = flag;
		m_defView.setEnabled(flag);
	}

	/**
	 * Returns <code>true</code> if the status bar item responds to click 
	 * events, or <code>false</code> otherwise.
	 */	
	public function isEnabled():Boolean
	{
		return m_enabled;
	}
	
	/**
	 * Sets the pull down menu that is displayed when this status bar item is
	 * clicked.
	 */
	public function setMenu(menu:NSMenu):Void
	{
		m_menu = menu;
		m_defView.setMenu(menu);
	}
	
	/**
	 * Returns the pull down menu that is displayed when this status bar item is
	 * clicked.
	 */
	public function menu():NSMenu
	{
		return m_menu;
	}
	
	/**
	 * Sets the object to which the status bar items action messages are sent.
	 */
	public function setTarget(aTarget:Object):Void
	{
		m_target = aTarget;
		m_defView.setTarget(aTarget);
	}

	/**
	 * Returns the object to which the status bar items action messages are 
	 * sent.
	 */	
	public function target():Object
	{
		return m_target;
	}
	
	//******************************************************															 
	//*                  Custom View
	//******************************************************
	
	/**
	 * Sets a custom view used to draw onto this status bar item's status bar.
	 * 
	 * This view must handle mouse events and send action messages on its own.
	 */
	public function setView(aView:NSView):Void
	{
		m_view = aView;
		m_defView.release();
		m_defView = null;
	}
	
	/**
	 * Returns the view used to draw onto this status bar item's status
	 * bar.
	 */
	public function view():NSView
	{
		if (null != m_view) {
			return m_view;
		}
		
		return m_defView;
	}
	
	//******************************************************															 
	//*                    Drawing
	//******************************************************
	
	/**
	 * Draw the background of the status bar item.
	 */
	public function drawStatusBarBackgroundInRectWithHighlight(
		rect:NSRect, highlight:Boolean):Void
	{
		// TODO
	}
}