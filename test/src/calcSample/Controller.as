/* See LICENSE for copyright and terms of use */

import org.actionstep.NSTextField;
import org.actionstep.NSButton;
import org.actionstep.NSFont;
import org.actionstep.constants.NSTextAlignment;

/**
 * @author Scott Hyndman
 */
class calcSample.Controller 
{
	var m_numStack:Array;
	var m_tf:NSTextField;
	
	public function Controller() {
		m_numStack = new Array();
	}
	
	public function setTextField(tf:NSTextField):Void {
		m_tf = tf;
		m_tf.setAlignment(NSTextAlignment.NSRightTextAlignment);
	}
	
	public function digit(from:NSButton):Void {
		m_tf.setStringValue(m_tf.stringValue() + from.title());
		m_tf.display();
	}
	
	public function add():Void {
		m_numStack.push(Number(m_tf.stringValue()));
		clearScreen();
	}
	
	public function total():Void {
		m_numStack.push(Number(m_tf.stringValue()));
		
		var num:Number = 0;
		for (var i:Number = 0; i < m_numStack.length; i++)
		{
			num += m_numStack[i];
		}
		
		m_tf.setStringValue(num.toString());
		m_tf.display();
		
		m_numStack = new Array();
	}
	
	public function clear():Void {
		clearScreen();
		m_numStack = new Array();
	}
	
	public function clearScreen():Void {
		m_tf.setStringValue("");
		m_tf.display();
	}
}