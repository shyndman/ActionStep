/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.constants.NSButtonType;
import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.constants.NSToolbarDisplayMode;
import org.actionstep.NSButton;
import org.actionstep.NSButtonCell;
import org.actionstep.NSCell;
import org.actionstep.NSCopying;
import org.actionstep.NSException;
import org.actionstep.NSImage;
import org.actionstep.NSMenuItem;
import org.actionstep.NSObject;
import org.actionstep.NSSize;
import org.actionstep.NSToolbar;
import org.actionstep.NSView;
import org.actionstep.toolbar.items.ASToolbarFlexibleSpaceItem;
import org.actionstep.toolbar.items.ASToolbarItemBackView;
import org.actionstep.toolbar.items.ASToolbarItemBackViewProtocol;
import org.actionstep.toolbar.items.ASToolbarItemButton;
import org.actionstep.toolbar.items.ASToolbarSeparatorItem;
import org.actionstep.toolbar.items.ASToolbarSpaceItem;

/**
 * Each item in an {@link NSToolbar} is an instance of NSToolbarItem.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSToolbarItem extends NSObject 
		implements NSCopying {
	
	//******************************************************
	//*               Identifier Constants
	//******************************************************
	
	/**
	 * The Separator item.
	 */
	public static var NSToolbarSeparatorItemIdentifier:String
		= "separator";
	
	/**
	 * The Space item.
	 */
	public static var NSToolbarSpaceItemIdentifier:String
		= "space";
		
	/**
	 * The Flexible Space item.
	 */
	public static var NSToolbarFlexibleSpaceItemIdentifier:String
		= "flexibleSpace";
		
//	/**
//	 * The Colors item. Shows the color panel.
//	 */
//	public static var NSToolbarShowColorsItemIdentifier:String
//		= "colors";
//		
//	/**
//	 * The Fonts item. Shows the font panel.
//	 */
//	public static var NSToolbarShowFontsItemIdentifier:String
//		= "fonts";
//		
//	/**
//	 * The Customize item. Shows the customization palette.
//	 */
//	public static var NSToolbarCustomizeToolbarItemIdentifier:String
//		= "customize";
//		
//	/**
//	 * The Print item. Sends 
//	 * {@link org.actionstep.NSResponder#printDocument()} to 
//	 * {@link org.actionstep.NSWindow#firstResponder}, but you can change this 
//	 * in {@link NSToolbar#toolbarWillAddItem()} if you need to do so.
//	 */
//	public static var NSToolbarPrintItemIdentifier:String
//		= "print";
		
	/**
	 * The overflow button item.
	 */
	public static var ASToolbarOverflowItemIdentifier:String
		= "overflow";
		
	//******************************************************
	//*                Priority Constants
	//******************************************************
	
	/**
	 * The default visibility priority.
	 */
	public static var NSToolbarItemVisibilityPriorityStandard:Number = 50;
		
	/**
	 * Items with this priority will be the first items to be pushed to the 
	 * overflow menu.
	 */
	public static var NSToolbarItemVisibilityPriorityLow:Number	= 0;
	
	/**
	 * Items with this priority are less inclined to be pushed to the 
	 * overflow menu.
	 */
	public static var NSToolbarItemVisibilityPriorityHigh:Number = 100;
	
	/**
	 * Items with this priority are the last to be pushed to the overflow 
	 * menu. Only the user should set items to this priority.
	 */
	public static var NSToolbarItemVisibilityPriorityUser:Number = 150;
	 
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_itemIdentifier:String;
	private var m_toolbar:NSToolbar;
	private var m_label:String;
	private var m_paletteLabel:String;
	private var m_menuFormRepresentation:NSMenuItem;
	private var m_toolTip:String;
	private var m_tag:Number;
	private var m_target:Object;
	private var m_action:String;
	private var m_enabled:Boolean;
	private var m_image:NSImage;
	private var m_usingCustomView:Boolean;
	private var m_backView:NSView;
	private var m_view:NSView;
	private var m_minSize:NSSize;
	private var m_maxSize:NSSize;
	private var m_visibilityPriority:Number;
	private var m_autovalidates:Boolean;
	private var m_selectable:Boolean;
	private var m_selected:Boolean;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSToolbarItem</code> class.
	 */
	public function NSToolbarItem() {
		m_menuFormRepresentation = null;
		m_visibilityPriority = NSToolbarItemVisibilityPriorityStandard;
		m_autovalidates = true;
		m_enabled = true;
		m_usingCustomView = false;
		m_selected = m_selectable = false;
	}
	
	/**
	 * <p>Initialize the receiver with <code>itemIdentifier</code>, which is 
	 * used by the toolbar and its delegate to identify the kind of the 
	 * toolbar item.</p>
	 */
	public function initWithItemIdentifier(itemIdentifier:String):NSToolbarItem {		
		var view:NSView;
		switch (itemIdentifier) {
			case NSToolbarSeparatorItemIdentifier:
				if (getClass() != ASToolbarSeparatorItem) {
					return (new ASToolbarSeparatorItem()).initWithItemIdentifier(
						itemIdentifier);
				}
				break;
			case NSToolbarSpaceItemIdentifier:
				if (getClass() != ASToolbarSpaceItem) {
					return (new ASToolbarSpaceItem()).initWithItemIdentifier(
						itemIdentifier);
				}
				break;
			case NSToolbarFlexibleSpaceItemIdentifier:
				if (getClass() != ASToolbarFlexibleSpaceItem) {
					return (new ASToolbarFlexibleSpaceItem()).initWithItemIdentifier(
						itemIdentifier);
				}
				break;
		}
				
		m_itemIdentifier = itemIdentifier;
		constructBackView();
		
		return this;
	}
	
	/**
	 * Constructs the back view. Can be overridden to provide specific 
	 * functionality.  
	 */
	private function constructBackView():Void {
		var button:ASToolbarItemButton;
		var cell:NSButtonCell;
		button = (new ASToolbarItemButton()).initWithToolbarItem(this);
		cell = NSButtonCell(button.cell());
		button.setTitle("");
		button.setEnabled(m_enabled);
		button.setBordered(false);
		button.setImagePosition(NSCellImagePosition.NSImageAbove);
		cell.setBezeled(false);
		cell.setHighlightsBy(NSCell.NSChangeGrayCellMask 
			| NSCell.NSChangeBackgroundCellMask);
		m_backView = button;	
	}
	
	//******************************************************
	//*                    NSCopying
	//******************************************************
	
	public function copyWithZone():NSObject {
		var dup:NSToolbarItem = (new NSToolbarItem()).initWithItemIdentifier(
			m_itemIdentifier);
		dup.setTarget(m_target);
		dup.setAction(m_action);
		dup.setView(m_view);
		dup.setToolTip(m_toolTip);
		dup.setTag(m_tag);
		dup.setImage(m_image);
		dup.setEnabled(m_enabled);
		dup.setLabel(m_label);
		dup.setMinSize(m_minSize);
		dup.setMaxSize(m_maxSize);
		
		return dup;
	}
	
	//******************************************************
	//*              Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the NSToolbarItem instance.
	 */
	public function description():String {
		return "NSToolbarItem(itemIdentifier=" + itemIdentifier() + ")";
	}
	
	//******************************************************
	//*                Managing attributes
	//******************************************************
	
	/**
	 * Returns the receiver’s identifier, which was provided in the 
	 * initializer.
	 * 
	 * @see #initWithItemIdentifier()
	 */
	public function itemIdentifier():String{
		return m_itemIdentifier;
	}
	
	/**
	 * Returns the toolbar that is using the receiver.
	 */
	public function toolbar():NSToolbar{
		return m_toolbar;
	}
	
	/**
	 * <p>Returns the receiver’s label, which normally appears in the toolbar 
	 * and in the overflow menu.</p>
	 * 
	 * @see #setLabel()
	 * @see #menuFormRepresentation()
	 */
	public function label():String{
		return m_label;
	}
	
	/**
	 * <p>Sets the receiver’s label that appears in the toolbar to 
	 * <code>value</code>.</p>
	 * 
	 * <p>The implication is that the toolbar will draw the label for the 
	 * receiver, and a redraw is triggered by this method. The toolbar is in 
	 * charge of the label area. It’s OK for an item to have an empty label. 
	 * You should make sure the length of the label is appropriate and not too 
	 * long.</p>
	 * 
	 * @see #setLabel()
	 * @see #paletteLabel()
	 */
	public function setLabel(value:String):Void {
		m_label = value;
		
		if (m_backView instanceof NSButton) {
			NSButton(m_backView).setTitle(value);
		}
		
		if (m_toolbar != null) {
			m_toolbar.__toolbarView().reload();
		}
	}
	
	/**
	 * <p>Returns the label that appears when the receiver is in the 
	 * customization palette.</p>
	 * 
	 * <p>NOT SUPPORTED</p>
	 */
	public function paletteLabel():String{
		var e:NSException = NSException.exceptionWithNameReasonUserInfo(
			"NSNotSupportedException",
			"This property is not supported",
			null);
		trace(e);
		throw e;
		return m_paletteLabel;
	}
	
	/**
	 * <p>Sets the receiver’s label that appears when it is in the 
	 * customization palette to <code>value</code>.</p>
	 * 
	 * <p>NOT SUPPORTED</p>
	 */
	public function setPaletteLabel(value:String):Void {
		var e:NSException = NSException.exceptionWithNameReasonUserInfo(
			"NSNotSupportedException",
			"This property is not supported",
			null);
		trace(e);
		throw e;
		m_paletteLabel = value;
	}
	
	/**
	 * Returns the tooltip used when the receiver is displayed in the toolbar.
	 * 
	 * @see #setToolTip()
	 */
	public function toolTip():String{
		return m_toolTip;
	}
	
	/**
	 * Sets the tooltip to be used when the receiver is displayed in the 
	 * toolbar to <code>value</code>.
	 * 
	 * @see #toolTip()
	 */
	public function setToolTip(value:String):Void {
		if (m_view != null) {
			m_view.setToolTip(value);
		} else {
			m_backView.setToolTip(value);
		}
		
		m_toolTip = value;
	}
	
	/**
	 * <p>Returns the receiver’s menu form representation.</p>
	 * 
	 * <p>By default, this method returns <code>null</code>, even though there is 
	 * a default menu form representation.</p>
	 * 
	 * @see #setMenuFormRepresentation()
	 */
	public function menuFormRepresentation():NSMenuItem {
		return m_menuFormRepresentation;
	}
	
	/**
	 * <p>Sets the receiver’s menu form to <code>value</code>.</p>
	 * 
	 * @see #menuFormRepresentation()
	 */
	public function setMenuFormRepresentation(value:NSMenuItem):Void {
		m_menuFormRepresentation = value;
	}
	
	/**
	 * Returns the receiver’s tag, which can be used for your own custom 
	 * purpose.
	 * 
	 * @see #setTag()
	 */
	public function tag():Number{
		return m_tag;
	}
	
	/**
	 * Sets the receiver’s tag to <code>value</code>, which can be used for 
	 * your own custom purpose.
	 * 
	 * @see #tag()
	 */
	public function setTag(value:Number):Void {
		m_tag = value;
	}
	
	/**
	 * Returns the receiver’s target.
	 * 
	 * @see #setTarget()
	 */
	public function target():Object{
		return m_target;
	}
	
	/**
	 * <p>Sets the receiver’s target to <code>value</code>.</p>
	 * 
	 * <p>If target is unset, the toolbar will call {@link #action()} on the 
	 * first responder that implements it.</p>
	 * 
	 * <p>If the receiver's {@link #target()} is an instance of a class that
	 * implements {@link org.actionstep.toolbar.NSToolbarItemValidation}, 
	 * then {@link org.actionstep.toolbar.NSToolbarItemValidation#validateToolbarItem()}
	 * will be called by the toolbar to determine whether or not the item
	 * is enabled.</p>
	 * 
	 * @see #target()
	 */
	public function setTarget(value:Object):Void {
		m_target = value;
		
		if (!m_usingCustomView) {
			ASToolbarItemButton(m_backView).setTarget(m_target);
		}
		
		validate();
	}
	
	/**
	 * <p>Returns the receiver’s action.</p>
	 * 
	 * <p>For custom view items, this method sends {@link #action()} to the view 
	 * if it responds and returns the result.</p>
	 * 
	 * @see #setAction()
	 */
	public function action():String{
		if (m_usingCustomView && m_view != null && ASUtils.respondsToSelector(m_view, "action")) {
			return m_view["action"]();
		}
		
		return m_action;
	}
	
	/**
	 * <p>Sets the receiver’s action to <code>value</code>.</p>
	 * 
	 * <p>For a custom view item, this method calls {@link #setAction()} on 
	 * the view if it responds.</p>
	 * 
	 * @see #action()
	 */
	public function setAction(value:String):Void {
		if (m_usingCustomView) {
			if (m_view != null && ASUtils.respondsToSelector(m_view, "setAction")) {
				m_view["setAction"](value);
			}
		} else {
			ASToolbarItemButton(m_backView).setToolbarItemAction(value);
		}
		
		m_action = value;
	}
	
	/**
	 * <p>Returns the receiver’s enabled status.</p>
	 * 
	 * <p>For a view item, this method calls 
	 * {@link org.actionstep.NSControl#isEnabled()} on the view if it responds 
	 * and returns the result.</p>
	 * 
	 * @see #setEnabled()
	 */
	public function isEnabled():Boolean {
		if (m_usingCustomView && m_view != null && ASUtils.respondsToSelector(m_view, "isEnabled")) {
			return m_view["isEnabled"]();
		}
		
		return m_enabled;
	}
	
	/**
	 * <p>Sets the receiver’s enabled flag to <code>value</code>.</p>
	 * 
	 * <p>For a custom view item, this method calls 
	 * {@link org.actionstep.NSControl#setEnabled()} on the view if it 
	 * responds.</p>
	 * 
	 * @see #isEnabled()
	 */
	public function setEnabled(value:Boolean):Void {
		if (m_usingCustomView) {
			if (m_view != null && ASUtils.respondsToSelector(m_view, "setEnabled")) {
				m_view["setEnabled"](value);
			}
		} else {
			ASToolbarItemButton(m_backView).setEnabled(value);
		}
		
		m_enabled = value;
	}
	
	/**
	 * <p>Returns the image of the receiver.</p>
	 * 
	 * <p>For an image item this method returns the result of the most recent 
	 * {@link setImage()}. For view items, this method calls 
	 * <code>image()</code> on the view if it responds and returns the result.
	 * </p>
	 * 
	 * @see #setImage()
	 */
	public function image():NSImage{
		if (m_usingCustomView && m_view != null && ASUtils.respondsToSelector(m_view, "image")) {
			return m_view["image"]();
		}
		
		return m_image;
	}
	
	/**
	 * <p>Sets the receiver's image to <code>value</code>.</p>
	 * 
	 * <p>For a custom view item (one whose view has already been set), this 
	 * method calls <code>setImage()</code> on the view if it responds.</p>
	 * 
	 * @see #image()
	 * @see #view()
	 */
	public function setImage(value:NSImage):Void {
		if (m_usingCustomView) {
			if (m_view != null && ASUtils.respondsToSelector(m_view, "setImage")) {
				m_view["setImage"](value);
			}
		} else {
			value.setScalesWhenResized(true);
			ASToolbarItemButton(m_backView).setImage(value);
		}
		
		m_image = value;
	}
	
	/**
	 * <p>Returns the receiver’s view.</p>
	 * 
	 * <p>Note that many of the set/get methods are implemented by calls 
	 * forwarded to the NSView object referenced by this attribute, if the 
	 * object responds to it, like {@link #image()}, {@link #action()}, etc.</p>
	 * 
	 * @see #setView()
	 */
	public function view():NSView {
		if (!m_usingCustomView) {
			return null;
		}
		
		return m_view;
	}
	
	/**
	 * <p>Use this method to make the receiver into a view item.</p>
	 * 
	 * <p>Note that many of the set/get methods are implemented by calls 
	 * forwarded to the NSView object referenced by this attribute, if the 
	 * object responds to it, like {@link #image()}, {@link #action()}, etc.</p>
	 * 
	 * @see #view()
	 */
	public function setView(value:NSView):Void {
		m_view = value;
		var wasUsingCustom:Boolean = m_usingCustomView;
		m_usingCustomView = value != null;
		
		if (m_usingCustomView) {
			var sz:NSSize = m_view.frame().size;
			setMinSize(sz);
			setMaxSize(sz);
			
			if (!wasUsingCustom) {
				m_backView.removeFromSuperview();
				m_backView.release();
				
				m_backView = (new ASToolbarItemBackView()).initWithToolbarItem(
					this);
			}
		} else {
			setMinSize(null);
			setMaxSize(null);
				
			if (wasUsingCustom) {
				m_backView.removeFromSuperview();
				m_backView.release();
				
				m_backView = (new ASToolbarItemButton()).initWithToolbarItem(
					this);
			}
		}
	}
	
	/**
	 * Returns the receiver’s minimum size.
	 * 
	 * @see #setMinSize()
	 */
	public function minSize():NSSize{
		return m_minSize.clone();
	}
	
	/**
	 * Sets the receiver’s minimum size to <code>value</code>.
	 * 
	 * @see #minSize()
	 */
	public function setMinSize(value:NSSize):Void {
		m_minSize = value.clone();
	}
	
	/**
	 * Returns the receiver’s maximum size.
	 * 
	 * @see #setMaxSize()
	 */
	public function maxSize():NSSize{
		return m_maxSize.clone();
	}
	
	/**
	 * Sets the receiver’s maximum size to <code>value</code>.
	 * 
	 * @see #maxSize()
	 */
	public function setMaxSize(value:NSSize):Void {
		m_maxSize = value.clone();
	}
	
	//******************************************************
	//*               Visibility priority
	//******************************************************
	
	/**
	 * <p>Returns the receiver’s visibility priority.</p>
	 * 
	 * <p>This value is used to determine whether the item should be placed
	 * int the overflow menu or not.</p>
	 * 
	 * @see #setVisibilityPriority()
	 * @see #NSToolbarItemVisibilityPriorityStandard
	 * @see #NSToolbarItemVisibilityPriorityLow
	 * @see #NSToolbarItemVisibilityPriorityHigh
	 * @see #NSToolbarItemVisibilityPriorityUser
	 */
	public function visibilityPriority():Number{
		return m_visibilityPriority;
	}
	
	/**
	 * <p>Sets the receiver’s visibility priority to <code>value</code>.</p>
	 * 
	 * <p>This value is used to determine whether the item should be placed
	 * int the overflow menu or not.</p>
	 * 
	 * @see #visibilityPriority()
	 * @see #NSToolbarItemVisibilityPriorityStandard
	 * @see #NSToolbarItemVisibilityPriorityLow
	 * @see #NSToolbarItemVisibilityPriorityHigh
	 * @see #NSToolbarItemVisibilityPriorityUser
	 */
	public function setVisibilityPriority(value:Number):Void {
		m_visibilityPriority = value;
	}
	
	//******************************************************
	//*                   Validation
	//******************************************************
	
	/**
	 * <p>This method is called by the receiver’s toolbar during validation.</p>
	 */
	public function validate():Void {
		if (m_view != null) {
			return;
		}
		
		if (m_toolbar.displayMode() == NSToolbarDisplayMode.NSToolbarDisplayModeLabelOnly
				&& m_menuFormRepresentation != null) {
			if (ASUtils.respondsToSelector(m_target, "validateMenuItem")) {
				this.setEnabled(m_target.validateMenuItem(m_menuFormRepresentation));
			}		
		} else {
			if (ASUtils.respondsToSelector(m_target, "validateToolbarItem")) {
				setEnabled(m_target.validateToolbarItem(this));	
			}
		}
	}
	
	/**
	 * Returns whether the receiver is automatically validated by the toolbar.
	 * 
	 * @see #setAutovalidates()
	 */
	public function autovalidates():Boolean{
		return m_autovalidates;
	}
	
	/**
	 * <p>Sets the receiver’s auto validation flag to <code>value</code>.</p>
	 * 
	 * <p>By default NSToolbar automatically invokes the receiver’s 
	 * {@link #validate()} method on a regular basis. If your validate method is
	 * time consuming, you can disable auto validation on a per toolbar item 
	 * basis.</p>
	 * 
	 * @see #autovalidates()
	 */
	public function setAutovalidates(value:Boolean):Void {
		m_autovalidates = value;
	}
	
	//******************************************************
	//*             Getting special instances
	//******************************************************
	
	/**
	 * Creates and returns an instance of a separator item.
	 */
	public static function separatorItem():NSToolbarItem {
		return (new NSToolbarItem()).initWithItemIdentifier(
			NSToolbarSeparatorItemIdentifier);
	}
	
	/**
	 * Creates and returns an instance of a space item.
	 */
	public static function spaceItem():NSToolbarItem {
		return (new NSToolbarItem()).initWithItemIdentifier(
			NSToolbarSpaceItemIdentifier);
	}
	
	/**
	 * Creates and returns an instance of a flexible space item.
	 */
	public static function flexibleSpaceItem():NSToolbarItem {
		return (new NSToolbarItem()).initWithItemIdentifier(
			NSToolbarFlexibleSpaceItemIdentifier);
	}
	
//	/**
//	 * Creates and returns an instance of a show colors item.
//	 */
//	public static function showColorsItem():NSToolbarItem {
//		return (new NSToolbarItem()).initWithItemIdentifier(
//			NSToolbarShowColorsItemIdentifier);
//	}
//	
//	/**
//	 * Creates and returns an instance of a show fonts item.
//	 */
//	public static function showFontsItem():NSToolbarItem {
//		return (new NSToolbarItem()).initWithItemIdentifier(
//			NSToolbarShowFontsItemIdentifier);
//	}
//	
//	/**
//	 * Creates and returns an instance of a print item.
//	 */
//	public static function printItem():NSToolbarItem {
//		return (new NSToolbarItem()).initWithItemIdentifier(
//			NSToolbarPrintItemIdentifier);
//	}

	//******************************************************
	//*                 Internal properties
	//******************************************************
		
	/**
	 * For internal use only.
	 */
	public function __setToolbar(value:NSToolbar):Void {
		m_toolbar = value;
	}
	
	/**
	 * For internal use only.
	 */
	public function __layout():Void {
		ASToolbarItemBackViewProtocol(m_backView).layout();
	}
	
	/**
	 * For internal use only.
	 */
	public function __isFlexibleSpace():Boolean {
		return getClass() == ASToolbarFlexibleSpaceItem;
	}
	
	/**
	 * For internal use only.
	 */
	public function __selectable():Boolean {
		return m_selectable;
	}

	/**
	 * For internal use only.
	 */	
	public function __setSelectable(flag:Boolean):Void {		
		if (m_backView instanceof ASToolbarItemButton) {
			m_selectable = flag;
			
			ASToolbarItemButton(m_backView).setButtonType(m_selectable 
				? NSButtonType.NSOnOffButton
				: null);
		} else {
			trace(asWarning("The toolbar item " + this + " is not selectable"));
		}
	}
	
	/**
	 * For internal use only.
	 */
	public function __selected():Boolean {
		if (m_backView instanceof ASToolbarItemButton) {
			return ASToolbarItemButton(m_backView).state() == NSCell.NSOnState;
		}
		
		return m_selected;
	}
	
	/**
	 * For internal use only.
	 */
	public function __setSelected(flag:Boolean):Void {		
		if (m_selectable && !__selected() && flag) {
			if (m_backView.superview() != null) {
				ASToolbarItemButton(m_backView).performClick();
			} else {
				ASToolbarItemButton(m_backView).setState(NSCell.NSOnState);
			}
		}
		else if (!flag) {
			ASToolbarItemButton(m_backView).setState(NSCell.NSOffState);
			ASToolbarItemButton(m_backView).setNeedsDisplay(true);
		}
		else if (!m_selectable) {
			trace(asWarning("The toolbar item " + this + " is not selectable"));
		}
	}
	
	/**
	 * For internal use only.
	 */
	public function __backView():NSView {
		return m_backView;
	}
	
	/**
	 * Should be overridden by subclasses that support menu form.
	 */
	public function __defaultMenuFormRepresentation():NSMenuItem {
		var item:NSMenuItem = (new NSMenuItem()).initWithTitleActionKeyEquivalent(
			label(), null, "");
		item.setImage(image());
		item.setToolTip(toolTip());
		item.setEnabled(isEnabled());
		item.setRepresentedObject(this);
		item.setTarget(this);
		item.setAction("menuFormClicked");
		item.setTag(tag());
		
		return item;	
	}
	
	//******************************************************
	//*                   Menu action
	//******************************************************
	
	private function menuFormClicked(menuItem:NSMenuItem):Void {
		if (m_backView instanceof ASToolbarItemButton) {
			ASToolbarItemButton(m_backView).sendActionTo(action(), target());
		}
	}
}