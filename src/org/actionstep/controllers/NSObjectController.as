/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.binding.ASBindingDescriptor;
import org.actionstep.constants.NSBindingDescription;
import org.actionstep.controllers.ASObjectProxy;
import org.actionstep.controllers.NSController;
import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSMenuItem;

/**
 * <code>NSObjectController</code> is a bindings compatible controller class. 
 * Properties of the content object of an instance of this class can be bound to
 * user interface elements to access and modify their values.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.controllers.NSObjectController extends NSController {
	
	private static var g_exposedBindings:NSArray;
	
	private var m_content:Object;
	private var m_objectClass:Function;
	private var m_editable:Boolean;
	private var m_selectionProxy:ASObjectProxy;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSObjectController</code> class.
	 */
	public function NSObjectController() {
		m_objectClass = NSDictionary;
		m_editable = true;
		m_selectionProxy = (new ASObjectProxy()).init();
	}
	
	/**
	 * Initializes and returns an <code>NSObjectController</code> object with 
	 * the specified content.
	 */
	public function initWithContent(content:Object):NSObjectController {
		super.init();
		setContent(content);
		
		return this;
	}
	
	//******************************************************
	//*                Managing content
	//******************************************************
	
	/**
	 * <p>Sets this controllers content to <code>content</code>.</p>
	 * 
	 * @see #content()
	 */
	public function setContent(content:Object):Void {
		if (m_content != null) {
			unregisterContent(m_content);
		}
		
		m_content = content;
		
		if (m_content != null) {
			registerContent(m_content);
		}
	}
	
	/**
	 * <p>Returns this controller's content.</p>
	 * 
	 * <p>This property is observable using key-value observing.</p>
	 * 
	 * @see #setContent()
	 */
	public function content():Object {
		return m_content;
	}
	
	//******************************************************
	//*             Setting the content class
	//******************************************************
	
	/**
	 * <p>
	 * Sets the object class used when creating new objects to
	 * <code>objectClass</code>.
	 * </p>
	 * <p>
	 * <code>NSObjectController</code>’s default implementation assumes that 
	 * instances of <code>objectClass</code> are initialized using a standard 
	 * <code>#init</code> method that takes no arguments.
	 * </p>
	 */
	public function setObjectClass(objectClass:Function):Void {
		m_objectClass = objectClass;
	}
	
	/**
	 * <p>Returns the class used when creating new objects.</p>
	 * 
	 * <p>The default class is <code>NSDictionary</code>.</p>
	 * 
	 * <p>This property is observable using key-value observing.</p>
	 */
	public function objectClass():Function {
		return m_objectClass;
	}
	
	//******************************************************
	//*               Managing objects
	//******************************************************
	
	/**
	 * <p>
	 * Creates and returns a new object of the class specified by 
	 * <code>#objectClass()</code>.
	 * </p>
	 */
	public function newObject():Object {
		var obj:Object = ASUtils.createInstanceOf(objectClass(), []);
		obj.init();
		
		return obj;
	}
	
	/**
	 * <p>Sets <code>object</code> as the controller’s content object.</p>
	 * 
	 * <p>
	 * If the controller's content is bound to another object or controller 
	 * through a relationship key, the relationship of the 'master' object is 
	 * changed.
	 * </p>
	 */
	public function addObject(object:Object):Void {
		if (!canAdd()) {
			return;
		}
		
		setContent(object);
	}
	
	/**
	 * If <code>object</code> is the controller’s content object, the 
	 * controller’s content is set to <code>null</code>.
	 * 
	 * If the controller's content is bound to another object or controller 
	 * through a relationship key, the relationship of the 'master' object is 
	 * cleared.
	 */
	public function removeObject(object:Object):Void {
		if (!canRemove()) {
			return;
		}
		
		var equal:Boolean = false;
		
		if (ASUtils.respondsToSelector(object, "isEqual")) {
			equal = object.isEqual(content());
		} else {
			equal = object == content();
		}
		
		if (equal) {
			setContent(null);
		}
		
		// TODO deal with case where content is already bound to another
		// "master" object. Break the binding.
	}
	
	/**
	 * Creates a new object of the class specified by <code>#objectClass</code> 
	 * and sets it as the controller’s content object using 
	 * <code>#addObject</code>.
	 * 
	 * The <code>sender</code> is typically the object that invoked this method.
	 * 
	 * @see #canAdd
	 */
	public function add(sender:Object):Void {		
		addObject(newObject());
	}
	
	/**
	 * <p>
	 * Returns <code>true</code> if an object can be added to the controller 
	 * using <code>#add</code>.
	 * </p>
	 * <p>
	 * Bindings can use this method to control the enabling of user interface 
	 * objects.
	 * </p>
	 * <p>
	 * This property is observable using key-value observing.
	 * </p>
	 */
	public function canAdd():Boolean {
		return m_editable;
	}
	
	/**
	 * Removes the controller’s content object using <code>#removeObject</code>.
	 */
	public function remove():Void {
		removeObject(content());
	}
	
	/**
	 * <p>
	 * Returns <code>true</code> if an object can be removed from the controller 
	 * using <code>#remove</code>.
	 * </p>
	 * <p>
	 * Bindings can use this method to control the enabling of user interface 
	 * objects.
	 * </p>
	 * <p>
	 * This property is observable using key-value observing.
	 * </p>
	 */
	public function canRemove():Boolean {
		return m_editable;
	}
	
	//******************************************************
	//*                 Managing editing
	//******************************************************
	
	/**
	 * <p>Sets whether the controller allows adding and removing objects.</p>
	 * 
	 * <p>The default is <code>true</code>.</p>
	 */
	public function setEditable(flag:Boolean):Void {
		m_editable = flag;
	}
	
	/**
	 * <p>
	 * Returns <code>true</code> if the controller allows adding and removing 
	 * objects.
	 * </p>
	 * <p>
	 * This property is observable using key-value observing.
	 * </p>
	 */
	public function isEditable():Boolean {
		return m_editable;
	}
	
	//******************************************************
	//*                Obtaining selections
	//******************************************************
	
	/**
	 * <p>Returns an array of all objects to be affected by editing.</p>
	 * <p>This property is observable using key-value observing.</p>
	 */
	public function selectedObjects():NSArray {
		return NSArray.arrayWithObject(content());
	}
	
	/**
	 * <p>Returns a proxy object representing the controller’s selection.</p>
	 * <p>This property is observable using key-value observing.</p>
	 */
	public function selection():Object {
		
		return null;
	}
	
	//******************************************************
	//*               Validating menu items
	//******************************************************
	
	/**
	 * Validates menu item <code>anItem</code>, returning <code>true</code> if 
	 * it should be enabled, <code>false</code> otherwise.
	 * 
	 * For example, if <code>#canAdd</code> returns <code>false</code>, menu 
	 * items with the <code>#add</code> action and this controller as the target 
	 * object are disabled.
	 */
	public function validateMenuItem(anItem:NSMenuItem):Boolean {
		var targ:Object = anItem.target();
		var action:String = anItem.action();
		
		if (targ != this) {
			return true;
		}
		
		switch (action) {
			case "add":
				return canAdd();
				break;
				
			case "remove":
				return canRemove();
				break;
				
		}
		
		return true;
	}
	
	//******************************************************
	//*                Object registration  
	//******************************************************
	
	/**
	 * Unregisters a content object from the controller.
	 */
	private function unregisterContent(object:Object):Void {
		m_selectionProxy.setContent(null);
	}
	
	/**
	 * Registers a new content object to the controller.
	 */
	private function registerContent(object:Object):Void {
		m_selectionProxy.setContent(object);
	}
	
	//******************************************************
	//*              Creating object proxies
	//******************************************************
	
	/**
	 * Returns a key-value compliant proxy of the supplied object.
	 */
	private function buildObjectProxy(object:Object):Object {
		return null;
	}
	
	//******************************************************
	//*              NSKeyValueBindingCreation
	//******************************************************
	
	/**
	 * Returns the bindings exposed by this class.
	 */
	public static function exposedBindingsForClass():NSArray {
		return g_exposedBindings;
	}
	
	//******************************************************
	//*                Static construction
	//******************************************************
	
	/**
	 * Initializes the class.
	 */
	private static function initialize():Void {
		g_exposedBindings = new NSArray();
		
		g_exposedBindings.addObject(
			ASBindingDescriptor.bindingDescriptorWithDescriptionReadOnlyOptions(
				NSBindingDescription.NSEditableBinding,
				true,
				null
			));
			
		g_exposedBindings.addObject(
			ASBindingDescriptor.bindingDescriptorWithDescriptionReadOnlyOptions(
				NSBindingDescription.NSContentObjectBinding,
				false,
				null
			));
	}
}