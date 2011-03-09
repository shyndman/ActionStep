/* See LICENSE for copyright and terms of use */

import org.actionstep.ASTreeCell;
import org.actionstep.ASTreeView;
import org.actionstep.NSArray;
import org.actionstep.NSCell;
import org.actionstep.NSDictionary;
import org.actionstep.NSImage;
import org.actionstep.NSObject;
import org.actionstep.tree.ASTreeDelegate;
import org.actionstep.ASUtils;

/**
 * <p>A delegate implementation for the <code>ASTree</code> class used to
 * provide an XML datasource.</p>
 * 
 * @see ASTree#setDelegate()
 * 
 * @author Scott Hyndman
 */
class org.actionstep.tree.ASXmlTreeDelegate extends NSObject 
		implements ASTreeDelegate {
	
	//******************************************************
	//*                    Constants
	//******************************************************
	
	private static var ASDelegateCounterAttributeName:String = "__delegateCount__";
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_xml:XMLNode;
	private var m_delegateID:Number;
	private var m_levelKey:String;
	private var m_nodeIDKey:String;
	private var m_nodeCount:Number;
	private var m_titleKey:String;
	private var m_imageKey:String;
	private var m_altImageKey:String;
	private var m_idToCell:NSDictionary;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASXmlTreeDelegate</code> class.
	 */
	public function ASXmlTreeDelegate() {
		m_idToCell = NSDictionary.dictionary();
		m_nodeCount = 0;
	}
	
	/**
	 * Initializes the tree delegate with a data source of <code>xml</code>
	 * and the key <code>aKey</code> that represents the name of the attribute
	 * in each node that contains the node's title.
	 * 
	 * @see #initWithXmlTitleKeyImageKey()
	 * @see #initWithXmlTitleKeyImageKeyAltImageKey()
	 */
	public function initWithXmlTitleKey(xml:XMLNode, aKey:String):ASXmlTreeDelegate {
		m_xml = xml;
		m_titleKey = aKey;
		_generateDelegateID();
		return this;
	}
	
	/**
	 * Initializes the tree delegate with a data source of <code>xml</code>
	 * and the keys <code>titleKey</code> and <code>imageKey</code> that 
	 * represent the names of the attributes in each node that contain the 
	 * node's title and image name respectively.
	 * 
	 * @see #initWithXmlTitleKey()
	 * @see #initWithXmlTitleKeyImageKeyAltImageKey()
	 */
	public function initWithXmlTitleKeyImageKey(xml:XMLNode, titleKey:String, 
			imageKey:String):ASXmlTreeDelegate {
		initWithXmlTitleKey(xml, titleKey);
		m_imageKey = imageKey;
		return this;
	}
	
	/**
	 * Initializes the tree delegate with a data source of <code>xml</code>
	 * and the keys <code>titleKey</code>, <code>imageKey</code> and 
	 * <code>altImageKey</code> that represent the names of the attributes in 
	 * each node that contain the node's title, image name and alternate image
	 * name respectively.
	 * 
	 * @see #initWithXmlTitleKey()
	 * @see #initWithXmlTitleKeyImageKey()
	 */
	public function initWithXmlTitleKeyImageKeyAltImageKey(xml:XMLNode, 
			titleKey:String, imageKey:String, altImageKey:String):ASXmlTreeDelegate {
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
	//*               Getting node data
	//******************************************************
		
	/**
	 * Returns the title of <code>node</code>, or <code>null</code> if it
	 * has none.
	 */
	private function titleForNode(node:Object):String {
		var key:String = titleKey();
		if (key == null) {
			return null;
		}
		
		return node.attributes[key];
	}
	
	/**
	 * Returns the image of <code>node</code>, or <code>null</code> if it
	 * has none.
	 */
	private function imageForNode(node:Object):NSImage {
		var key:String = imageKey();
		if (key == null) {
			return null;
		}
		
		return NSImage.imageNamed(node.attributes[key]);
	}
	
	/**
	 * Returns the alternate image of <code>node</code>, or <code>null</code> if
	 * it has none.
	 */
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
	
	/**
	 * @see ASTreeDelegate#treeViewChildrenOfItem()
	 */
	public function treeViewChildrenOfItem(tree:ASTreeView, 
			item:Object):NSArray {
		//
		// Get roots
		//
		if (item == null) {
			return NSArray.arrayWithArray(m_xml.childNodes);
		}
		
		var node:XMLNode = XMLNode(item);
		if (node == null) { // not an XML node
			trace(asWarning("item must be an XMLNode"));
			return null;
		}
		
		//
		// Return the node's children
		//
		return NSArray.arrayWithArray(node.childNodes);
	}
	
	/**
	 * @see ASTreeDelegate#treeViewIsItemExpandable()
	 */
	public function treeViewIsItemExpandable(tree:ASTreeView, item:Object):Boolean {
		return XMLNode(item).childNodes.length > 0;
	}
	
	/**
	 * @see ASTreeDelegate#treeViewLevelOfItem()
	 */
	public function treeViewLevelOfItem(tree:ASTreeView, item:Object):Number {
		return _getNodeLevel(XMLNode(item));
	}

	/**
	 * @see ASTreeDelegate#treeViewCellOfItem()
	 */
	public function treeViewCellOfItem(tree:ASTreeView, item:Object):ASTreeCell {
		var id:String = _getNodeID(XMLNode(item)).toString();
		return ASTreeCell(m_idToCell.objectForKey(id));
	}
	
	/**
	 * @see ASTreeDelegate#treeViewWillDisplayCellWithItem()
	 */
	public function treeViewWillDisplayCellWithItem(tree:ASTreeView, cell:NSCell, 
			item:Object):Void {
		//
		// Get the path and the node
		//
		var node:XMLNode = XMLNode(item);
		var level:Number = _getNodeLevel(node);
		
		//
		// Bad level
		//
		if (level == -1) {
			trace(asWarning("Unabled to determine level of " + node));
			return;
		}
		
		//
		// Set the cell properties
		//
		var c:ASTreeCell = ASTreeCell(cell);
		c.setStringValue(titleForNode(node));
		c.setImage(imageForNode(node));
		c.setAlternateImage(alternateImageForNode(node));
		c.setLeaf(node.firstChild == null);
		c.setLevel(level);
		c.setTreeNode(node);
		
		//
		// Associate the node with the cell
		//
		m_idToCell.setObjectForKey(c, _getNodeID(node).toString());
	}
	
	//******************************************************
	//*                 Helper methods
	//******************************************************
	
	/**
	 * Generates a unique delegate ID for this XML tree.
	 */
	private function _generateDelegateID():Void {
		var root:XMLNode = ASUtils.rootNodeOfNode(m_xml);
		
		if (root[ASDelegateCounterAttributeName] == null) {
			m_delegateID = root[ASDelegateCounterAttributeName] = 0;
			_global.ASSetPropFlags(root, [ASDelegateCounterAttributeName], 1);
		} else {
			m_delegateID = ++root[ASDelegateCounterAttributeName];
		}
		
		m_levelKey = "__xmlTreeDelegate" + m_delegateID + "_level";
		m_nodeIDKey = "__xmlTreeDelegate" + m_delegateID + "_nodeID";
		
		m_xml[m_levelKey] = -1;
		m_xml[m_nodeIDKey] = m_nodeCount++;
		_global.ASSetPropFlags(m_xml, [m_levelKey, m_nodeIDKey], 1);
	}
	
	/**
	 * Gets the node identifier for <code>node</code> in this delegate.
	 */
	private function _getNodeID(node:XMLNode):Number {
		if (node[m_nodeIDKey] == null) {
			node[m_nodeIDKey] = m_nodeCount++;
			_global.ASSetPropFlags(node, [m_nodeIDKey], 1);
		}
		
		return node[m_nodeIDKey];
	}
	
	/**
	 * Sets the node level of <code>node</code> to <code>level</code>.
	 */
	private function _setNodeLevel(node:XMLNode, level:Number):Void {
		node[m_levelKey] = level;
	}
	
	/**
	 * <p>Gets the node level of <code>node</code>.</p>
	 * 
	 * <p>Returns <code>-1</code> if the level cannot be determined.</p> 
	 */
	private function _getNodeLevel(node:XMLNode):Number {
		var stack:Array = [];
		var parent:XMLNode = node;
		while (parent != null) {
			if (parent[m_levelKey] == null) {
				stack.push(parent);
			} else {
				break;
			}
			
			parent = parent.parentNode;
		}
		
		//
		// Get the parent level
		//
		var parentLevel:Number = parent[m_levelKey];
		if (parentLevel == null) {
			return -1;
		}
		
		//
		// Fill in the levels of all nodes in between the parent and node.
		//
		var cnt:Number = 0;
		var obj:Object;
		while ((obj = stack.pop()) != null) {
			obj[m_levelKey] = parentLevel + ++cnt;
			_global.ASSetPropFlags(obj, [m_levelKey], 1);
		}
		
		return node[m_levelKey];
	}
}