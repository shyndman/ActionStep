/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;

/**
 * <p>This class represents an object property (refered to by the # symbol). This
 * contains all the information as extracted from the tag attribute.</p>
 * 
 * <p>This is necessary because the setting of these reference properties is 
 * deferred to a point where the parsing of the ASML file is complete, and 
 * all reference properties have been obtained.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASReferenceProperty extends NSObject 
{
	private var m_owner:Object;
	private var m_property:String;
	private var m_id:String;
			
	/**
	 * Sets the owner of this property to <code>obj</code>.
	 */
	public function setOwner(obj:Object):Void
	{
		m_owner = obj;
	}
	
	/**
	 * Returns the owner of this property.
	 */
	public function owner():Object
	{
		return m_owner;
	}
	
	/**
	 * Sets the property name to <code>propertyName</code>.
	 */
	public function setPropertyName(propertyName:String):Void
	{
		m_property = propertyName;
	}
	
	/**
	 * Returns the property name.
	 */
	public function propertyName():String
	{
		return m_property;
	}
	
	/**
	 * Sets the ID this property is referring to.
	 */
	public function setID(id:String):Void
	{
		m_id = id;
	}
	
	/**
	 * Returns the ID this property is referring to.
	 */
	public function ID():String
	{
		return m_id;
	}
	
	/**
	 * Returns a string representation of the object.
	 */
	public function description():String
	{
		return "ASReferenceProperty(ID=" + ID() 
			+ ", propertyName=" + propertyName() 
			+ ", owner=" + owner() + ")";
	}
}