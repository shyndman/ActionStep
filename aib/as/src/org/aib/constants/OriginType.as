/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;
import org.actionstep.NSArray;
import org.aib.AIBApplication;
import org.aib.inspector.SizeInspector;

/**
 * Represents origin types shown by the origin dropdown on the size inspector.
 * 
 * @author Scott Hyndman
 */
class org.aib.constants.OriginType extends ASConstantValue {
	
	public static var TopLeft:OriginType 
		= new OriginType(1, "OriginTopLeft");
		
	public static var BottomLeft:OriginType 
		= new OriginType(2, "OriginBottomLeft");
		
	public static var TopRight:OriginType 
		= new OriginType(3, "OriginTopRight");
		
	public static var BottomRight:OriginType 
		= new OriginType(4, "OriginBottomRight");
	
	/**
	 * All origin types.
	 */
	public static var allTypes:NSArray;
	
	/**
	 * The string id of this constant.
	 */
	public var stringId:String;
	
	/**
	 * Creates a new instance of the <code>OriginTypes</code> class.
	 */
	public function OriginType(value:Number, stringId:String) {
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