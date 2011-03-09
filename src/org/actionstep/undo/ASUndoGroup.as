/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;
import org.actionstep.NSInvocation;

/**
 * Represents an undo group, which is a grouping on undo actions.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.undo.ASUndoGroup extends NSObject {
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private var m_parent:ASUndoGroup;
	private var m_actions:Array;
	private var m_actionName:String;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASUndoGroup</code> class.
	 */
	public function ASUndoGroup() {
	}
	
	/**
	 * Initializes this undo group with a parent undo group.
	 */
	public function initWithParent(parent:ASUndoGroup):ASUndoGroup {
		m_parent = parent;
		m_actionName = "";
		m_actions = null;
		
		return this;
	}
	
	//******************************************************
	//*          Releasing the object from memory
	//******************************************************
	
	public function release():Boolean {
		super.release();
		m_actions = null;
		m_parent = null;
		m_actionName = null;
		return true;
	}
	
	//******************************************************
	//*            Information about the group
	//******************************************************
	
	/**
	 * Returns the array of NSInvocation objects contained in this group,
	 * or <code>null</code> if it has none.
	 */
	public function actions():Array {
		return m_actions;
	}
	
	/**
	 * Returns the action name associated with this undo group.
	 */
	public function actionName():String {
		return m_actionName;
	}
	
	/**
	 * Sets the action name associated with this undo group.
	 */
	public function setActionName(aString:String):Void {
		m_actionName = aString;
	}
	
	/**
	 * Returns the parent undo group of this group.
	 */
	public function parent():ASUndoGroup {
		return m_parent;
	}
	
	//******************************************************
	//*               Orphaning the group
	//******************************************************
	
	/**
	 * Orphans the undo group.
	 */
	public function orphan():Void {
		m_parent = null;
	}
	
	//******************************************************
	//*                   Operations
	//******************************************************
	
	/**
	 * Adds an invocation to the group.
	 */
	public function addInvocation(inv:NSInvocation):Void {
		if (m_actions == null) {
			m_actions = [];
		}
		
		m_actions.push(inv);
	}
	
	/**
	 * Removes all actions in this undo group that are associated with 
	 * <code>target</code>.
	 */
	public function removeActionsForTarget(target:Object):Boolean {
		if (m_actions == null || m_actions.length == 0) {
			return false;
		}
		
		var len:Number = m_actions.length;
		for (var i:Number = len - 1; i >= 0; i--) {
			var inv:NSInvocation = NSInvocation(m_actions[i]);
			if (inv.target() == target) {
				m_actions.splice(i, 1);
			} 
		}
		
		if (m_actions.length == 0) {
			m_actions = null;
			return false;
		}
		
		return true;
	}
	
	/**
	 * Invokes all actions handled by this undo group.
	 */
	public function perform():Void {
		if (m_actions == null) {
			return;
		}
		
		var len:Number = m_actions.length;
		for (var i:Number = 0; i < len; i++) {
			var inv:NSInvocation = NSInvocation(m_actions[i]);
			inv.invoke();
		}	
	}
}