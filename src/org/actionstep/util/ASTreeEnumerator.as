/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;
import org.actionstep.NSException;
import org.actionstep.NSEnumerator;
import org.actionstep.NSArray;

/**
 * <p>Abstract class for tree iterators.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.util.ASTreeEnumerator extends NSEnumerator {

	private var m_tree:Object;
	private var m_pref:Object;
	
	/**
	 * Creates a new instance of the <code>ASTreeEnumerator</code> class.
	 */
	public function ASTreeEnumerator(aTree:Object, pref:Object) {
		m_tree = aTree;
		m_pref = pref;
	}
	
	//******************************************************
	//*                   Description
	//******************************************************
	
	/**
	 * Returns a string representation of the ASTreeEnumerator instance.
	 */
	public function description():String {
		return "ASTreeEnumerator(tree=" + m_tree + ", pref=" + m_pref + ")";
	}
	
	//******************************************************
	//*              Enumeration operations
	//******************************************************
	
	/**
	 * <p>Returns an array of objects the receiver has yet to enumerate.</p>
	 */
	public function allObjects():NSArray {
		var arr:NSArray = NSArray.array();
		
		var node:Object;
		while ((node = nextObject()) != null) {
			arr.addObject(node);
		}
		
		return arr;
	}
		
	/**
	 * <p>Returns the next object from the tree being enumerated. When
	 * {@link #nextObject} returns <code>null</code>, all objects have been 
	 * enumerated.</p>
	 *
	 * <p><strong>Note:</strong><br/>
	 * Returns <code>null</code> if and only if the end is reached; if the 
	 * element is itself <code>null</code>, the <code>pref</code> argument
	 * that was passed to the constructor is returned.</p>
	 * 
	 * <p>Must be implemented by subclasses.</p>
	 * 
	 * @return The next object in the tree, or null if the end of the
	 * collection has been reached.
	 */
	public function nextObject():Object {
		var e:NSException = NSException.exceptionWithNameReasonUserInfo(
			NSException.ASAbstractMethod,
			"subclass responsibility",
			null);
		trace(e);
		throw e;
		
		return null;
	}
}