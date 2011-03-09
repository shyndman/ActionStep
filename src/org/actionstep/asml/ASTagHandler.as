/* See LICENSE for copyright and terms of use */

/**
 * <p>A tag handler is responsible for parsing tag data into an object, and 
 * adding children of the tag (as parsed by their respective handlers) into 
 * the object.</p>
 *  
 * <p><strong>Implementation notes:</strong>
 * <ul><li>
 * You may find it helpful to check out the utility funtions offered in
 * {@link org.actionstep.asml.ASParsingUtils}.
 * </li><li>
 * It may be useful to extend {@link org.actionstep.asml.ASInstanceTagHandler}
 * or {@link org.actionstep.asml.ASDefaultTagHandler} to inherit useful 
 * functionality.
 * </li></ul></p>
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.asml.ASTagHandler 
{
	/**
	 * Adds a child of the tag into the <code>parent</code> object, which
	 * is an object that was produced by using {@link #parseNodeWithClassName}.
	 */
	function addChildToParent(child:Object, parent:Object,
		remainingChildAttributes:Object):Void;
	
	/**
	 * <p>Parses an XML node and returns an initialized instance of the class.</p>
	 * 
	 * <p>Do not parse any children in this method.</p>
	 * 
	 * <p><strong>Notes:</strong>
	 * <ul><li>
	 * If your class allows for the <code>instanceOf</code> attribute, remember 
	 * to account for this and ignore <code>className</code> if necessary.
	 * </li></ul></p>
	 */
	function parseNodeWithClassName(node:XMLNode, className:String):Object;
}