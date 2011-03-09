/* See LICENSE for copyright and terms of use */

import org.actionstep.NSDictionary;


/**
 * This interface must be implemented by all classes that wish to participate
 * in Key-Value Observing. More details can be found at the 
 * {@link org.actionstep.binding.NSKeyValueObserving} class.
 * 
 * @see org.actionstep.binding.NSKeyValueObserving#addObserverWithObjectForKeyPathOptionsContext()
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.binding.ASKeyValueObserver {
	
	/**
	 * <p>This method is called when the value at the specified 
	 * <code>keyPath</code> relative to the <code>object</code> has changed.</p>
	 * 
	 * <p>This method is called when the object implementing this interface has
	 * registered as an observer for the specified <code>keyPath</code> and 
	 * <code>object</code>.</p>
	 */
	public function observeValueForKeyPathOfObjectChangeContext(
		keyPath:String, object:Object, change:NSDictionary, context:Object):Void;
}