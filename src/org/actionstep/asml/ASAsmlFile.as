/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASReferenceProperty;
import org.actionstep.asml.ASTagHandler;
import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSEnumerator;
import org.actionstep.NSException;
import org.actionstep.NSObject;

/**
 * <p>Represents the contents of an ASML file that has been read.</p>
 * 
 * <p>To access the root objects of the ASML file, use the 
 * {@link #rootObjects()} method. This will return an {@link NSArray}
 * containing the objects that were represented by the top-most tags under
 * the ASML file's <code>objects</code> tag.</p>
 * 
 * <p>Objects that had been assigned <code>id</code>s in the ASML file can be
 * accessed using the {@link #objectForId} method. </p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASAsmlFile extends NSObject 
{
	/**
	 * The url from which this file was loaded. 
	 */
	private var m_url:String;
	
	/**
	 * A dictionary containing objects hashed on their "id" attributes.
	 */
	private var m_idsToObjects:NSDictionary;
	
	/**
	 * Contains an array of reference properties, which are applied after the
	 * initial parsing stage is complete.
	 */
	private var m_referenceProps:NSArray;
		
	/** 
	 * An array containing the children of this file's objects tag.
	 */
	private var m_rootObjects:NSArray;
	
	/**
	 * If this file is a partial file, <code>m_partialFileParent</code> is the
	 * parent of all the objects this file contains.
	 */
	private var m_partialFileParent:Object;
	
	/**
	 * If this file is a partial file, <code>m_partialFileParentHandler</code>
	 * is the tag handler for the parent of this file's root nodes.
	 */
	private var m_partialFileParentHandler:ASTagHandler;
	
	//******************************************************															 
	//*                 Construction
	//******************************************************
	
	/**
	 * Creates a new instance of ASAsmlFile.
	 */
	public function ASAsmlFile()
	{
		m_idsToObjects = NSDictionary.dictionary();
		m_referenceProps = NSArray.array();
	}
	
	//******************************************************															 
	//*              Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the object.
	 */
	public function description():String
	{
		return "ASAsmlFile(url=" + m_url + ")";
	}
	
	/**
	 * Returns the url from which this file was loaded.
	 */
	public function url():String
	{
		return m_url;
	}
	
	/**
	 * Sets the url from which this file was loaded to <code>url</code>.
	 */
	public function setUrl(url:String):Void
	{
		m_url = url;
	}
	
	//******************************************************															 
	//*              Object to ID mapping
	//******************************************************
	
	/**
	 * Creates an association between the object identifier <code>id</code> and
	 * the object <code>obj</code>.
	 */
	public function associateIdWithObject(id:String, obj:Object):Void
	{
		m_idsToObjects.setObjectForKey(obj, id);
	}
	
	/**
	 * Returns the object associated with <code>id</code>, or <code>null</code>
	 * if no such object exists.
	 */
	public function objectForId(id:String):Object
	{
		return m_idsToObjects.objectForKey(id);
	}
	
	/**
	 * Returns the dictionary containing the id to object mappings.
	 */
	public function idToObjectDictionary():NSDictionary
	{
		return m_idsToObjects;
	}
	
	//******************************************************															 
	//*              Reference Properties
	//******************************************************
	
	/**
	 * Returns the array of {@link ASReferenceProperty} objects.
	 */
	public function referenceProperties():NSArray
	{
		return m_referenceProps;
	}
	
	/**
	 * Adds a reference property to be invoked after the initial parsing is
	 * complete.
	 */
	public function addReferenceProperty(property:ASReferenceProperty):Void
	{		
		m_referenceProps.addObject(property);
	}
	
	/**
	 * <p>Invokes all setters that point to other objects defined in the .asml 
	 * file.</p>
	 * 
	 * <p>This should not be called directly. {@link ASAsmlReader} calls this 
	 * when it has finished parsing the asml file.</p>
	 */
	public function applyReferenceProperties():Void
	{
		var itr:NSEnumerator = m_referenceProps.objectEnumerator();
		var ref:ASReferenceProperty;

		while (null != (ref = ASReferenceProperty(itr.nextObject())))
		{
			//
			// Get the object with the specified ID.
			//
			var obj:Object = m_idsToObjects.objectForKey(ref.ID());
			
			//
			// Throw an exception if we can't find the object in question.
			//
			if (null == obj)
			{
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					"NSObjectNotFoundException",
					"The object with ID [" + ref.ID() + "] was not defined in " +
					".asml file.",
					null);
				trace(e);
				throw e;
			}
			
			var setter:Object = ref.owner()[ref.propertyName()];

			if (undefined != setter || typeof(setter) == "function") {
				ref.owner()[ref.propertyName()](obj);
			} else {
				trace("undefined setter");
			}
		}
	}
	
	//******************************************************															 
	//*                    Root Objects
	//******************************************************
	
	/**
	 * Returns an array of the root objects contained in the asml file's
	 * objects node.
	 * 
	 * @see #setRootObjects
	 */
	public function rootObjects():NSArray
	{
		return m_rootObjects;
	}
	
	/**
	 * Sets the asml file's root objects (the children of the objects node) to
	 * the objects contained in <code>rootObjs</code>.
	 * 
	 * @see #rootObjects
	 */
	public function setRootObjects(rootObjs:NSArray):Void
	{
		m_rootObjects = rootObjs;
	}
	
	//******************************************************															 
	//*            Partial file properties
	//******************************************************
	
	public function parentObject():Object
	{
		return m_partialFileParent;
	}
	
	public function parentHandler():ASTagHandler
	{
		return m_partialFileParentHandler;
	}
	
	/**
	 * <p>Sets the parent object of all the objects this file contains, as well
	 * as the parent's handler.</p>
	 * 
	 * <p>Used if this instance represents a partial file.</p>
	 */
	public function setParentObjectWithHandler(parent:Object, 
		handler:ASTagHandler):Void
	{
		m_partialFileParent = parent;
		m_partialFileParentHandler = handler;
	}
}