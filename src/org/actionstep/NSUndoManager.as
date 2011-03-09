/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSException;
import org.actionstep.NSInvocation;
import org.actionstep.NSObject;
import org.actionstep.NSRange;
import org.actionstep.undo.ASUndoGroup;
import org.actionstep.ASUtils;
import org.actionstep.NSNotificationCenter;
import org.actionstep.ASStringFormatter;

/**
 * <p>NSUndoManager is a general-purpose recorder of operations for undo and 
 * redo. You register an undo operation by specifying the object that’s 
 * changing (or the owner of that object), along with a method to invoke to 
 * revert its state, and the arguments for that method. When performing undo
 * an NSUndoManager saves the operations reverted so that you can redo the 
 * undos.</p>
 */
dynamic class org.actionstep.NSUndoManager extends NSObject {
	
	//******************************************************
	//*                 Notifications
	//******************************************************
	
	/**
	 * Posted whenever an NSUndoManager object opens or closes an undo group 
	 * (except when it opens a top-level group) and when checking the redo 
	 * stack in canRedo. The notification object is the NSUndoManager object. 
	 * This notification does not contain a userInfo dictionary.
	 */
	public static var NSUndoManagerCheckpointNotification:Number =
		ASUtils.intern("NSUndoManagerCheckpointNotification");
	
	/**
	 * Posted whenever an NSUndoManager object opens an undo group, which occurs
	 * in the implementation of the beginUndoGrouping method. The notification 
	 * object is the NSUndoManager object. This notification does not contain a 
	 * userInfo dictionary.
	 */	
	public static var NSUndoManagerDidOpenUndoGroupNotification:Number =
		ASUtils.intern("NSUndoManagerDidOpenUndoGroupNotification");
		
	/**
	 * Posted just after an NSUndoManager object performs a redo operation 
	 * (redo). The notification object is the NSUndoManager object. This 
	 * notification does not contain a userInfo dictionary.
	 */
	public static var NSUndoManagerDidRedoChangeNotification:Number =
		ASUtils.intern("NSUndoManagerDidRedoChangeNotification");
		
	/**
	 * Posted just after an NSUndoManager object performs an undo operation. If 
	 * you invoke undo or undoNestedGroup, this notification is posted. The 
	 * notification object is the NSUndoManager object. This notification does 
	 * not contain a userInfo dictionary.
	 */
	public static var NSUndoManagerDidUndoChangeNotification:Number =
		ASUtils.intern("NSUndoManagerDidUndoChangeNotification");
		
	/**
	 * Posted before an NSUndoManager object closes an undo group, which occurs 
	 * in the implementation of the endUndoGrouping method. The notification 
	 * object is the NSUndoManager object. This notification does not contain a 
	 * userInfo dictionary.
	 */
	public static var NSUndoManagerWillCloseUndoGroupNotification:Number =
		ASUtils.intern("NSUndoManagerWillCloseUndoGroupNotification");
		
	/**
	 * Posted just before an NSUndoManager object performs a redo operation 
	 * (redo). The notification object is the NSUndoManager object. This 
	 * notification does not contain a userInfo dictionary.
	 */
	public static var NSUndoManagerWillRedoChangeNotification:Number =
		ASUtils.intern("NSUndoManagerWillRedoChangeNotification");
		
	/**
	 * Posted just before an NSUndoManager object performs an undo operation. If 
	 * you invoke undo or undoNestedGroup, this notification is posted. The 
	 * notification object is the NSUndoManager object. This notification does 
	 * not contain a userInfo dictionary.
	 */
	public static var NSUndoManagerWillUndoChangeNotification:Number =
		ASUtils.intern("NSUndoManagerWillUndoChangeNotification");
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_undoStack:NSArray;
	private var m_redoStack:NSArray;
	private var m_group:ASUndoGroup;
	private var m_preparedTarget:Object;
	private var m_levelsOfUndo:Number;
	private var m_undoTitle:String;
	private var m_redoTitle:String;
	private var m_disableCount:Number;
	private var m_isUndoing:Boolean;
	private var m_isRedoing:Boolean;
	private var m_nc:NSNotificationCenter;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSUndoManager</code> class.
	 */
	public function NSUndoManager() {
		m_levelsOfUndo = 0;
		m_undoTitle = "Undo %s";
		m_redoTitle = "Redo %s";
		m_disableCount = 0;
		m_group = null;
		m_isUndoing = false;
		m_isRedoing = false;
	}
	
	/**
	 * Initializes the undo manager.
	 */
	public function init():NSUndoManager {
		super.init();
		
		m_undoStack = NSArray.array();
		m_redoStack = NSArray.array();
		m_nc = NSNotificationCenter.defaultCenter();
		
		return this;
	}
	
	//******************************************************
	//*               Releasing the object
	//******************************************************
	
	/**
	 * Releases the object from memory.
	 */
	public function release():Boolean {
		m_undoStack.removeAllObjects();
		m_redoStack.removeAllObjects();
		m_group.release();
		
		m_undoStack = null;
		m_redoStack = null;
		m_group = null;
		m_preparedTarget = null;
		
		return true;
	}
	
	//******************************************************
	//*              Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the NSUndoManager instance.
	 */
	public function description():String {
		return "NSUndoManager()";
	}
	
	//******************************************************
	//*            Registering undo operations
	//******************************************************
	
	/**
	 * <p>Records a single undo operation for <code>target</code>, so that when 
	 * an undo is performed it is sent <code>aSelector</code> with 
	 * <code>anObject</code> as the sole argument.</p>
	 * 
	 * <p>Also clears the redo stack.</p>
	 * 
	 * <p>Raises an exception if invoked when no undo group has been established
	 * using {@link #beginUndoGrouping()}. Undo groups are normally set by 
	 * default, so you should rarely need to begin a top-level undo group 
	 * explicitly.</p>
	 * 
	 * @see #undoNestedGroup()
	 * @see #forwardInvocation()
	 * @see #groupingLevel()
	 */
	public function registerUndoWithTargetSelectorObject(target:Object, 
			sel:String, object:Object):Void {
		if (m_group == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"An undo group has not been established.",
				null);
			trace(e);
			throw e;
		}
		
		m_undoStack.addObject(NSInvocation.invocationWithTargetSelectorArguments(
			target, sel, object));		
	}
	
	/**
	 * Prepares the receiver for invocation-based undo with 
	 * <code>target</code> as the subject of the next undo operation and 
	 * returns <code>this</code>.
	 * 
	 * @see #forwardInvocation()
	 */
	public function prepareWithInvocationTarget(target:Object):NSUndoManager {
		m_preparedTarget = target;
		return this;
	}
	
	/**
	 * <p>Overrides NSObject’s implementation to record anInvocation as an undo 
	 * operation.</p>
	 * 
	 * <p>Also clears the redo stack.</p>
	 * 
	 * <p>Raises an exception if {@link #prepareWithInvocationTarget()} was not 
	 * invoked before this method. This method then clears the prepared 
	 * invocation target. Also raises an exception if invoked when no undo 
	 * group has been established using {@link #beginUndoGrouping()}. Undo 
	 * groups are normally set by default, so you should rarely need to begin a 
	 * top-level undo group explicitly.</p>
	 */
	public function forwardInvocation(anInvocation:NSInvocation):Void {
		if (m_preparedTarget == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"prepareWithInvocationTarget() must be run prior to " +
				"forwarding an invocation.",
				null);
			trace(e);
			throw e;
		}
		
		if (m_group == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"An undo group has not been established.",
				null);
			trace(e);
			throw e;
		}
		
		anInvocation.setTarget(m_preparedTarget);
		m_group.addInvocation(anInvocation);
		m_preparedTarget = null;
		
		if (!m_isUndoing && !m_isRedoing && m_group.actions().length > 0) {
			m_redoStack.removeAllObjects();
		}
	}
	
	//******************************************************
	//*              Checking undo ability
	//******************************************************
	
	/**
	 * <p>
	 * Returns a Boolean value indicating whether the receiver has any actions 
	 * to undo.
	 * </p>
	 * <p>
	 * The return value does not mean you can safely invoke {@link #undo()} or 
	 * {@link #undoNestedGroup()}—you may have to close open undo groups first.
	 * </p>
	 */
	public function canUndo():Boolean {
		return m_undoStack.count() > 0 
			|| (m_group != null && m_group.actions().length > 0);
	}
	
	/**
	 * <p>
	 * Returns a Boolean value indicating whether the receiver has any actions 
	 * to redo.
	 * </p>
	 * <p>
	 * Because any {@link #undo()} operation registered clears the redo stack, 
	 * this method posts an {@link #NSUndoManagerCheckpointNotification} to 
	 * allow clients to apply their pending operations before testing the redo 
	 * stack.
	 * </p>
	 */
	public function canRedo():Boolean {
		m_nc.postNotificationWithNameObject(NSUndoManagerCheckpointNotification,
			this);
		return m_redoStack.count() > 0;
	}
	
	//******************************************************
	//*             Performing undo and redo
	//******************************************************
	
	/**
	 * <p>
	 * Closes the top-level undo group if necessary and invokes 
	 * {@link #undoNestedGroup()}.
	 * </p>
	 * <p>
	 * This method also invokes {@link #endUndoGrouping} if the nesting level is 
	 * 1. Raises an exception if more than one undo group is open (that is, if 
	 * the last group isn’t at the top level).
	 * </p>
	 */
	public function undo():Void {
		if (groupingLevel() == 1) {
			endUndoGrouping();
		} 
		
		if (m_group != null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"undo with nested groups",
				null);
			trace(e);
			throw e;
		}
		
		undoNestedGroup();
	}
	
	/**
	 * <p>
	 * Performs the undo operations in the last undo group (whether top-level 
	 * or nested), recording the operations on the redo stack as a single 
	 * group.
	 * </p>
	 * <p>
	 * Raises an exception if any undo operations have been registered since the
	 * last enableUndoRegistration message.
	 * </p>
	 * <p>
	 * This method posts an {@link #NSUndoManagerCheckpointNotification} and 
	 * {@link #NSUndoManagerWillUndoChangeNotification} before it performs the 
	 * undo operation, and it posts an 
	 * {@link #NSUndoManagerDidUndoChangeNotification} after it performs the 
	 * undo operation.
	 * </p>
	 */
	public function undoNestedGroup():Void {
		m_nc.postNotificationWithNameObject(NSUndoManagerCheckpointNotification,
			this);
		
		//
		// If the current undo group hasn't been closed, throw an exception.
		//
		if (m_group != null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"undoNestedGroup before endUndoGrouping",
				null);
			trace(e);
			throw e;
		}
		
		if (m_isUndoing || m_isRedoing) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"undoNestedGroup while undoing or redoing",
				null);
			trace(e);
			throw e;
		}
		
		if (m_undoStack.count() == 0) {
			return;
		}
		
		//
		// Post notification
		//
		m_nc.postNotificationWithNameObject(NSUndoManagerWillUndoChangeNotification,
			this);
			
		//
		// Update stack and state
		//
		var groupToUndo:ASUndoGroup;
		var oldGroup:ASUndoGroup = m_group;
		m_group = null;
		m_isUndoing = true;
		
		if (oldGroup != null) {
			groupToUndo = oldGroup;
			oldGroup = oldGroup.parent();
			groupToUndo.orphan();
			m_redoStack.addObject(groupToUndo);
		} else {
			groupToUndo = ASUndoGroup(m_undoStack.lastObject());
			m_undoStack.removeLastObject(); 
		}
		
		var name:String = groupToUndo.actionName();
		
		//
		// Get the name before we undo
		//
		beginUndoGrouping();
		groupToUndo.perform();
		endUndoGrouping();
		
		m_isUndoing = false;
		m_group = oldGroup;
		
		ASUndoGroup(m_redoStack.lastObject()).setActionName(name);
				
		//
		// Post notification
		//
		m_nc.postNotificationWithNameObject(NSUndoManagerDidUndoChangeNotification,
			this);
		
	}
	
	/**
	 * <p>
	 * Performs the operations in the last group on the redo stack, if there 
	 * are any, recording them on the undo stack as a single group.
	 * </p>
	 * <p>
	 * Raises an exception if the method is invoked during an undo operation.
	 * </p>
	 * <p>
	 * This method posts an {@link #NSUndoManagerCheckpointNotification} and 
	 * {@link #NSUndoManagerWillRedoChangeNotification} before it performs the 
	 * redo operation, and it posts an 
	 * {@link #NSUndoManagerDidRedoChangeNotification} after it performs the 
	 * redo operation.
	 * </p>
	 */
	public function redo():Void {
		if (m_isUndoing || m_isRedoing) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"redo while undoing or redoing",
				null);
			trace(e);
			throw e;
		}
		
		m_nc.postNotificationWithNameObject(NSUndoManagerCheckpointNotification,
			this);
			
		if (m_redoStack.count() == 0) {
			return;
		}
		
		var oldGroup:ASUndoGroup;
		var groupToRedo:ASUndoGroup;
		var name:String;
		
		//
		// Post notification
		//
		m_nc.postNotificationWithNameObject(NSUndoManagerWillRedoChangeNotification,
			this);
			
		groupToRedo = ASUndoGroup(m_redoStack.lastObject());
		m_redoStack.removeLastObject();
		
		name = groupToRedo.actionName();
		
		oldGroup = m_group;
		m_group = null;
		
		beginUndoGrouping();
		groupToRedo.perform();		
		endUndoGrouping();

		m_isRedoing = false;
		m_group = oldGroup;
		
		ASUndoGroup(m_undoStack.lastObject()).setActionName(name);
				
		//
		// Post notification
		//
		m_nc.postNotificationWithNameObject(NSUndoManagerDidRedoChangeNotification,
			this);
	}
	
	//******************************************************
	//*             Limiting the undo stack
	//******************************************************
	
	/**
	 * <p>Sets the maximum number of top-level undo groups the receiver holds to 
	 * <code>levels</code>.</p>
	 * <p>
	 * When ending an undo group results in the number of groups exceeding this 
	 * limit, the oldest groups are dropped from the stack. A limit of 0 
	 * indicates no limit, so that old undo groups are never dropped. The 
	 * default is 0.
	 * </p>
	 * <p>
	 * If invoked with a limit below the prior limit, old undo groups are 
	 * immediately dropped.
	 * </p>
	 * 
	 * @see #enableUndoRegistration()
	 * @see #levelsOfUndo()
	 */
	public function setLevelsOfUndo(num:Number):Void {		
		m_levelsOfUndo = num;
		
		if (num > 0) {
			while (m_undoStack.count() > num) {
				m_undoStack.removeObjectAtIndex(0);
			}
			while (m_redoStack.count() > num) {
				m_redoStack.removeObjectAtIndex(0);
			}
		}
	}
	
	/**
	 * <p>
	 * Returns the maximum number of top-level undo groups the receiver holds.
	 * </p>
	 * <p>
	 * When ending an undo group results in the number of groups exceeding this 
	 * limit, the oldest groups are dropped from the stack. A limit of 0 
	 * indicates no limit, so old undo groups are never dropped. The default is 
	 * 0.
	 * </p>
	 * 
	 * @see #enableUndoRegistration()
	 * @see #setLevelsOfUndo()
	 */
	public function levelsOfUndo():Number {
		return m_levelsOfUndo;
	}
	
	//******************************************************
	//*              Creating undo groups
	//******************************************************
	
	/**
	 * <p>Marks the beginning of an undo group.</p>
	 * <p>
	 * All individual undo operations before a subsequent 
	 * {@link #endUndoGrouping} message are grouped together and reversed by a 
	 * later {@link #undo()} message.
	 * </p>
	 * <p>
	 * This method posts an {@link #NSUndoManagerCheckpointNotification} unless 
	 * a top-level undo is in progress. It posts an 
	 * {@link #NSUndoManagerDidOpenUndoGroupNotification} if a new group was 
	 * successfully created.
	 * </p>
	 */
	public function beginUndoGrouping():Void {
		//
		// Post checkpoint
		//
		if (!m_isUndoing) {
			m_nc.postNotificationWithNameObject(NSUndoManagerCheckpointNotification,
				this);
		}
		
		var parent:ASUndoGroup = m_group;
		m_group = (new ASUndoGroup()).initWithParent(parent);
		
		//
		// Make sure we created the group
		//
		if (m_group == null) {
			m_group = parent;
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"beginUndoGrouping failed to create group",
				null);
			trace(e);
			throw e;
		}
		
		m_nc.postNotificationWithNameObject(NSUndoManagerDidOpenUndoGroupNotification,
			this);
	}
	
	/**
	 * <p>Marks the end of an undo group.</p>
	 * <p>
	 * All individual undo operations back to the matching 
	 * {@link #beginUndoGrouping()} message are grouped together and reversed by 
	 * a later {@link #undo()} or {@link #undoNestedGroup()} message. Undo 
	 * groups can be nested, thus providing functionality similar to nested 
	 * transactions. Raises an exception if there’s no 
	 * {@link #beginUndoGrouping()} message in effect.
	 * </p>
	 * <p>
	 * This method posts an {@link #NSUndoManagerCheckpointNotification} and an 
	 * {@link #NSUndoManagerWillCloseUndoGroupNotification} just before the 
	 * group is closed.
	 * </p>
	 */
	public function endUndoGrouping():Void {
		if (m_group == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"endUndoGrouping without beginUndoGrouping",
				null);
			trace(e);
			throw e;
		}
		
		m_nc.postNotificationWithNameObject(NSUndoManagerCheckpointNotification,
			this);
		
		var g:ASUndoGroup = m_group;
		var gActions:Array = g.actions();
		var gNumActions:Number = gActions.length;
		var p:ASUndoGroup = g.parent();
		m_group = p;
		g.orphan();
		
		m_nc.postNotificationWithNameObject(NSUndoManagerWillCloseUndoGroupNotification,
			this);
			
		//
		// Cleanup stack
		//
		if (p == null) {
			if (m_isUndoing) {
				if (m_levelsOfUndo > 0 && m_redoStack.count() == m_levelsOfUndo 
						&& g.actions().length > 0) {
					m_redoStack.removeObjectAtIndex(0);
				}
			
				if (g != null) {
					if (g.actions().length > 0) {
						m_redoStack.addObject(g);
					}
				}
			} else {
				if (m_levelsOfUndo > 0 
						&& m_undoStack.count() == m_levelsOfUndo 
						&& g.actions().length > 0) {
					m_undoStack.removeObjectAtIndex(0);
				}
		
				if (g != null) {
					if (g.actions().length > 0) {
						m_undoStack.addObject(g);
					}
				}
			}			
		}
		else if (gActions != null) {
			var a:Array = gActions;
			var len:Number = gNumActions;
			
			for (var i:Number = 0; i < len; i++) {
				p.addInvocation(a[i]);
			}
		}
	}
	
	/**
	 * Enables the recording of undo operations.
	 */
	public function enableUndoRegistration():Void {
		if (m_disableCount > 0) {
			m_disableCount--;
		} else {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"enableUndoRegistration called when not disabled",
				null);
			trace(e);
			throw e;
		}
	}
	
	/**
	 * Returns the current number of groupings.  These are the current
	 * groupings which can be nested, not the number of of groups on either
	 * the undo or redo stack.
	 */
	public function groupingLevel():Number {
		var g:ASUndoGroup = m_group;
		var level:Number = 0;
		while (g != null) {
			level++;
			g = g.parent();
		}
		
		return level;
	}
	
	//******************************************************
	//*                 Disabling undo
	//******************************************************
	
	/**
	 * <p>
	 * Disables the recording of undo operations, whether by 
	 * {@link #registerUndoWithTargetSelectorObject()} or by invocation-based 
	 * undo.
	 * </p>
	 */
	public function disableUndoRegistration():Void {
		m_disableCount++;
	}
	
	/**
	 * Returns a Boolean value that indicates whether the recording of undo 
	 * operations is enabled.
	 */
	public function isUndoRegistrationEnabled():Boolean {
		return m_disableCount == 0;
	}
	
	//******************************************************
	//*             Clearing undo operations
	//******************************************************
	
	/**
	 * Clears the undo and redo stacks and reenables the receiver.
	 */
	public function removeAllActions():Void {
		m_redoStack.removeAllObjects();
		m_undoStack.removeAllObjects();
		m_isRedoing = false;
  		m_isUndoing = false;
		m_disableCount = 0;
	}
	
	/**
	 * Clears the undo and redo stacks of all operations involving the 
	 * specified target as the recipient of the undo message.
	 */
	public function removeAllActionsWithTarget(target:Object):Void {
		var arr:Array = m_redoStack.internalList();
		var i:Number = arr.length;
		
		while (i-- > 0) {
			var g:ASUndoGroup = arr[i];
			if (!g.removeActionsForTarget(target)) {
				m_redoStack.removeObjectAtIndex(i);
			}
		}
		
		arr = m_undoStack.internalList();
		i = arr.length;
		
		while (i-- > 0) {
			var g:ASUndoGroup = arr[i];
			if (!g.removeActionsForTarget(target)) {
				m_undoStack.removeObjectAtIndex(i);
			}
		}
	}
	
	//******************************************************
	//*       Setting and getting the action name
	//******************************************************
	
	/**
	 * Sets the name of the action associated with the Undo or Redo command.
	 */
	public function setActionName(name:String):Void {
		if (name != null && m_group != null) {
			m_group.setActionName(name);
		}
	}
	
	/**
	 * Returns the name identifying the redo action.
	 */
	public function redoActionName():String {
		if (!canRedo()) {
			return null;
		}
		
		return ASUndoGroup(m_redoStack.lastObject()).actionName();
	}
	
	/**
	 * Returns the name identifying the undo action.
	 */
	public function undoActionName():String {
		if (!canUndo()) {
			return null;
		}
		
		return ASUndoGroup(m_undoStack.lastObject()).actionName();
	}
	 
	//******************************************************
	//*      Getting and localizing menu item title
	//******************************************************

	/**
	 * Returns the redo menu title template, which is a string containing
	 * the localized "redo" word and a "%s" field where the action name is
	 * inserted.
	 */	
	public function redoMenuItemTitleTemplate():String {
		return m_redoTitle;
	}
	
	/**
	 * Returns the undo menu title template, which is a string containing
	 * the localized "undo" word and a "%s" field where the action name is
	 * inserted.
	 */
	public function undoMenuItemTitleTemplate():String {
		return m_undoTitle;
	}
	
	/**
	 * Sets the redo menu title template, which is a string containing
	 * the localized "redo" word and a "%s" field where the action name is
	 * inserted.
	 */	
	public function setRedoMenuItemTitleTemplate(aString:String):Void {
		m_redoTitle = aString;
	}
	
	/**
	 * Sets the undo menu title template, which is a string containing
	 * the localized "undo" word and a "%s" field where the action name is
	 * inserted.
	 */
	public function setUndoMenuItemTitleTemplate(aString:String):Void {
		m_undoTitle = aString;
	}
	
	/**
	 * Returns the complete title of the Redo menu command, for example, 
	 * “Redo Paste.”
	 */
	public function redoMenuItemTitle():String {
		var name:String = redoActionName();
		if (name == null) {
			name = "";
		}
				
		return redoMenuItemTitleForUndoActionName(name);
	}
	
	/**
	 * Returns the complete, localized title of the Redo menu command for the 
	 * action identified by the given name.
	 */
	public function redoMenuItemTitleForUndoActionName(name:String):String {
		if (name != null) {
			return ASStringFormatter.formatString(redoMenuItemTitleTemplate(),
					NSArray.arrayWithObject(name));
		}
		
		return name;	
	}
	
	/**
	 * Returns the complete title of the Redo menu command, for example, 
	 * “Redo Paste.”
	 */
	public function undoMenuItemTitle():String {
		var name:String = undoActionName();
		if (name == null) {
			name = "";
		}
		
		return undoMenuItemTitleForUndoActionName(name);
	}
	
	/**
	 * Returns the complete, localized title of the Redo menu command for the 
	 * action identified by the given name.
	 */
	public function undoMenuItemTitleForUndoActionName(name:String):String {
		if (name != null) {
			return ASStringFormatter.formatString(undoMenuItemTitleTemplate(),
					NSArray.arrayWithObject(name));
		}
		
		return name;	
	}
	
	//******************************************************
	//*                 Helper methods
	//******************************************************
	
	private function addUndo(anInvocation:NSInvocation):Void {
		m_undoStack.addObject(anInvocation);
		
		if (m_levelsOfUndo != 0 && m_levelsOfUndo < m_undoStack.count()) {
			m_undoStack.removeObjectsInRange(
				new NSRange(0, m_undoStack.count() - m_levelsOfUndo));
		}
	}
	
	//******************************************************
	//*                 Internal methods
	//******************************************************
	
	private function __resolve(methodName:String):Function {		
		var self:NSUndoManager = this;
		var ret:Function = function() {
			var args:Array = [null, methodName];
			args.concat(arguments);
			var inv:NSInvocation = NSInvocation.invocationWithTargetSelectorArguments.apply(
				NSInvocation, args);
			self.forwardInvocation(inv);
		};
		return ret;
	}
}