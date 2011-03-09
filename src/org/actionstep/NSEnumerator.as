/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;

/**
 * <p>Enumerates through a collection of objects.</p>
 *
 * <p><strong>Note:</strong><br/>
 * It isn’t safe to modify a mutable collection while enumerating through it.
 * </p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSEnumerator
{
	/** The collection. */
	private var m_list:Array;

	/** The current index in the collection. */
	private var m_curidx:Number;

	/** True if the enumeration is happening in reverse. */
	private var m_reverse:Boolean;

	/** Preferred return value if an element is null. */
	private var m_prefVal:Object;


	/**
	 * Constructs a new instance of <code>NSEnumerator</code>.
	 *
	 * @param anArray The array to enumerate through.
	 * @param reverse Whether to move forwards or backwards while enumerating.
	 * @param pref Preferred return value if an element is null. Defaults to "".
	 */
	public function NSEnumerator(anArray:Array, reverse:Boolean, pref:Object)
	{
		m_list = anArray;
		m_curidx = reverse ? m_list.length - 1 : 0;
		m_reverse = reverse;
		m_prefVal = pref==null ? "" : pref;
	}


	//******************************************************
	//*					 Public Methods					   *
	//******************************************************

	/**
	 * Returns an array of objects the receiver has yet to enumerate. The array
	 * returned by this method does not contain objects that have already been
	 * enumerated with previous nextObject messages. Invoking this method
	 * exhausts the enumerator’s collection so that subsequent invocations of
	 * {@link #nextObject} return <code>null</code>.
	 *
	 * @return The array of objects yet to be enumerated through.
	 */
	public function allObjects():NSArray
	{
		var idx:Number = m_curidx;

		//
		// Set the current index to exhaust the enumeration.
		//
		if (m_reverse)
		{
			m_curidx = 0;
		}
		else
		{
			m_curidx = m_list.length - 1;
		}

		return NSArray.arrayWithArray(m_list.slice(idx, m_curidx));
	}


	/**
	 * <p>Returns the next object from the collection being enumerated. When
	 * {@link #nextObject} returns <code>null</code>, all objects have been 
	 * enumerated.</p>
	 *
	 * <p><strong>Note:</strong><br/>
	 * Returns <code>null</code> if and only if the end is reached; if the 
	 * element is itself <code>null</code>, the <code>pref</code> argument
	 * that was passed to the constructor is returned.</p>
	 * 
	 * @return The next object in the collection, or null if the end of the
	 * collection has been reached.
	 */
	public function nextObject():Object
	{
		var i:Object;
		return (m_curidx == m_list.length || m_curidx == -1) ? null :
			((i=m_list[m_reverse ? m_curidx-- : m_curidx++])
			 == null ? m_prefVal : i);
	}
}
