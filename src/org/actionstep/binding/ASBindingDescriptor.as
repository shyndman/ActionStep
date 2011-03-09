/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSBindingDescription;
import org.actionstep.NSDictionary;
import org.actionstep.NSObject;

/**
 * Describes a binding.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.binding.ASBindingDescriptor extends NSObject {
	
	/** The name of the binding. */
	public var name:String;
	
	/** The type of the binding. */
	public var type:Function;
	
	/** Whether the binding is read-only or not. */
	public var readOnly:Boolean;
	
	/** Binding options. */
	public var options:NSDictionary;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Initializes a binding descriptor with the binding description 
	 * <code>description</code>, and the options <code>options</code>.
	 * 
	 * If <code>readOnly</code> is <code>true</code> the binding will be read
	 * only, or <code>false</code> otherwise.
	 */
	public function initWithDescriptionReadOnlyOptions(
			description:NSBindingDescription,
			readOnly:Boolean,
			options:NSDictionary):ASBindingDescriptor {
				
		return initWithNameTypeReadOnlyOptions(description.name,
			description.type, readOnly, options);
	}

	/**
	 * Initializes a binding descriptor with the name <code>name</code>, type
	 * <code>type</code> and the options <code>options</code>.
	 * 
	 * If <code>readOnly</code> is <code>true</code> the binding will be read
	 * only, or <code>false</code> otherwise.
	 */	
	public function initWithNameTypeReadOnlyOptions(
			name:String,
			type:Function,
			readOnly:Boolean,
			options:NSDictionary):ASBindingDescriptor {
		this.name = name;
		this.type = type;
		this.readOnly = readOnly;
		this.options = options;
		
		return this;		
	}
	
	/**
	 * Creates and returns a new binding descriptor.
	 */
	public static function bindingDescriptorWithDescriptionReadOnlyOptions(
			description:NSBindingDescription,
			readOnly:Boolean,
			options:NSDictionary):ASBindingDescriptor {
		return (new ASBindingDescriptor()).initWithDescriptionReadOnlyOptions(
			description, readOnly, options);		
	}
	
	/**
	 * Creates and returns a new binding descriptor.
	 */
	public static function bindingDescriptorWithNameTypeReadOnlyOptions(
			name:String,
			type:Function,
			readOnly:Boolean,
			options:NSDictionary):ASBindingDescriptor {
		return (new ASBindingDescriptor()).initWithNameTypeReadOnlyOptions(
			name, type, readOnly, options);		
	}
}