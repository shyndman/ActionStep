/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSBrowser;
import org.actionstep.NSBrowserCell;
import org.actionstep.NSCell;
import org.actionstep.NSObject;
import org.actionstep.NSImage;

/**
 * Used by an <code>NSBrowser</code> to display data from an XML data source.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.browser.ASXmlBrowserDelegate extends NSObject {
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_xml:XMLNode;
	private var m_titleKey:String;
	private var m_imageKey:String;
	private var m_altImageKey:String;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASXmlBrowserDelegate</code> class.
	 */
	public function ASXmlBrowserDelegate() {
	}
	
	/**
	 * Initializes the browser delegate with a data source of <code>xml</code>
	 * and the key <code>aKey</code> that represents the name of the attribute
	 * in each node that contains the node's title.
	 * 
	 * @see #initWithXmlTitleKeyImageKey()
	 * @see #initWithXmlTitleKeyImageKeyAltImageKey()
	 */
	public function initWithXmlTitleKey(xml:XMLNode, aKey:String):ASXmlBrowserDelegate {
		m_xml = xml;
		m_titleKey = aKey;
		return this;
	}
	
	/**
	 * Initializes the browser delegate with a data source of <code>xml</code>
	 * and the keys <code>titleKey</code> and <code>imageKey</code> that 
	 * represent the names of the attributes in each node that contain the 
	 * node's title and image name respectively.
	 * 
	 * @see #initWithXmlTitleKey()
	 * @see #initWithXmlTitleKeyImageKeyAltImageKey()
	 */
	public function initWithXmlTitleKeyImageKey(xml:XMLNode, titleKey:String, 
			imageKey:String):ASXmlBrowserDelegate {
		initWithXmlTitleKey(xml, titleKey);
		m_imageKey = imageKey;
		return this;
	}
	
	/**
	 * Initializes the browser delegate with a data source of <code>xml</code>
	 * and the keys <code>titleKey</code>, <code>imageKey</code> and 
	 * <code>altImageKey</code> that represent the names of the attributes in 
	 * each node that contain the node's title, image name and alternate image
	 * name respectively.
	 * 
	 * @see #initWithXmlTitleKey()
	 * @see #initWithXmlTitleKeyImageKey()
	 */
	public function initWithXmlTitleKeyImageKeyAltImageKey(xml:XMLNode, 
			titleKey:String, imageKey:String, altImageKey:String):ASXmlBrowserDelegate {
		initWithXmlTitleKeyImageKey(xml, titleKey, imageKey);
		m_altImageKey = altImageKey;
		return this;		
	}
	
	//******************************************************
	//*            Getting the internal data
	//******************************************************
	
	/**
	 * Returns the XML handled internally by this delegate.
	 */
	public function xmlData():XMLNode {
		return m_xml;
	}
	
	//******************************************************
	//*       Getting title and image data from nodes
	//******************************************************
	
	/**
	 * Returns the XMLNode attribute name that contains the node's title.
	 */
	public function titleKey():String {
		return m_titleKey;
	}
	
	/**
	 * Sets the XMLNode attribute name that contains the node's title to
	 * <code>aKey</code>.
	 */
	public function setTitleKey(aKey:String):Void {
		m_titleKey = aKey;
	}
	
	/**
	 * Returns the XMLNode attribute name that contains the node's image name.
	 */
	public function imageKey():String {
		return m_imageKey;
	}
	
	/**
	 * Sets the XMLNode attribute name that contains the node's image name to
	 * <code>aKey</code>.
	 */
	public function setImageKey(aKey:String):Void {
		m_imageKey = aKey;
	}
	
	/**
	 * Returns the XMLNode attribute name that contains the node's alternate
	 * image name.
	 */
	public function alternateImageKey():String {
		return m_altImageKey;
	}
	
	/**
	 * Sets the XMLNode attribute name that contains the node's alternate image
	 * name to <code>aKey</code>.
	 */
	public function setAlternateImageKey(aKey:String):Void {
		m_altImageKey = aKey;
	}
	
	//******************************************************
	//*               Getting column data
	//******************************************************
	
	/**
	 * Returns an array of nodes that can be found at path.
	 */
	private function nodesForPath(path:NSArray):Array {
		while (path.containsObject("")) {
			path.removeObject("");
		}
		
		var curNode:Object = m_xml;
		var arr:Array = path.internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			var p:String = arr[i];
			curNode = findNodeInListWithTitle(curNode.childNodes, p);
		}
		
		return curNode.childNodes;
	}
	
	private function findNodeInListWithTitle(nodes:Array, title:String):Object {
		var len:Number = nodes.length;
		for (var i:Number = 0; i < len; i++) {
			if (titleForNode(nodes[i]) == title) {
				return nodes[i];
			}
		}
		
		return null;
	}
	
	private function titleForNode(node:Object):String {
		var key:String = titleKey();
		if (key == null) {
			return null;
		}
		
		return node.attributes[key];
	}
	
	private function imageForNode(node:Object):NSImage {
		var key:String = imageKey();
		if (key == null) {
			return null;
		}
		
		return NSImage.imageNamed(node.attributes[key]);
	}
	
	private function alternateImageForNode(node:Object):NSImage {
		var key:String = alternateImageKey();
		if (key == null) {
			return null;
		}
		
		return NSImage.imageNamed(node.attributes[key]);
	}
	
	//******************************************************
	//*                 Delegate methods
	//******************************************************
	
	public function browserWillDisplayCellAtRowColumn(sender:NSBrowser,
			cell:NSCell,
			row:Number,
			column:Number):Void {
		var nodes:Array = nodesForPath(NSArray.arrayWithArray(
			sender.pathToColumn(column).split(sender.pathSeparator())));
		var node:Object = nodes[row];
		cell.setStringValue(titleForNode(node));
		cell.setImage(imageForNode(node));
		NSBrowserCell(cell).setAlternateImage(alternateImageForNode(node));
		NSBrowserCell(cell).setLeaf(node.firstChild == null);
	}
		
	public function browserNumberOfRowsInColumn(sender:NSBrowser,
			column:Number):Number {
		return nodesForPath(NSArray.arrayWithArray(
			sender.path().split(sender.pathSeparator()))).length;
	}
	
	public function browserTitleOfColumn(sender:NSBrowser,
			column:Number):String {
		return null;
	}
}