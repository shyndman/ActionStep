/* See LICENSE for copyright and terms of use */

import org.actionstep.NSAttributedString;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.formatter.ASFormatResult;

/**
 * <p>An abstract formatting class. Provides common operations to be implemented
 * by subclasses.</p>
 * 
 * <p>Notes for those intending to subclass <code>NSFormatter</code>:
 * <ul><li>
 * Please examine the {@link #getObjectValueForStringErrorDescription} method's 
 * comments, as it describes differences from the Cocoa implementation of
 * the method.
 * </li></ul></p>
 *
 * <p><strong>Class Todo:</strong>
 * <ul>
 * <li>
 * Figure out how these methods integrate with {@link org.actionstep.NSControl}.
 * </li>
 * </ul></p>
 * 
 * @see org.actionstep.NSDateFormatter
 * @see org.actionstep.NSNumberFormatter
 * @author Scott Hyndman
 */
class org.actionstep.NSFormatter extends org.actionstep.NSObject {
	
	//******************************************************
	//*                    Construction
	//******************************************************
		
	/**
	 * <p>Creates a new instance of <code>NSFormatter</code>.</p>
	 *
	 * <p>Since this is an abstract class, the constructor is private (protected)
	 * so only subclasses can call it.</p>
	 */
	private function NSFormatter() {
	}
	
	//******************************************************															 
	//*                    Properties
	//******************************************************
	
	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String {
		return "NSFormatter()";
	}
	
	//******************************************************
	//*       Textual representation of cell content
	//******************************************************
	
	/**
	 * <p>The default (<code>NSFormatter</code>) implementation raises an 
	 * exception. Subclasses override this method to perform object to string 
	 * conversion.</p>
	 *
	 * <p><strong>Subclassing notes:</strong>
	 * <ul><li>
	 * The type of the value argument should be tested. If it is not an 
	 * instance of the expected class, <code>null</code> should be returned.
	 * </li><li>
	 * Remember localization!
	 * </li></ul></p>
	 */
	public function stringForObjectValue(value:Object):String {
		var e:NSException = NSException.exceptionWithNameReasonUserInfo(
			"NSAbstractMethodException",
			"This method is only implemented by subclasses of NSFormatter.",
			null);
		trace(e);
		throw e;
		
		return null;
	}
	
	/**
	 * <p>The default (<code>NSFormatter</code>) implementation returns 
	 * <code>null</code>.</p>
	 *
	 * <p>This method generates an attributed string based on a source object.</p>
	 */
	public function attributedStringForObjectValueWithDefaultAttributes(
		anObject:Object, attributes:NSDictionary):NSAttributedString {
		return null;
	}
	
	/**
	 * <p>The default implementation of this method invokes 
	 * {@link #stringForObjectValue}.</p>
	 * 
	 * <p>When implementing a subclass, override this method only when the string 
	 * that users see and the string that they edit are different. In your 
	 * implementation, return a string that is used for editing, following the 
	 * logic recommended for implementing {@link #stringForObjectValue}. As an 
	 * example, you would implement this method if you want the dollar signs in 
	 * displayed strings removed for editing.</p>
	 */
	public function editingStringForObjectValue(anObject:Object):String {
		return stringForObjectValue(anObject);
	}	

	//******************************************************
	//*    Object equivalent to textual representation
	//******************************************************
	
	/**
	 * <p>The default (<code>NSFormatter</code>) implementation raises an 
	 * exception. Subclasses override this method to perform string to object 
	 * conversion.</p>
	 *
	 * <p>This method will return an object formatted as follows:<br/>
	 * <code>{success:Boolean, obj:Object, error:String}</code></p>
	 *
	 * <p>If the success property is <code>true</code>, the conversion succeeded
	 * and the <code>obj</code> property will contain the newly created object. 
	 * If the <code>success</code> property is <code>false</code>, the 
	 * conversion failed and the error property will contain a descriptive error
	 * message.</p>
	 *
	 * <p>The implementation of this method differs from Cocoa's as ActionScript
	 * does not have pointers. Ordinarily a boolean is returned indicating
	 * success and the obj and error arguments are pointers.</p>
	 */	 
	public function getObjectValueForString(string:String)
			:ASFormatResult {
		var e:NSException = NSException.exceptionWithNameReasonUserInfo(
			"NSAbstractMethodException",
			"This method is only implemented by subclasses of NSFormatter.",
			null);
		trace(e);
		throw e;
		
		return null;
	}
	
	//******************************************************
	//*               Dynamic cell editing
	//******************************************************
	
	/**
	 * <p>Since this method is invoked each time the user presses a key while the 
	 * cell has the keyboard focus, it lets you verify and edit the cell text as
	 * the user types it.</p>
	 * 
	 * <p>Since ActionScript does not have the concept of pointers, this method
	 * will instead return an object structured as follows:<br/>
	 * <code>{valid:Boolean, newString:String, error:String}</code><br/>
	 * These properties are described below.</p>
	 * 
	 * <p><code>partialString</code> is the text currently in the cell. Evaluate 
	 * this text according to the context, edit the text if necessary, and 
	 * return by reference any edited string in the return object's
	 * <code>newString</code> property. Assign <code>true</code> to the return
	 * object's <code>valid</code> property if <code>partialString</code> is 
	 * acceptable and <code>false</code> if <code>partialString</code> is 
	 * unacceptable. If you set the return object's <code>valid</code> property
	 * to <code>false</code> and its <code>newString</code> to 
	 * <code>null</code>, <code>partialString</code> minus the last character 
	 * typed is displayed. If set the return object's <code>valid</code> 
	 * property to <code>false</code>, you can also set the return object's
	 * <code>error</code> property to a string that explains the reason why the 
	 * validation failed; the delegate (if any) of the 
	 * {@link org.actionstep.NSControl} managing the cell can then respond to 
	 * the failure in {@link #controlDidFailToValidatePartialStringErrorDescription}. 
	 * The selection range will always be set to the end of the text if 
	 * replacement occurs.</p>
	 */
	public function isPartialStringValidNewEditingStringErrorDescription(
			partialString:String):Object {
		return {valid: true};		
	}
	
	//! TODO isPartialStringValid:proposedSelectedRange:originalString:originalSelectedRange:errorDescription:
}
