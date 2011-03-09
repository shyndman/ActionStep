/* See LICENSE for copyright and terms of use */

import org.actionstep.graphics.ASGraphics;
import org.actionstep.NSArray;
import org.actionstep.NSImage;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSSortDescriptor;
import org.actionstep.NSToolbar;
import org.actionstep.NSToolbarItem;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeImageNames;
import org.actionstep.toolbar.ASToolbarOverflowButton;
import org.actionstep.toolbar.items.ASToolbarItemBackViewProtocol;
import org.actionstep.window.ASRootWindowView;

/**
 * <p>The visual representation of a toolbar.</p>
 * 
 * <p>This is used internally, and should not be modified.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.toolbar.ASToolbarView extends NSView {
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private static var g_nc:NSNotificationCenter;
	
	private var m_toolbar:NSToolbar;
	private var m_isOverflow:Boolean;
	private var m_visibleItems:NSArray;
	private var m_visibleBackRows:NSArray;
	private var m_overflowButton:ASToolbarOverflowButton;
	private var m_overflowSpace:NSToolbarItem;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASToolbarView</code> class.
	 */
	public function ASToolbarView() {
		setAutoresizingMask(NSView.WidthSizable);
		m_isOverflow = false;
	}
	
	/**
	 * Initializes the view with a toolbar.
	 */
	public function initWithToolbar(toolbar:NSToolbar):ASToolbarView {
		super.init();
		m_toolbar = toolbar;
		setAutoresizingMask(NSView.WidthSizable | NSView.HeightSizable);
		
		//
		// Add overflow button and its flexy space
		//
		m_overflowButton = (new ASToolbarOverflowButton()).init();
		m_overflowButton.setToolbar(m_toolbar);
		m_overflowSpace = NSToolbarItem.flexibleSpaceItem();
		m_overflowSpace.__setToolbar(m_toolbar);
						
		return this;
	}
	
	//******************************************************
	//*         Releasing the object from memory
	//******************************************************
	
	public function release():Boolean {
		super.release();
		m_toolbar = null;
		g_nc.removeObserver(this);
		return true;
	}
	
	//******************************************************
	//*               Setting the window
	//******************************************************
	
	/**
	 * Sets the toolbar view's window to <code>window</code>.
	 */
	public function setWindow(window:NSWindow):Void {
		if (window == null) {
			removeFromSuperview();
			return;
		}
		
		var rv:ASRootWindowView = window.rootView();
		var tbv:NSView = rv.toolbarView();		
		tbv.addSubview(this);		
	}
	
	//******************************************************
	//*             Overridden event handlers
	//******************************************************
	
	public function viewWillMoveToWindow(window:NSWindow):Void {
		super.viewWillMoveToWindow(window);
		
		if (m_window != null) {
			g_nc.removeObserverNameObject(this, null, m_window);
		}
		
		if (window != null) {
			g_nc.addObserverSelectorNameObject(
				this, "windowWillClose",
				NSWindow.NSWindowWillCloseNotification,
				window);
		}
	}
	
	//******************************************************
	//*            Responding to window events
	//******************************************************
	
	private function windowWillClose(ntf:NSNotification):Void {
		var wnd:NSWindow = NSWindow(ntf.object);
		if (wnd.isReleasedWhenClosed()) {
			this.release();
		}
	}
	
	//******************************************************
	//*             Getting visible items
	//******************************************************
	
	/**
	 * <p>Returns an array of visible items in this view's toolbar.</p>
	 * 
	 * <p>This value is used by the toolbar.</p>
	 */
	public function visibleItems():NSArray {
		return m_visibleItems;
	}
	
	//******************************************************
	//*                 Toolbar items
	//******************************************************
	
	public function reload():Void {
		handleItemVisibility();
		setNeedsDisplay(true);
	}
	
	private function handleItemVisibility():Void {
		var visible:NSArray = visibleBackRows();
		
		//
		// If we have an overflow, add flexible space and the overflow button
		// to the end of the 
		//
		if (m_isOverflow) {			
			if (ASToolbarItemBackViewProtocol(visible.lastObject()).toolbarItem()
					.itemIdentifier() != 
					NSToolbarItem.NSToolbarFlexibleSpaceItemIdentifier) {
				visible.addObject(m_overflowSpace.__backView());			
			}
			visible.addObject(m_overflowButton);
		}
		
		layoutItemFrames();
		adjustForFlexibleSpace();
		
		//
		// Add and remove subviews
		//
		var sv:NSArray = NSArray.arrayWithArray(m_subviews);
		var arr:Array = sv.internalList();
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			if (!visible.containsObject(arr[i])) {
				NSView(arr[i]).removeFromSuperview();
			}
		}
		
		arr = visible.internalList();
		len = arr.length;
		for (var i:Number = 0; i < len; i++) {
			if (!sv.containsObject(arr[i])) {
				addSubview(arr[i]);
			}
		}
	}
	
	private function visibleBackRows():NSArray {
		//
		// Get the overflow image size
		//
		var overflowSize:NSSize = NSImage.imageNamed(
			ASThemeImageNames.NSToolbarOverflowImage).size();

		//
		// Get a copy of the toolbars items and sort it
		//
		var items:NSArray = NSArray.arrayWithNSArray(m_toolbar.items());
		var sd:NSSortDescriptor = (new NSSortDescriptor()).initWithKeyAscending(
			"visibilityPriority", false);
		items.sortUsingDescriptors(NSArray.arrayWithObject(sd));
					
		//
		// Cycle through and determine the visible rows
		//
		m_visibleItems = NSArray.array();
		var visible:NSArray = NSArray.array();
		var arr:Array = items.internalList();
		var len:Number = arr.length;
		var bvWidth:Number = 0;
		var tbWidth:Number = m_frame.size.width;
		m_isOverflow = false;
		
		for (var i:Number = 0; i < len; i++) {
			var item:NSToolbarItem = NSToolbarItem(arr[i]);
			var bv:NSView = item.__backView();
			if (!item.__isFlexibleSpace()) {
				bvWidth += bv.frame().size.width;
			}
			
			if (bvWidth + overflowSize.width <= tbWidth
					|| (i + 1 == len && bvWidth <= tbWidth)) {
				m_visibleItems.addObject(item);
				visible.addObject(bv);
			} else {
				m_isOverflow = true;
			}
		}

		m_visibleBackRows.release();
		m_visibleBackRows = NSArray.arrayWithNSArray(
			NSArray(m_toolbar.items().valueForKey("__backView")));
		var backRowsTmp:NSArray = NSArray.arrayWithNSArray(
			m_visibleBackRows);
			
		arr = m_visibleBackRows.internalList();
		len = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			if (!visible.containsObject(arr[i])) {
				backRowsTmp.removeObject(arr[i]);
			}
		}
				
		m_visibleBackRows = backRowsTmp;
		return m_visibleBackRows;
	}
	
	//******************************************************
	//*                     Layout
	//******************************************************
	
	private var m_heightFromLayout:Number;
	
	private function layoutItemFrames():Void {
		var arr:Array = m_visibleBackRows.internalList();
		var len:Number = arr.length;
		var x:Number = 0;
		var newHeight:Number = 0;
		var subviews:NSArray = NSArray.arrayWithArray(m_subviews);
		
		for (var i:Number = 0; i < len; i++) {
			var bv:NSView = NSView(arr[i]);
			var item:NSToolbarItem = ASToolbarItemBackViewProtocol(bv).toolbarItem();
			item.__layout();	
						
			var frm:NSRect = bv.frame();
			bv.setFrame(new NSRect(x, frm.origin.y, frm.size.width, frm.size.height));
						
			x += frm.size.width;
			
			if (frm.size.height > newHeight) {
				newHeight = frm.size.height;
			}
		}
		
		if (newHeight > 0) {
			m_heightFromLayout = newHeight;
		}
	}
	
	private function adjustForFlexibleSpace():Void {
		var arr:Array = m_visibleBackRows.internalList();
		var len:Number = arr.length;
		var lenAvailable:Number = m_frame.size.width;
		var flexCount:Number = 0;
		var mustAdjustNext:Boolean = false;
		var x:Number = 0;
		
		//
		// Calculate available length
		//
		for (var i:Number = 0; i < len; i++) {
			var bv:NSView = NSView(arr[i]);
			var item:NSToolbarItem = ASToolbarItemBackViewProtocol(bv).toolbarItem();
			if (item.__isFlexibleSpace()) {
				flexCount++;
			} else {
				lenAvailable -= bv.frame().size.width;
			}
		}
				
		//
		// Adjust item sizes based on available space
		//
		var width:Number;
		var bv:NSView;
		var bvf:NSRect;
		var item:NSToolbarItem;
				
		for (var i:Number = 0; i < len; i++) {
			item = ASToolbarItemBackViewProtocol(arr[i]).toolbarItem();
			bv = arr[i];
			bvf = bv.frame();
						
			if (item.__isFlexibleSpace()) {
				width = lenAvailable / flexCount;
				bv.setFrame(new NSRect(x, bvf.origin.y, width,
					bvf.size.height));
				mustAdjustNext = true;
			} else {
				
				bv.setFrameXOrigin(x);
				
				width = bvf.size.width;
			}
			
			x += width;
		}		
	}
	
	//******************************************************
	//*                   Drawing
	//******************************************************
	
	public function drawRect(aRect:NSRect):Void {
		var g:ASGraphics = graphics();
		g.clear();
		
		ASTheme.current().drawToolbarBackgroundWithRectInView(
			m_toolbar, aRect, this);
	}
	
	//******************************************************
	//*                   Resizing
	//******************************************************
	
	public function frameDidChange(oldFrame:NSRect):Void {
		super.frameDidChange(oldFrame);
				
		reload();
	}
			
	//******************************************************
	//*               Static constructor
	//******************************************************
	
	private static function initialize():Void {
		g_nc = NSNotificationCenter.defaultCenter();
	}
}