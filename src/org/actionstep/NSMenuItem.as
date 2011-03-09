/* See LICENSE for copyright and terms of use */

import org.actionstep.menu.ASMenuSeparator;
import org.actionstep.NSCell;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSImage;
import org.actionstep.NSMenu;
import org.actionstep.NSObject;
import org.actionstep.NSUserDefaults;

/**
 * An item in an <code>NSMenu</code>.
 *
 * @author Tay Ray Chuan
 */
class org.actionstep.NSMenuItem extends NSObject {
	
	//******************************************************
	//*                    Class members
	//******************************************************
	
	//
	// Exceptions are thrown if usage of state images or key equivalents is
	// attempted.
	//
	private static var g_rootHasNoStateException:NSException;
	private static var g_rootHasNoKeyEquivalent:NSException;
	private static var g_menuHasNoKeyEquivalent:NSException;

	private static var g_usesUserKeyEquivalents:Boolean = false;

	//******************************************************
	//*                      Members
	//******************************************************
	
	private var m_keyEquivalentModifierMask:Number;
	private var	m_keyEquivalent:String;
	private var	m_state:Number;
	private var	m_enabled:Boolean;
	private var	m_action:String;
	private var	m_target:Object;
	private var	m_tag:Number;
	private var	m_representedObject:Object;
	private var	m_title:String;
	private var	m_changesState:Boolean;
	private var m_isSeparator:Boolean;
	private var m_toolTip:String;
	
	//Menus
	private var	m_menu:NSMenu;
	private var	m_submenu:NSMenu;

	//Images
	private var	m_image:NSImage;
	private var	m_onStateImage:NSImage;
	private var	m_offStateImage:NSImage;
	private var	m_mixedStateImage:NSImage;

	//******************************************************
	//*                    Construction
	//******************************************************
	
	/**
	 * <p>Creates a new instance of the <code>NSMenuItem</code> class.</p>
	 * 
	 * <p>Follow this method with a call to {@link #init()} or
	 * {@link #initWithTitleActionKeyEquivalent()}</p>
	 */
	public function NSMenuItem() {
	}

	/**
	 * Initializes the menu item with no title, action or key equivalent.
	 * 
	 * @see #initWithTitleActionKeyEquivalent()
	 */
	public function init():NSMenuItem {
		return initWithTitleActionKeyEquivalent("", null, "");
	}

	/**
	 * <p>Returns an initialized instance of an <code>NSMenuItem</code>.</p>
	 * 
	 * <p>The arguments <code>itemName</code> and <code>charCode</code> must not 
	 * be <code>null</code> (if there is no title or key equivalent, specify an 
	 * empty string). The <code>anAction</code> argument must be a valid 
	 * selector or <code>null</code>. For instances of the 
	 * <code>NSMenuItem</code> class, the default initial state is 
	 * {@link NSCell#NSOffState}, the default on-state image is a checkmark, and 
	 * the default mixed-state image is a dash.</p>
	 */
	public function initWithTitleActionKeyEquivalent(aString:String, aSelector:String, charCode:String):NSMenuItem {
		setTitle(aString);
		setKeyEquivalent(charCode);
		m_keyEquivalentModifierMask = NSEvent.NSCommandKeyMask;
		m_state = NSCell.NSOffState;
		m_enabled = true;
		m_isSeparator = false;
		// Set the images according to the spec. On: check mark; off: dash.
		setOnStateImage(NSImage.imageNamed("NSMenuItemOnState"));
		setMixedStateImage(NSImage.imageNamed("NSMenuItemMixedState"));
		setOffStateImage(NSImage.imageNamed("NSMenuItemOffState"));
		m_action = aSelector;
		return this;
	}

	//******************************************************
	//*              Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the <code>NSMenuItem</code> instance.
	 */
	public function description():String {
		return "NSMenuItem("+m_title+")";
	}
	
	//******************************************************
	//*              Enabling a menu item
	//******************************************************
	
	/**
	 * <p>Sets whether the receiver is enabled based on <code>flag</code>.</p>
	 * 
	 * <p>If a menu item is disabled, its keyboard equivalent is also disabled.</p>
	 * 
	 * @see #isEnabled()
	 */
	public function setEnabled(flag:Boolean):Void {
		if (flag == m_enabled) {
			return;
		}

		m_enabled = flag;
		m_menu.itemChanged(this);
	}

	/**
	 * Returns <code>true</code> if the receiver is enabled, <code>false</code> 
	 * if not.
	 */
	public function isEnabled():Boolean {
		return m_enabled;
	}
	
	//******************************************************
	//*             Setting the target and action
	//******************************************************
	
	/**
	 * Sets the receiver's target to <code>anObject</code>.
	 * 
	 * @see #target()
	 * @see #setAction()
	 */
	public function setTarget(anObject:Object):Void {
		if (m_target == anObject) {
			return;
		}

		m_target = anObject;
		m_menu.itemChanged(this);
	}

	/**
	 * Returns the receiver's target.
	 * 
	 * @see #action()
	 * @see #setTarget()
	 */
	public function target():Object {
		return m_target;
	}

	/**
	 * Sets the receiver's action method to <code>aSelector</code>.
	 * 
	 * @see #action()
	 * @see #setTarget()
	 */
	public function setAction(aSelector:String):Void {
		if (m_action == aSelector) {
			return;
		}

		m_action = aSelector;
		m_menu.itemChanged(this);
	}

	/**
	 * Returns the receiver's action method.
	 * 
	 * @see #setAction()
	 * @see #target()
	 */
	public function action():String {
		return m_action;
	}
	
	//******************************************************
	//*                 Setting the title
	//******************************************************
	
	/**
	 * Sets the receiver's title to <code>aString</code>.
	 * 
	 * @see #title()
	 * @see #setAttributedTitle()
	 */
	public function setTitle(aString:String):Void{
		if (aString==null)	aString = "";

		m_title = aString;
		m_menu.itemChanged(this);
	}

	/**
	 * Returns the receiver's title.
	 * 
	 * @see #setTitle()
	 */
	public function title():String {
		return m_title;
	}
	
	//! TODO setAttributedTitle()
	//! TODO attributedTitle()
	
	//******************************************************
	//*                  Setting the tag
	//******************************************************
	
	/**
	 * Sets the receiver's tag to <code>anInt</code>.
	 * 
	 * @see #setRepresentedObject()
	 * @see #tag()
	 */
	public function setTag(anInt:Number):Void {
		m_tag = anInt;
	}

	/**
	 * Returns the receiver's tag.
	 * 
	 * @see #representedObject()
	 * @see #setTag()
	 */
	public function tag():Number {
		return m_tag;
	}
	
	//******************************************************
	//*                 Setting the state
	//******************************************************
	
	/**
	 * <p>Sets the state of the receiver to itemState, which should be one of 
	 * {@link NSCell#NSOffState}, {@link NSCell#NSOnState}, or 
	 * {@link NSCell#NSMixedState}.</p>
	 * 
	 * <p>The image associated with the new state is displayed to the left of the 
	 * menu item.</p>
	 * 
	 * @see #state()
	 * @see #setMixedStateImage()
	 * @see #setOffStateImage()
	 * @see #setOnStateImage()
	 */
	public function setState(state:Number):Void {
		if(menu().isRoot()) {
			trace(g_rootHasNoStateException);
			throw g_rootHasNoStateException;
		}
		m_changesState = true;
		if (m_state == state) {
			return;
		}

		m_state = state;
		m_menu.itemChanged(this);
	}

	/**
	 * Returns the state of the receiver, which is {@link NSCell#NSOffState} 
	 * (the default), {@link NSCell#NSOnState}, or {@link NSCell#NSMixedState}.
	 * 
	 * @see #setState()
	 */
	public function state():Number {
		return m_state;
	}
	
	//******************************************************
	//*                  Setting the image
	//******************************************************
	
	/**
	 * <p>Sets the receiver's image to <code>menuImage</code>.</p>
	 * 
	 * <p>If <code>menuImage</code> is <code>null</code>, the current image (if
	 * any) is removed. This image is not affected by changes in menu-item 
	 * state.</p>
	 * 
	 * @see #image()
	 */
	public function setImage(image:NSImage):Void {
		m_image = image;
		m_menu.itemChanged(this);
	}

	/**
	 * <p>Returns the image displayed by the receiver, or <code>null</code> if it
	 * displays no image.</p>
	 * 
	 * @see #setImage()
	 */
	public function image():NSImage {
		return m_image;
	}
	
	/**
	 * <p>Sets the image of the receiver that indicates an "on" state.</p>
	 * 
	 * <p>If <code>itemImage</code> is <code>null</code>, any current on-state 
	 * image is removed.</p>
	 * 
	 * @see #onStateImage()
	 * @see #setMixedStateImage()
	 * @see #setOffStateImage()
	 * @see #setState()
	 */
	public function setOnStateImage(image:NSImage):Void {
		if(menu().isRoot()) {
			trace(g_rootHasNoStateException);
			throw g_rootHasNoStateException;
		}
		m_onStateImage = image;
		m_menu.itemChanged(this);
	}

	/**
	 * <p>Returns the image used to depict the receiver's "on" state, or 
	 * <code>null</code> if the image has not been set.</p>
	 * 
	 * <p>By default this image is a checkmark.</p>
	 * 
	 * @see #setOnStateImage()
	 */
	public function onStateImage():NSImage {
		return m_onStateImage;
	}

	/**
	 * <p>Sets the image of the receiver that indicates an "off" state.</p>
	 * 
	 * <p>If <code>itemImage</code> is <code>null</code>, any current off-state 
	 * image is removed.</p>
	 * 
	 * @see #offStateImage()
	 * @see #setMixedStateImage()
	 * @see #setOnStateImage()
	 * @see #setState()
	 */
	public function setOffStateImage(image:NSImage):Void {
		if(menu().isRoot()) {
			trace(g_rootHasNoStateException);
			throw g_rootHasNoStateException;
		}
		m_offStateImage = (image==null) ? null : image;
		m_menu.itemChanged(this);
	}

	/**
	 * <p>Returns the image used to depict the receiver's "off" state, or 
	 * <code>null</code> if the image has not been set.</p>
	 * 
	 * <p>By default there is no image.</p>
	 * 
	 * @see #setOffStateImage()
	 */
	public function offStateImage():NSImage {
		return m_offStateImage;
	}

	/**
	 * <p>Sets the image of the receiver that indicates an "mixed" state.</p>
	 * 
	 * <p>If <code>itemImage</code> is <code>null</code>, any current mixed-state 
	 * image is removed.</p>
	 * 
	 * @see #mixedStateImage()
	 * @see #setOnStateImage()
	 * @see #setOffStateImage()
	 * @see #setState()
	 */
	public function setMixedStateImage(image:NSImage):Void {
		if(menu().isRoot()) {
			trace(g_rootHasNoStateException);
			throw g_rootHasNoStateException;
		}
		m_mixedStateImage = image;
		m_menu.itemChanged(this);
	}

	/**
	 * <p>Returns the image used to depict a "mixed state."</p>
	 * 
	 * <p>A mixed state is useful for indicating "off" and "on" attribute values
	 * in a group of selected objects, such as a selection of text containing 
	 * boldface and plain (nonboldface) words. By default this is a horizontal 
	 * line.</p>
	 * 
	 * @see #setMixedStateImage()
	 */
	public function mixedStateImage():NSImage {
		return m_mixedStateImage;
	}
	
	//******************************************************
	//*                 Managing submenus
	//******************************************************
	
	/**
	 * <p>Sets the submenu of the receiver to <code>aSubmenu</code>.</p>
	 * 
	 * <p>The default implementation of the <code>NSMenuItem</code> class raises 
	 * an exception if <code>aSubmenu</code> already has a supermenu.</p>
	 * 
	 * @see #submenu()
	 * @see #hasSubmenu()
	 */
	public function setSubmenu(submenu:NSMenu):Void {
		if (submenu.superMenu() != null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"Submenu ("+submenu.title()+") already has superMenu (" + 
				submenu.superMenu().title()+")",
				null);
			trace(e);
			e.raise();
		}
		setKeyEquivalent("", true);
		m_submenu = submenu;
		if (submenu != null) {
			submenu.setSupermenu(m_menu);
			submenu.setTitle(m_title);
		}
		setTarget(m_menu);
		setAction("submenuAction");
		m_menu.itemChanged(this);
	}

	/**
	 * <p>Returns the submenu associated with the receiving menu item, or 
	 * <code>null</code> if no submenu is associated with it.</p>
	 * 
	 * <p>If the {@link #hasSubmenu()} returns <code>true</code>, a submenu is
	 * returned.</p>
	 * 
	 * @see #setSubmenu()
	 * @see #hasSubmenu()
	 */
	public function submenu():NSMenu {
		if (hasSubmenu()) {
			return m_submenu;
		}
		return null;
	}

	/**
	 * Returns <code>true</code> if the receiver has a submenu, 
	 * <code>false</code> if it doesn't.
	 * 
	 * @see NSMenu#setSubmenuForItem()
	 */
	public function hasSubmenu():Boolean {
		return !(m_submenu == null);
	}
	
	//******************************************************
	//*              Getting a separator item
	//******************************************************
	
	/**
	* <p>Returns a menu item that is used to separate logical groups of menu 
	* commands.</p>
	* 
	* <p>This menu item is disabled.</p>
	* 
	* @see #isSeparatorItem()
	* @see #setEnabled()
	*/
	public static function separatorItem():NSMenuItem {
		return (new ASMenuSeparator()).init();
	}
	
	/**
	 * Returns whether the receiver is a separator item (that is, a menu item 
	 * used to visually segregate related menu items).
	 * 
	 * @see #separatorItem()
	 */
	public function isSeparatorItem():Boolean {
		return m_isSeparator;
	}
	
	//******************************************************
	//*              Setting the owning menu
	//******************************************************
	
	/**
	 * <p>Sets the receiver's menu to <code>aMenu</code>.</p>
	 * 
	 * <p>This method is invoked by the owning <code>NSMenu</code> when the 
	 * receiver is added or removed. You shouldn't have to invoke this method in
	 * your own code, although it can be overridden to provide specialized 
	 * behavior.</p>
	 * 
	 * @see #menu()
	 */
	public function setMenu(menu:NSMenu):Void {
		m_menu = menu;
		if(menu.isRoot() && m_keyEquivalent!="") {
			trace(asWarning("clearing key equivalent..."));
			m_keyEquivalent = "";
		}
		if (m_submenu != null) {
			m_submenu.setSupermenu(menu);
			setTarget(m_menu);
		}
	}

	/**
	 * Returns the menu to which the receiver belongs, or <code>null</code> if 
	 * no menu has been set.
	 * 
	 * @see #setMenu()
	 */
	public function menu():NSMenu {
		return m_menu;
	}

	//******************************************************
	//*              Managing key equivalents
	//******************************************************

	/**
	 * <p>Sets the receiver's unmodified key equivalent to 
	 * <code>aKeyEquivalent</code>.</p>
	 * 
	 * <p>If you want to remove the key equivalent from a menu item, pass an 
	 * empty string <code>""</code> for <code>aString</code> (never pass 
	 * <code>null</code>). Use {@link #setKeyEquivalentModifierMask()} to set 
	 * the appropriate mask for the modifier keys for the key equivalent.</p>
	 * 
	 * <p>TODO document toClear</p>
	 * 
	 * @see #keyEquivalent()
	 */
	public function setKeyEquivalent(aKeyEquivalent:String, toClear:Boolean):Void {
		if(m_menu.isRoot() && toClear!=true) {
			trace(g_rootHasNoKeyEquivalent);
			throw g_rootHasNoKeyEquivalent;
		}
		if(hasSubmenu()) {
			trace(g_menuHasNoKeyEquivalent);
			throw g_menuHasNoKeyEquivalent;
		}
		if (aKeyEquivalent == null) {
			aKeyEquivalent = "";
		}

		m_keyEquivalent = aKeyEquivalent;
		m_menu.itemChanged(this);
	}

	/**
	 * <p>Returns the receiver's unmodified keyboard equivalent, or the empty 
	 * string if one hasn't been defined.</p>
	 * 
	 * <p>Use {@link keyEquivalentModifierMask()} to determine the modifier mask 
	 * for the key equivalent.</p>
	 * 
	 * @see #userKeyEquivalent()
	 * @see #setKeyEquivalent()
	 */
	public function keyEquivalent():String {
		if (usesUserKeyEquivalents()) {
			return userKeyEquivalent();
		} else {
			return m_keyEquivalent;
		}
	}

	/**
	 * <p>Sets the receiver's keyboard equivalent modifiers (indicating 
	 * modifiers such as the Shift or Option keys) to those in mask.</p>
	 * 
	 * <p><code>mask</code> is an integer bit field containing any of these 
	 * modifier key masks, combined using the bitwise OR operator:</p>
	 * <ul>
	 * <li>{@link NSEvent#NSShiftKeyMask}</li>
	 * <li>{@link NSEvent#NSAlternateKeyMask}</li>
	 * <li>{@link NSEvent#NSCommandKeyMask}</li>
	 * <li>{@link NSEvent#NSControlKeyMask}</li>
	 * </ul>
	 * <p>You should always set {@link NSEvent#NSCommandKeyMask} in mask.</p>
	 * 
	 * @see #keyEquivalentModifierMask()
	 */
	public function setKeyEquivalentModifierMask(mask:Number):Void {
		m_keyEquivalentModifierMask = mask;
		
		m_menu.itemChanged(this);
	}

	/**
	 * Returns the receiver's keyboard equivalent modifier mask.
	 * 
	 * @see #setKeyEquivalentModifierMask()
	 */
	public function keyEquivalentModifierMask():Number {
		return m_keyEquivalentModifierMask;
	}

	//******************************************************
	//*            Managing user key equivalents
	//******************************************************
	
	/**
	 * <p>If <code>flag</code> is <code>true</code>, menu items conform to user 
	 * preferences for key equivalents; otherwise, the key equivalents 
	 * originally assigned to the menu items are used.</p>
	 * 
	 * @see #usesUserKeyEquivalents()
	 * @see #userKeyEquivalent()
	 */
	public static function setUsesUserKeyEquivalents(flag:Boolean):Void {
		g_usesUserKeyEquivalents = flag;
	}

	/**
	 * Returns <code>true</code> if menu items conform to user preferences for 
	 * key equivalents; otherwise, returns <code>false</code>.
	 * 
	 * @see #setUsesUserKeyEquivalents()
	 * @see #userKeyEquivalent()
	 */
	public static function usesUserKeyEquivalents():Boolean {
		return g_usesUserKeyEquivalents;
	}
	
	/**
	 * Returns the user-assigned key equivalent for the receiver.
	 * 
	 * @see #keyEquivalent()
	 */
	public function userKeyEquivalent():String {
		var userKeyEquivalent:String = //NSDictionary(
		NSUserDefaults.standardUserDefaults().objectForKey("NSCommandKeys")
			.objectForKey(m_title);

		if ( userKeyEquivalent == null) {
			userKeyEquivalent = "";
		}

		return userKeyEquivalent;
	}

	/**
	 * <p>Returns the modifier mask for the user-assigned key equivalent.</p>
	 * 
	 * <p>This method is ActionStep-only.</p>
	 */
	public function userKeyEquivalentModifierMask():Number {
		return NSEvent.NSCommandKeyMask;
	}

	//******************************************************
	//*                Managing alternates
	//******************************************************
	
	/**
	 * <p>Marks the receiver as an alternate to the previous menu item.</p>
	 * 
	 * <p>If the receiver has the same key equivalent as the previous item, but 
	 * has different key equivalent modifiers, the items are folded into a 
	 * single visible item and the appropriate item shows while tracking the 
	 * menu. The menu items may also have no key equivalent as long as the key 
	 * equivalent modifiers are different.</p>
	 * 
	 * <p>If there are two or more items with no key equivalent but different 
	 * modifiers, then the only way to get access to the alternate items is 
	 * with the mouse. If you mark items as alternates but their key 
	 * equivalents don't match, they might be displayed as separate items. 
	 * Marking the first item as an alternate has no effect.</p>
	 * 
	 * @see #isAlternate()
	 */
	//! TODO setAlternate()
	
	/**
	 * Returns whether the receiver is an alternate to the previous menu item.
	 * 
	 * @see #setAlternate()
	 */
	//! TODO isAlternate()
	
	//******************************************************
	//*            Managing indentation levels
	//******************************************************
	
	//! TODO setIndentationLevel()
	//! TODO indentationLevel()
	
	//******************************************************
	//*               Managing tool tips
	//******************************************************
	
	/**
	 * <p>Sets a help tag for a menu item.</p>
	 * 
	 * <p>You can call this method for any menu item, including items in the 
	 * main menu bar.</p>
	 * 
	 * <p>This string is not archived in the old nib format.</p>
	 * 
	 * @see #toolTip()
	 */
	public function setToolTip(toolTip:String):Void {
		m_toolTip = toolTip;
		
		// FIXME implement this
	}
	
	/**
	 * <p>Returns the help tag for a menu item.</p>
	 * 
	 * @see #setToolTip()
	 */
	public function toolTip():String {
		return m_toolTip;
	}
			
	//******************************************************
	//*              Representing an object
	//******************************************************
	
	/**
	 * <p>Sets the object represented by the receiver to <code>anObject</code>.</p>
	 * 
	 * <p>By setting a represented object for a menu item, you make an 
	 * association between the menu item and that object. The represented object 
	 * functions as a more specific form of tag that allows you to associate any 
	 * object, not just an int, with the items in a menu.</p>
	 * 
	 * <p>For example, an NSView object might be associated with a menu 
	 * item—when the user chooses the menu item, the represented object is 
	 * fetched and displayed in a panel. Several menu items might control the 
	 * display of multiple views in the same panel.</p>
	 * 
	 * @see #setTag()
	 * @see #representedObject()
	 */
	public function setRepresentedObject(anObject:Object):Void {
		m_representedObject = anObject;
	}

	/**
	 * <p>Returns the object that the receiving menu item represents.</p>
	 * 
	 * <p>For example, you might have a menu list the names of views that are 
	 * swapped into the same panel. The represented objects would be the 
	 * appropriate NSView objects. The user would then be able to switch back 
	 * and forth between the different views that are displayed by selecting the
	 * various menu items.</p>
	 * 
	 * @see #setTag()
	 * @see #setRepresentedObject()
	 */
	public function representedObject():Object {
		return m_representedObject;
	}
	
	/**
	 * AS-specific function.<br/>
	 * Returns the current state image.
	 */
	public function stateImage():NSImage {
		if(!m_changesState) {
			return null;
		}
		switch(m_state) {
		  case NSCell.NSOnState:
		    return onStateImage();
		  case NSCell.NSMixedState:
		    return mixedStateImage();
		  case NSCell.NSOffState:
		  default:
		    return offStateImage();
		}
	}

	public function setChangesState(n:Boolean):Void {
		m_changesState = n;
	}

	public function changesState():Boolean {
		return m_changesState;
	}
	
	//******************************************************
	//*                Class constructor
	//******************************************************
	
	/**
	 * Called when the application begins.
	 */
	private static function initialize():Void {
		//
		// Build some special exceptions
		//
		g_rootHasNoStateException = NSException.exceptionWithNameReasonUserInfo(
			"ASRootMenuException", 
			"Root menu cannot display state", null);

		g_rootHasNoKeyEquivalent = NSException.exceptionWithNameReasonUserInfo(
			"ASRootMenuException", 
			"Root menu cannot display key equivalent", null);

		g_menuHasNoKeyEquivalent = NSException.exceptionWithNameReasonUserInfo(
			"ASRootMenuException", 
			"Menu with submenus cannot display key equivalent", null);
	}
}