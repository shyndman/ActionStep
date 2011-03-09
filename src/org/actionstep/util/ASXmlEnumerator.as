/* See LICENSE for copyright and terms of use */

import org.actionstep.util.ASTreeEnumerator;
import org.actionstep.NSException;

/**
 * Abstract class for iterating XML trees.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.util.ASXmlEnumerator extends ASTreeEnumerator {

	private var m_root:XMLNode;
	private var m_stack:Array;
	
	/**
	 * Creates a new instance of the <code>ASPostOrderEnumerator</code> class.
	 */
	public function ASXmlEnumerator(aTree:XML, pref:Object) {
		super(aTree, pref);
		m_root = aTree.firstChild;
		reset();
	}
	
	//******************************************************
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the ASXmlEnumerator instance.
	 */
	public function description():String {
		return "ASXmlEnumerator(tree=" + m_tree + ", pref=" + m_pref + ")";
	}
	
	//******************************************************
	//*                   Operations
	//******************************************************
	
	/**
	 * Resets the enumerator. 
	 */
	public function reset():Void {
		m_stack = [];
		_visit(m_root);
	}
	
	/**
	 * Returns the next object in the post-order traversal sequence.
	 */
	public function nextObject():Object {
		if (m_stack.length == 0) {
			return null;
		}
		
		var ret:Object = m_stack.shift();
		return ret == null ? m_pref : ret;
	}	
	
	/**
	 * Recursively visits all nodes rooted at <code>node</code>.
	 */
	private function _visit(node:XMLNode):Void {
		var e:NSException = NSException.exceptionWithNameReasonUserInfo(
			NSException.ASAbstractMethod,
			"subclass responsibility",
			null);
		trace(e);
		throw e;
	}
}