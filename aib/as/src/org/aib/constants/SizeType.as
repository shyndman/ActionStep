/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;
import org.actionstep.NSArray;
import org.aib.AIBApplication;
import org.aib.inspector.SizeInspector;

/**
 * Represents size types shown by the size dropdown on the size inspector.
 * 
 * @author Scott Hyndman
 */
class org.aib.constants.SizeType extends ASConstantValue {
	
	public static var WidthHeight:SizeType 
		= new SizeType(1, "SizeWidthHeight");
		
	public static var MaxXMaxY:SizeType 
		= new SizeType(2, "SizeMaxXMaxY");
	
	/**
	 * All origin types.
	 */
	public static var allTypes:NSArray;
	
	/**
	 * The string id of this constant.
	 */
	public var stringId:String;
	
	/**
	 * Creates a new instance of the <code>SizeType</code> class.
	 */
	public function SizeType(value:Number, stringId:String) {
		super(value);
		this.stringId = stringId;
		
		if (allTypes == null) {
			allTypes = NSArray.array();
		}
		
		allTypes.addObject(this);
	}
	
	/**
	 * Returns the locatized version of this origin type.
	 */
	public function toString() : String {
		return AIBApplication.stringForKeyPath(SizeInspector.STRING_GROUP +
			"." + stringId);
	}
}