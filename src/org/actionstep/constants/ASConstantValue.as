/* See LICENSE for copyright and terms of use */

/**
 * This is the base class for all constants. It provides a valueOf() function
 * that will result in all constants being evaluated to their <code>value</code>
 * property when an operation is performed on them.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.ASConstantValue 
{
	private static var g_count:Number = 0;
	
	public var value:Number;
	
	private function ASConstantValue(value:Number)
	{
		this.value = value;
		
		if (isNaN(value) || value == undefined) {
			this.value = g_count++;
		}
	}	
	
	/**
	 * This function is implicitly called when the constant is used.
	 */
	public function valueOf():Number
	{
		return this.value;
	}
	
	public function toString():String {
		return Object(this).__constructor__.__className + "(value=" + value + ")";
	}
}