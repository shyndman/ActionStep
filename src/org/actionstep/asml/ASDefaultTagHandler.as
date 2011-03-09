/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASAsmlReader;
import org.actionstep.asml.ASParsingUtils;
import org.actionstep.asml.ASReferenceProperty;
import org.actionstep.asml.ASTagHandler;
import org.actionstep.NSException;
import org.actionstep.NSInvocation;
import org.actionstep.NSObject;
import org.actionstep.NSRect;
import org.actionstep.NSView;

/**
 * <p>This is the default tag handler. It assumes the tag being processed
 * represents a subclass {@link NSView}.</p>
 * 
 * <p>This is an excellent tag handler to extend for custom tag handling that
 * will result in subclasses of {@link NSView} being created.</p>
 * 
 * <p><strong>Implementation notes:</strong>
 * <ul>
 * <li>
 * Take a look at {@link #initializeObject()}. This is a good method
 *   to override if your custom <code>NSView</code> subclass uses an
 *   initializer method other than {@link NSView#initWithFrame(NSRect)}
 * </li>
 * </ul>
 * </p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASDefaultTagHandler extends NSObject 
	implements ASTagHandler 
{
	private var m_reader:ASAsmlReader;
	private var m_shouldApplyProperties:Boolean;
	
	/**
	 * <p>Constructs a new instance of <code>ASDefaultTagHandler</code>.</p> 
	 * 
	 * <p><code>reader</code> is the {@link ASAsmlReader} using this tag handler.</p>
	 */
	public function ASDefaultTagHandler(reader:ASAsmlReader)
	{
		m_reader = reader;
		m_shouldApplyProperties = true;
	}
	
	/**
	 * Adds the <code>child</code> view as a subview of <code>parent</code>.
	 */
	public function addChildToParent(child:NSObject, parent:NSObject,
		remainingChildAttributes:Object):Void 
	{
		var parentView:NSView = NSView(parent);
		
		//! consider throwing exception if parent not NSView
		
		parentView.addSubview(NSView(child));
	}

	/**
	 * // TODO Describes steps taken here.
	 */
	public function parseNodeWithClassName(node:XMLNode, className:String)
		:Object 
	{
		var atts:Object = node.attributes;
		
		//
		// Store for exception
		//
		var clsName:String = atts.instanceOf == null ? className : atts.instanceOf;
			
		//
		// Get view instance
		//
		var view:NSView = NSView(
			ASParsingUtils.createInstanceWithClassNameAttributes(className, 
			atts));
		
		//
		// Throw an exception if view isn't an NSView
		//
		if (null == view)
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSInvalidClassException",
				"The class " + clsName + " is not a subclass of NSView.",
				null);
			trace(e);
			throw e;
		}
		
		//
		// Initialize the view with a frame if possible.
		//
		var frm:NSRect = ASParsingUtils.getFrameFromNodeAttributes(
			atts, true);
		
		initializeObject(view, frm, node);
		
		//
		// Grab toolTip property and postpone it.
		//
		var tipText:String = String(ASParsingUtils.
			extractTypedValueForAttributeKey(atts, "toolTip", true, ""));
		if ("" != tipText) {
			m_reader.addPostponedOperation(
				NSInvocation.invocationWithTargetSelectorArguments(
					view, "setToolTip", tipText));
		}
		
		var refs:Array = [];
		
		//
		// Apply remaining properties.
		//
		if (m_shouldApplyProperties) {
			refs = ASParsingUtils.applyPropertiesToObjectWithAttributes(view, atts);
		}
		
		//
		// Set the owner for all the reference properties and add them to the
		// reader.
		//
		var len:Number = refs.length;
		for (var i:Number = 0; i < len; i++)
		{
			ASReferenceProperty(refs[i]).setOwner(view);
			m_reader.addReferenceProperty(ASReferenceProperty(refs[i]));
		}
		
		//
		// Size to fit if no frame was specified
		//
		if (null == frm) {
			view["sizeToFit"]();
		}
		
		return view;
	}
	
	/**
	 * Override to provide more specific functionality.
	 */
	private function initializeObject(obj:Object, frm:NSRect, node:XMLNode):Void
	{
		if (null != frm) {
			obj.initWithFrame(frm); //! maybe change this	
		} else {
			obj.init();
		}
	}
}