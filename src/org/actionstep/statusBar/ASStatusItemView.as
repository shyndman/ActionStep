/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.NSButton;
import org.actionstep.NSButtonCell;
import org.actionstep.NSEvent;
import org.actionstep.NSImage;
import org.actionstep.NSRect;
import org.actionstep.NSStatusItem;
import org.actionstep.statusBar.ASStatusItemCell;

/**
 * This is the view that is used by default to draw an <code>NSStatusItem</code>.
 * 
 * To use a custom view to draw the status item, use 
 * <code>NSStatusItem#setView</code>.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.statusBar.ASStatusItemView extends NSButton 
{
	private static var g_cellClass:Function;
	private var m_statusItem:NSStatusItem;
	private var m_doubleAction:String;
	
	//******************************************************															 
	//*                 Construction
	//******************************************************
	
	/**
	 * Initializes the view with a status item from which its attributes
	 * should be drawn.
	 */
	public function initWithStatusItem(statusItem:NSStatusItem):ASStatusItemView
	{
		super.init();
		
		m_statusItem = statusItem;
		
		//
		// Create the button cell that draws this thing.
		//
		var cell:NSButtonCell = NSButtonCell(cell());
		cell.initTextCell("");
		//cell.setBordered(false);
		//cell.setBezeled(false);
		cell.setBackgroundColor(null);
		cell.setImagePosition(NSCellImagePosition.NSNoImage);
		
		return this;
	}
	
	//******************************************************															 
	//*                    Images
	//******************************************************

	public function setImage(value:NSImage):Void 
	{
		super.setImage(value);		
		
		if (value == null && alternateImage() == null)
		{
			setImagePosition(NSCellImagePosition.NSNoImage);
		}
		else 
		{
			setImagePosition(NSCellImagePosition.NSImageLeft);
		}
	}
		
	public function setAlternateImage(value:NSImage):Void 
	{		
		super.setAlternateImage(value);
		
		if (value == null && image() == null)
		{
			setImagePosition(NSCellImagePosition.NSNoImage);
		} 
		else 
		{
			setImagePosition(NSCellImagePosition.NSImageLeft);
		}
	}
	
	//******************************************************															 
	//*               Describing objects
	//******************************************************
	
	/**
	 * Returns a string representation of the ASStatusItemView instance.
	 */
	public function description():String
	{
		return "ASStatusItemView(title=" + title() + ", cell=" + cell() + ")";
	}
	
	//******************************************************															 
	//*                 Target-action
	//******************************************************
	
	public function doubleAction():String
	{
		return m_doubleAction;
	}
	
	public function setDoubleAction(dblAction:String):Void
	{
		m_doubleAction = dblAction;
	}
	
	public function sendDoubleAction():Boolean
	{
		if (!isEnabled())
			return false;
		
		//
		// Send the action to the target if possible.
		//
		var targ:Object = target();
		var act:String = doubleAction();
		if (act != null && act.length > 0 && targ != null)
			return sendActionTo(act, targ);
			
		return false;
	}
	
	//******************************************************															 
	//*                Handling events
	//******************************************************
	
	public function mouseDown(event:NSEvent):Void
	{
		if (event.clickCount == 2 && !m_ignoresMultiClick)
		{
			sendDoubleAction();
			return;
		}
		
		super.mouseDown(event);
	}
	
	//******************************************************															 
	//*               Drawing the view
	//******************************************************
	
	public function drawRect(aRect:NSRect):Void
	{
		m_mcBounds.clear();
		cell().drawWithFrameInView(aRect, this);
	}
	
	//******************************************************															 
	//*        Necessary NSControl cell accessors
	//******************************************************
	
	/**
	 * Sets the cell class to <code>klass</code>.
	 */
	public static function setCellClass(klass:Function) 
	{
		g_cellClass = klass;
	}
	
	/**
	 * Returns the cell class.
	 * 
	 * The default is <code>org.actionstep.NSStatusItem.ASStatusItemCell</code>.
	 */  
	public static function cellClass():Function {
		if (g_cellClass == undefined) 
		{
			g_cellClass = ASStatusItemCell;
		}
		
		return g_cellClass;
	}
}