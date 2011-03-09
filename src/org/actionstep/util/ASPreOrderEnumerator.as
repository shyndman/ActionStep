/* See LICENSE for copyright and terms of use */

import org.actionstep.util.ASXmlEnumerator;

/**
 * Performs post-order traversals on XML trees.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.util.ASPreOrderEnumerator extends ASXmlEnumerator {
	
	private var m_root:XMLNode;
	private var m_stack:Array;
	
	/**
	 * Creates a new instance of the <code>ASPostOrderEnumerator</code> class.
	 */
	public function ASPreOrderEnumerator(aTree:XML, pref:Object) {
		super(aTree, pref);
	}
	
	//******************************************************
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the ASPostOrderEnumerator instance.
	 */
	public function description():String {
		return "ASPreOrderEnumerator(tree=" + m_tree + ", pref=" + m_pref + ")";
	}
	
	//******************************************************
	//*                   Operations
	//******************************************************
	
	/**
	 * Recursively visits all nodes rooted at <code>node</code>.
	 */
	private function _visit(node:XMLNode):Void {
		m_stack.push(node);
		
		var arr:Array = node.childNodes;
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			_visit(arr[i]);
		}
	}
}