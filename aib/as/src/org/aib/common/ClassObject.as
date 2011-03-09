import org.aib.AIBObject;
import org.actionstep.NSArray;
import org.aib.common.Outlet;

/**
 * <p>Represents a class shown in the class resource tab.</p>
 * 
 * <p>When a new class is created by the user, an associated ClassObject is
 * also created.</p>
 * 
 * @author Scott Hyndman
 */
class org.aib.common.ClassObject extends AIBObject {
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_name:String;
	private var m_package:String;
	private var m_superclass:ClassObject;
	private var m_subclasses:NSArray;
	private var m_outlets:NSArray;
	private var m_actions:NSArray;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ClassObject</code> class.
	 */
	public function ClassObject() {
		m_subclasses = NSArray.array();
		m_outlets = NSArray.array();
		m_actions = NSArray.array();
	}
	
	/**
	 * Initializes the class object.
	 */
	public function init():ClassObject {
		super.init();
		return this;
	}
	
	//******************************************************
	//*        Getting information about the class
	//******************************************************
	
	public function name():String {
		return m_name;
	}
	
	public function package():String {
		return m_package;
	}
	
	public function superclass():ClassObject {
		return m_superclass;
	}
	
	//******************************************************
	//*             Working with subclasses
	//******************************************************
	
	public function subclasses():NSArray {
		return m_subclasses;
	}
	
	public function addSubclass(clz:ClassObject):Void {
		m_subclasses.addObject(clz);
	}
	
	public function removeSubclass(clz:ClassObject):Void {
		m_subclasses.removeObject(clz);
	}
	
	//******************************************************
	//*              Working with outlets
	//******************************************************
	
	public function outlets():NSArray {
		return m_outlets;
	}
	
	public function addOutlet(outlet:Outlet):Void {
		m_outlets.addObject(outlet);
	}
	
	public function removeOutlet(outlet:Outlet):Void {
		m_outlets.removeObject(outlet);
	}
	
	//******************************************************
	//*               Working with actions
	//******************************************************
	
	public function actions():NSArray {
		return m_actions;
	}
	
	public function addAction(action:String):Void {
		m_actions.addObject(action);
	}
	
	public function removeAction(action:String):Void {
		m_actions.removeObject(action);
	}
}