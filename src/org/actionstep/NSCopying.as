/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;

/**
 * <p>Also known as the NSCopying protocol in Cocoa.</p>
 *
 * <p>The {@link #copyWithZone()} method is used to create a copy of an
 * instance. It is called internally by {@link NSObject#copy()}.</p>
 *
 * <p>Please note that you might have to additional casts eg.<br/>
 * <code>
 * var foo:MyClass = MyClass(toCopy.copy());
 * </code></p>
 *
 * @see org.actionstep.NSObject#copy
 * @author Tay Ray Chuan
 */

interface org.actionstep.NSCopying {
	public function copyWithZone():NSObject;
}
