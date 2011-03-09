/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASAsmlReader;
import org.actionstep.asml.ASDefaultTagHandler;
import org.actionstep.asml.ASParsingUtils;
import org.actionstep.layout.ASHBox;
import org.actionstep.layout.ASVBox;
import org.actionstep.NSInvocation;
import org.actionstep.NSNumber;
import org.actionstep.NSObject;
import org.actionstep.NSRect;
import org.actionstep.NSView;

/**
 * <p>This handles the parsing of <code>hbox</code> and <code>vbox</code> tags 
 * from the ASML file.</p>
 * 
 * <p>These tags represent {@link ASHBox} and {@link ASVBox} controls 
 * respectively.</p> 
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASLayoutBoxTagHandler extends ASDefaultTagHandler 
{
	/**
	 * <p>Constructs a new instance of <code>ASLayoutBoxTagHandler</code>.</p> 
	 * 
	 * <p><code>reader</code> is the {@link ASAsmlReader} using this tag
	 * handler.</p>
	 */
	public function ASLayoutBoxTagHandler(reader:ASAsmlReader)
	{
		super(reader);
	}
	
	/**
	 * Adds the <code>child</code> view into the <code>parent</code> HBox/VBox 
	 * using {@link ASHBox#addView} or {@link ASVBox#addView} 
	 * (depending on whether <code>parent</code> is an HBox or a VBox.
	 */
	public function addChildToParent(child:NSObject, parent:NSObject,
		remainingChildAttributes:Object):Void
	{		
		var hbox:ASHBox = ASHBox(parent);
		
		if (null != hbox) {
			if (child instanceof NSNumber) // Add a separator
			{
				if (NSNumber(child).intValue() == -1) {
					hbox.addSeparator();
				} else {
					hbox.addSeparatorWithMinXMargin(NSNumber(child).intValue());
				}
			}
			else // Add a view
			{
				//
				// Get additional arguments.
				//
				var enableXResizing:Boolean = Boolean(
					ASParsingUtils.extractTypedValueForAttributeKey(
						remainingChildAttributes, "enableXResizing", true, 
						true));
				var minXMargin:Number = Number(
					ASParsingUtils.extractTypedValueForAttributeKey(
						remainingChildAttributes, "minXMargin", true,
						hbox.defaultMinXMargin()));
						
				hbox.addViewEnableXResizingWithMinXMargin(NSView(child),
					enableXResizing, minXMargin);
			}
			
			return;
		}
		
		var vbox:ASVBox = ASVBox(parent);
		
		if (null != vbox) {
			if (child instanceof NSNumber) // Add a separator
			{
				if (NSNumber(child).intValue() == -1) {
					vbox.addSeparator();
				} else {
					vbox.addSeparatorWithMinYMargin(NSNumber(child).intValue());
				}
			}
			else // Add a view
			{
				//
				// Get additional arguments.
				//
				var enableYResizing:Boolean = Boolean(
					ASParsingUtils.extractTypedValueForAttributeKey(
						remainingChildAttributes, "enableYResizing", true, 
						true));
				var minYMargin:Number = Number(
					ASParsingUtils.extractTypedValueForAttributeKey(
						remainingChildAttributes, "minYMargin", true,
						vbox.defaultMinYMargin()));
						
				vbox.addViewEnableYResizingWithMinYMargin(NSView(child),
					enableYResizing, minYMargin);
			}
			
			return;
		}
	}
	
	/**
	 * <p>If <code>className</code> is anything but "separator", this class invokes
	 * its superclass' implementation of {@link #parseNodeWithClassName}.</p>
	 * 
	 * <p>If it is "separator", then a special value is returned to indicate to
	 * {@link #addChildToParent} that a separator should be added to the
	 * box.</p>
	 */
	public function parseNodeWithClassName(node:XMLNode, className:String)
		:Object 
	{
		if ("separator" != className) {				
			var box:Object = super.parseNodeWithClassName(node, className);			
			return box;
		}
		
		//
		// Get the type of box we're inside.
		//
		var boxType:String = node.parentNode.nodeName;
		
		//
		// Get the property to check for.
		//
		var prop:String;
		
		switch (boxType) 
		{
			case "hbox":
				prop = "minXMargin";
				break;
				
			case "vbox":
				prop = "minYMargin";
				break;
		}
		
		//
		// Get the min margin if there is one. If not, set to -1.
		//
		var margin:Number = node.attributes[prop] == undefined ?
			-1 : Number(node.attributes[prop]);
		
		return NSNumber.numberWithInt(margin);
	}
	
	/**
	 * Defers a setFrame call on the box.
	 */
	private function initializeObject(obj:Object, frm:NSRect, node:XMLNode):Void
	{
		obj.init();
		
		if (null != frm)
		{
			var op:NSInvocation = NSInvocation.
				invocationWithTargetSelectorArguments(obj, "setFrame", frm);
			m_reader.addPostponedOperation(op);
		}
	}
}