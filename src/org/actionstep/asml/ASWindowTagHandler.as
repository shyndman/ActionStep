/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASAsmlReader;
import org.actionstep.asml.ASDefaultTagHandler;
import org.actionstep.asml.ASParsingUtils;
import org.actionstep.asml.ASReferenceProperty;
import org.actionstep.asml.ASTagHandler;
import org.actionstep.NSException;
import org.actionstep.NSObject;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.NSWindow;

/**
 * This tag handler handles <code>window</code> tags. It can create instances of
 * {@link NSWindow}s and <code>NSWindow</code> subclasses. 
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASWindowTagHandler extends ASDefaultTagHandler 
	implements ASTagHandler {
	
	/**
	 * <p>Constructs a new instance of <code>ASWindowTagHandler</code>.</p> 
	 * 
	 * <p><code>reader</code> is the {@link ASAsmlReader} using this tag
	 * handler.</p>
	 */
	public function ASWindowTagHandler(reader:ASAsmlReader)
	{
		super(reader);
	}
	
	/**
	 * Adds a child view to the content view of the parent window.
	 */
	public function addChildToParent(child:NSObject, parent:NSObject,
		remainingChildAttributes:Object):Void 
	{		
		NSWindow(parent).contentView().addSubview(NSView(child));
	}

	/**
	 * 
	 */
	public function parseNodeWithClassName(node:XMLNode, className:String)
		:Object 
	{		
		var atts:Object = node.attributes;
		var styleMask:Number = 0;
		var borderless:Boolean;
		var closable:Boolean;
		var miniaturizable:Boolean;
		var titled:Boolean;
		var resizable:Boolean;
		var centered:Boolean;
		var hidden:Boolean;
		var swf:Object;
		
		//
		// Store for exception
		//
		var clsName:String = atts.instanceOf == null ? className : atts.instanceOf;
			
		//
		// Get the window.
		//
		var win:NSWindow = NSWindow(
			ASParsingUtils.createInstanceWithClassNameAttributes(className,
			atts));
		
		//
		// Throw an exception if view isn't an NSView
		//
		if (null == win)
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"ASParserException",
				"The specified " + clsName + " is not a subclass of NSWindow.",
				null);
			trace(e);
			throw e;
		}

		//
		// Initialize the window with a frame if possible.
		//
		var frm:NSRect = ASParsingUtils.getFrameFromNodeAttributes(atts, true);
		
		if (null == frm) {
			frm = NSRect.ZeroRect;
		}
		
		//
		// DEAL WITH SPECIAL ATTRIBUTES
		//
		//
		// Borderless should be checked first, because if it is true, we should
		// ignore titled, miniturizable, closable and resizable.
		//
		borderless = Boolean(ASParsingUtils.extractTypedValueForAttributeKey(atts, 
			"borderless", true, false));
		
		if (borderless)
		{
			ASParsingUtils.removeAttributeForKey(atts, "miniaturizable");
			ASParsingUtils.removeAttributeForKey(atts, "resizable");
			ASParsingUtils.removeAttributeForKey(atts, "closable");
			ASParsingUtils.removeAttributeForKey(atts, "titled");
		}
		else
		{
			miniaturizable = Boolean(ASParsingUtils.
				extractTypedValueForAttributeKey(atts, "miniaturizable", true, true));
			resizable = Boolean(ASParsingUtils.
				extractTypedValueForAttributeKey(atts, "resizable", true, true));
			closable = Boolean(ASParsingUtils.
				extractTypedValueForAttributeKey(atts, "closable", true, true));
			titled = Boolean(ASParsingUtils.
				extractTypedValueForAttributeKey(atts, "titled", true, true));
			
			//
			// Modify style mask
			//	
			if (miniaturizable) {
				styleMask |= NSWindow.NSMiniaturizableWindowMask;
			}
			if (resizable) {
				styleMask |= NSWindow.NSResizableWindowMask;
			}
			if (titled) {
				styleMask |= NSWindow.NSTitledWindowMask;
			}
			if (closable) {
				styleMask |= NSWindow.NSClosableWindowMask;
			}
		}
		
		centered = Boolean(ASParsingUtils.extractTypedValueForAttributeKey(atts, 
				"center", true, false));
		hidden = Boolean(ASParsingUtils.extractTypedValueForAttributeKey(atts,
			"hidden", true, false));
		swf = ASParsingUtils.extractTypedValueForAttributeKey(atts,
			"swf", true, null);
				
		//
		// Create the window
		//
		win.initWithContentRectStyleMaskSwf(frm, styleMask, 
			swf == null ? null : swf.toString());
		
		//
		// Apply remaining properties
		//
		var refs:Array = ASParsingUtils.applyPropertiesToObjectWithAttributes(
			win, atts);	
		win.display();
		
		//
		// Set the owner for all the reference properties and add them to the
		// reader.
		//
		var len:Number = refs.length;
		for (var i:Number = 0; i < len; i++)
		{
			ASReferenceProperty(refs[i]).setOwner(win);
			m_reader.addReferenceProperty(ASReferenceProperty(refs[i]));
		}
		
		//
		// Center it if needed
		//
		if (centered) {
			win.center();
		}
		
		//
		// Hide if required, otherwise order it to the front.
		//
		if (hidden) {
			win.hide();
		} else {
			win.orderFront(this);
		}
		
		return win;
	}
}