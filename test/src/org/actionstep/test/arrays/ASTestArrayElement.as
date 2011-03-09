/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;
import org.actionstep.constants.NSComparisonResult;

/**
 * This is used by the <code>org.actionstep.ASTestArray</code> class.
 *
 * @author Scott Hyndman
 */
class org.actionstep.test.arrays.ASTestArrayElement extends NSObject
{
	public var age:Number;
	public var iq:Number;

	public function ASTestArrayElement(age:Number, iq:Number)
	{
		this.age = age;

		if (iq != undefined)
			this.iq = iq;
	}

	//******************************************************
	//*                    Properties
	//******************************************************

	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String
	{
		var ret:String = "ASTestArrayElement(age=" + age;

		if (iq != undefined)
			ret += ", IQ=" + iq;

		ret += ")";

		return ret;
	}

	//******************************************************
	//*                 Public Methods
	//******************************************************

	public function compareAge(that:Object):NSComparisonResult
	{
		if (this.age < that.age)
			return NSComparisonResult.NSOrderedAscending;
		else if (this.age > that.age)
			return NSComparisonResult.NSOrderedDescending;

		return NSComparisonResult.NSOrderedSame;
	}

	public function compareProperty(that:Object):NSComparisonResult
	{
		if (this < that)
			return NSComparisonResult.NSOrderedAscending;
		else if (this > that)
			return NSComparisonResult.NSOrderedDescending;

		return NSComparisonResult.NSOrderedSame;
	}

	//******************************************************
	//*                     Events
	//******************************************************
	//******************************************************
	//*                 Protected Methods
	//******************************************************
	//******************************************************
	//*                  Private Methods
	//******************************************************
	//******************************************************
	//*             Public Static Properties
	//******************************************************
	//******************************************************
	//*              Public Static Methods
	//******************************************************
	//******************************************************
	//*               Static Constructor
	//******************************************************

	/**
	 * Runs when the application begins.
	 */
	private static function classConstruct():Boolean
	{
		if (classConstructed)
			return true;

		return true;
	}

	private static var classConstructed:Boolean = classConstruct();
}
