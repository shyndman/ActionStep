/* See LICENSE for copyright and terms of use */

import org.actionstep.ASLabel;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.NSFont;
import org.actionstep.NSRect;
import org.actionstep.NSView;

/**
 * Used by the inspector to display messages instead of content.
 * 
 * @author Scott Hyndman
 */
class org.aib.inspector.MessageContentView extends NSView {
	
	private var m_label:ASLabel;
	
	//******************************************************
	//*                    Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>MessageContentView</code> class.
	 */
	public function MessageContentView() {
	}
	
	/**
	 * Initializes and returns the <code>MessageContentView</code> instance with a frame
	 * area of <code>aRect</code>.
	 */
	public function initWithFrame(aRect:NSRect):MessageContentView {
		m_label = (new ASLabel()).initWithFrame(
			new NSRect(0, aRect.size.height / 2 - 35, aRect.size.width, 35));
		m_label.setFont(NSFont.systemFontOfSize(24));
		m_label.setAlignment(NSTextAlignment.NSCenterTextAlignment);
		m_label.setStringValue("");
		m_label.setAutoresizingMask(NSView.MinYMargin | NSView.MaxYMargin);		
		addSubview(m_label);
		
		return MessageContentView(super.initWithFrame(aRect));
	}
	
	//******************************************************
	//*                Setting the message
	//******************************************************
	
	public function setMessage(aString:String):Void {
		m_label.setStringValue(aString);
		m_label.setNeedsDisplay(true);
	}
	
	//******************************************************
	//*                  Description
	//******************************************************
	
	/**
	 * Returns a string representation of the MessageContentView instance.
	 */
	public function description():String {
		return "MessageContentView(message=" + m_label.stringValue() + ")";
	}
}