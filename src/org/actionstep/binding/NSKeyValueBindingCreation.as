/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSDictionary;

/**
 * <p>The <code>NSKeyValueBindingCreation</code> informal protocol provides methods
 * to create and remove bindings between view objects and controllers or 
 * controllers and model objects. In addition, it provides a means for a view 
 * subclass to advertise the bindings that it exposes. This protocol is 
 * implemented by {@link org.actionstep.NSObject} and its methods can be 
 * overridden by view and controller subclasses.</p>
 * 
 * <p>Default bindings are typically exposed in the class' <code>initialize</code>
 * method.</p>
 * 
 * <p>Any class implementing this protocol should also have a static method named
 * {@link #exposedBindingsForClass} that returns an {@link NSArray}
 * of exposed bindings.</p>
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.binding.NSKeyValueBindingCreation {
	
	//******************************************************															 
	//*                 Exposing bindings
	//******************************************************
	
	/**
	 * Returns an array of bindings exposed by this instance.
	 */
	function exposedBindings():NSArray;
	
	//******************************************************															 
	//*                 Managing bindings
	//******************************************************
	
	/**
	 * Returns the class constructor of the value used by the binding named
	 * <code>binding</code>.
	 */
	function valueClassForBinding(binding:String):Function;
	
	/**
	 * <p>Creates a binding between this instance's <code>binding</code> and the
	 * property of <code>controller</code> specified by <code>keyPath</code>.</p>
	 * 
	 * <p><code>options</code> is an optional dictionary of options, which are
	 * described in {@link org.actionstep.binding.NSBindingOptions}.</p>
	 */
	function bindToObjectWithKeyPathOptions(binding:String, 
		controller:Object, keyPath:String, options:NSDictionary):Void;
			
	/**
	 * <p>Returns a dictionary describing this instance's <code>binding</code>.</p>
	 * 
	 * <p>The returned dictionary contains:
	 * <ul>
	 * <li>
	 * 		"NSObservedObjectKey" - //TODO Document
	 * </li>
	 * <li>
	 * 		"NSObservedKeyPathKey" - //TODO Document
	 * </li>
	 * <li>
	 * 		"NSOptionsKey" - A dictionary containing the options associated with
	 * 		the binding.
	 * </li>
	 * </ul>
	 * </p>
	 */
	function infoForBinding(binding:String):NSDictionary;
	
	/**
	 * Removes the <code>binding</code> between the receiver and a controller.
	 */
	function unbind(binding:String):Void;
}