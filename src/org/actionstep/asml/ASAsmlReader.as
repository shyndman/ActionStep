/* See LICENSE for copyright and terms of use */ 

import org.actionstep.asml.ASAsmlFile;
import org.actionstep.asml.ASColorTagHandler;
import org.actionstep.asml.ASConnectionTagHandler;
import org.actionstep.asml.ASDefaultTagHandler;
import org.actionstep.asml.ASGridTagHandler;
import org.actionstep.asml.ASImageTagHandler;
import org.actionstep.asml.ASIncludeTagHandler;
import org.actionstep.asml.ASInstanceTagHandler;
import org.actionstep.asml.ASLayoutBoxTagHandler;
import org.actionstep.asml.ASMovieViewTagHandler;
import org.actionstep.asml.ASReferenceProperty;
import org.actionstep.asml.ASTabViewItemTagHandler;
import org.actionstep.asml.ASTabViewTagHandler;
import org.actionstep.asml.ASTagHandler;
import org.actionstep.asml.ASThemeTagHandler;
import org.actionstep.asml.ASWindowTagHandler;
import org.actionstep.ASUtils;
import org.actionstep.constants.ASAsmlParsingMode;
import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSEnumerator;
import org.actionstep.NSException; 
import org.actionstep.NSInvocation;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSObject;

/**
 * <p>This class reads in asml (ActionStep Markup Language) files and produces
 * a layout based on the information contained within the file.</p>
 * 
 * <p>It works on the concept of TagHandler. TagHandlers are objects that 
 * implement the {@link org.actionstep.asml.ASTagHandler} interface. When a
 * node in the XML is discovered, a handler registered to handle the node is 
 * invoked and returns information used to further build the interface.</p>
 * 
 * <p>The contents of the read in ASML file is represented by an 
 * {@link ASAsmlFile} object. You can access this file by calling
 * the {@link #asmlFile()} method on the reader used to read the file.</p>
 * 
 * <p>When the asml file has finished loading, the ASAsmlReader posts a
 * {@link #ASAsmlFileDidLoadNotification} to the default notification center.</p>
 * 
 * <p>To see an example using this class, see
 * {@link org.actionstep.test.ASTestControls}.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASAsmlReader extends NSObject 
{
	//******************************************************															 
	//*                   Constants
	//******************************************************
	
	private static var ASObjectsTag:String 		= "objects";
	private static var ASConnectorsTag:String 	= "connectors";
	private static var ASThemeTag:String		= "theme";
	
	//******************************************************															 
	//*                    Members
	//******************************************************
	
	/** The file representation created by this class. */
	private var m_file:ASAsmlFile;
	
	/** The URL from which the asml file is loaded. */
	private var m_url:String;
	
	/** The asml file. */
	private var m_xml:XML;
	
	/** The method to use when parsing the asml file. */
	private var m_mode:ASAsmlParsingMode;
	
	/** The default tag handler. */
	private var m_defaultHandler:ASTagHandler;
	
	/** 
	 * A dictionary containing class name aliases (node names).
	 * 
	 * @see #registerAlias
	 */
	private var m_aliases:NSDictionary;
	
	/** 
	 * A dictionary containing class name aliases (node names).
	 * 
	 * @see #registerAlias
	 */
	private var m_handlers:NSDictionary;
	
	/**
	 * An array of operations that will occur after the parsing step.
	 */
	private var m_postponedOperations:NSArray;
	
	/** The number of includes that are currently loading. */
	private var m_childFileCount:Number;
	
	//******************************************************															 
	//*                  Construction
	//******************************************************
	
	/**
	 * Constructs a new instance of ASAsmlReader.
	 */
	public function ASAsmlReader()
	{
		m_xml = new XML();
		m_xml.ignoreWhite = true;
		m_aliases = NSDictionary.dictionary();
		m_handlers = NSDictionary.dictionary();
		m_postponedOperations = NSArray.array();
		m_childFileCount = 0;
	}
	
	/**
	 * Initializes the ASAsmlReader and returns the initialized instance.
	 */
	public function init():ASAsmlReader
	{
		//
		// Register aliases
		//
		registerAlias("view", "org.actionstep.NSView");
		registerAlias("button", "org.actionstep.NSButton");
		registerAlias("textfield", "org.actionstep.NSTextField");
		registerAlias("textField", "org.actionstep.NSTextField");
		registerAlias("tabview", "org.actionstep.NSTabView");
		registerAlias("tabView", "org.actionstep.NSTabView");
		registerAlias("tabItem", "org.actionstep.NSTabViewItem");
		registerAlias("tab", "org.actionstep.NSTabViewItem");
		registerAlias("comboBox", "org.actionstep.NSComboBox");
		registerAlias("combobox", "org.actionstep.NSComboBox");
		registerAlias("label", "org.actionstep.ASLabel");
		registerAlias("window", "org.actionstep.NSWindow");
		registerAlias("hbox", "org.actionstep.layout.ASHBox");
		registerAlias("vbox", "org.actionstep.layout.ASVBox");
		registerAlias("grid", "org.actionstep.layout.ASGrid");
		registerAlias("image", "org.actionstep.NSImage");
		registerAlias("connection", "org.actionstep.ASConnection");
		registerAlias("movieView", "org.actionstep.NSMovieView");
		registerAlias("movieview", "org.actionstep.NSMovieView");
		
		//
		// Register handlers
		//
		registerTagWithHandler(ASThemeTag,
			new ASThemeTagHandler(this));
		registerTagWithHandler("color",
			new ASColorTagHandler());
		registerTagWithHandler("org.actionstep.NSImage",
			new ASImageTagHandler());
		registerTagWithHandler("instance",
			new ASInstanceTagHandler(this));
		registerTagWithHandler("org.actionstep.NSWindow",
			new ASWindowTagHandler(this));
		registerTagWithHandler("separator",
			new ASLayoutBoxTagHandler(this));
		registerTagWithHandler("org.actionstep.layout.ASVBox",
			new ASLayoutBoxTagHandler(this));
		registerTagWithHandler("org.actionstep.layout.ASHBox",
			new ASLayoutBoxTagHandler(this));
		registerTagWithHandler("org.actionstep.layout.ASGrid",
			new ASGridTagHandler(this));
		registerTagWithHandler("cell",
			new ASGridTagHandler(this));
		registerTagWithHandler("row",
			new ASGridTagHandler(this));
		registerTagWithHandler("include",
			new ASIncludeTagHandler());
		registerTagWithHandler("org.actionstep.NSTabView",
			new ASTabViewTagHandler(this));
		registerTagWithHandler("org.actionstep.NSTabViewItem",
			new ASTabViewItemTagHandler(this));
		registerTagWithHandler("org.actionstep.ASConnection",
			new ASConnectionTagHandler(this));
		registerTagWithHandler("org.actionstep.NSMovieView",
			new ASMovieViewTagHandler(this));
			
		//
		// Register default handler
		//
		setDefaultTagHandler(new ASDefaultTagHandler(this));
		
		return this;
	}
	
	/**
	 * Initializes the AsmlReader and begins loading the asml file from
	 * <code>url</code>. This initializer assumes that the asml file
	 * at <code>url</code> is a complete file.
	 */
	public function initWithUrl(url:String):ASAsmlReader
	{
		return initWithUrlParsingMode(url, ASAsmlParsingMode.ASFullFile);
	}
	
	/**
	 * Initializes the AsmlReader and begins loading the asml file from
	 * <code>url</code> to be parsed under the <code>mode</code> parsing mode.
	 */
	public function initWithUrlParsingMode(url:String, mode:ASAsmlParsingMode)
		:ASAsmlReader
	{
		init();
		beginLoadingWithUrlParsingMode(url, mode);
		
		return this;
	}
	
	/**
	 * Initializes the AsmlReader with the contents of an asml file contained
	 * in <code>asml</code>.
	 */
	public function initWithAsmlFile(asml:XML):ASAsmlReader
	{
		init();
		m_xml = asml;
		m_xml.ignoreWhite = true;
		m_mode = ASAsmlParsingMode.ASFullFile;
		m_file = new ASAsmlFile();
		parseAsmlFile();
		
		return this;
	}
	
	/**
	 * Releases this reader from memory.
	 */
	public function release():Void
	{
		NSNotificationCenter.defaultCenter().removeObserver(this);
		m_xml = null;
		m_aliases.removeAllObjects();
		m_aliases = null;
		m_handlers.removeAllObjects();
		m_handlers = null;
		m_postponedOperations.removeAllObjects();
		m_postponedOperations = null;
		m_defaultHandler = null;
	}
	
	//******************************************************															 
	//*               ASML File Object
	//******************************************************
	
	/**
	 * Returns the asml file as created by the reader.
	 */
	public function asmlFile():ASAsmlFile
	{
		return m_file;
	}
	
	
	//******************************************************															 
	//*             XML Loading and Parsing
	//******************************************************
	
	public function beginLoadingWithUrlParsingMode(url:String, 
		mode:ASAsmlParsingMode):Void
	{
		m_url = url;
		m_mode = mode;
		m_file = new ASAsmlFile();
		m_file.setUrl(url);
		
		var self:ASAsmlReader = this;
		
		m_xml.load(m_url);
		m_xml.onLoad = function(success:Boolean) {
			self["asmlFileDidLoad"](success);
		};
	}
	
	/**
	 * Handler invoked when the asml file finishes loading.
	 */
	private function asmlFileDidLoad(success:Boolean):Void
	{
		try
		{
			//
			// Post an ASAsmlFileDidLoadNotification notification to the 
			// default notification center.
			//
			NSNotificationCenter.defaultCenter().postNotificationWithNameObjectUserInfo(
				ASAsmlFileDidLoadNotification,
				this,
				NSDictionary.dictionaryWithObjectForKey(success, "success"));
				
			// TODO how should we handle failure?
			if (success)
			{
				parseAsmlFile();
			}
		}
		catch (e:NSException)
		{
			trace(e.toString());
		}
	}
	
	/**
	 * Called when this reader's asml file is completely parsed.
	 */
	private function asmlFileDidParse():Void
	{
		//
		// Do nothing if the includes aren't finished parsing.
		//
		if (m_childFileCount != 0) {
			return;
		}
		
		if (m_mode == ASAsmlParsingMode.ASFullFile)
		{
			//
			// The complete file is finished loading, so we do the last step.
			//
			m_file.applyReferenceProperties();
			invokePostponedOperations();
		}
		
		//
		// Post a notification to indicate that we've finished parsing.
		//
		NSNotificationCenter.defaultCenter().
			postNotificationWithNameObjectUserInfo(
				ASAsmlFileDidParseNotification,
				this,
				NSDictionary.dictionaryWithObjectForKey(m_file, "file"));
	}
	
	/**
	 * This is where the magic starts. 
	 */
	private function parseAsmlFile():Void
	{
		//
		// Get root node (<asml> or <asml>).
		//
		var root:XMLNode = m_xml.firstChild;
		
		switch (m_mode)
		{
			case ASAsmlParsingMode.ASFullFile:
				//
				// Loop through top level nodes and handle as necessary.
				//
				var len:Number = root.childNodes.length;
				for (var i:Number = 0; i < len; i++)
				{
					switch (root.childNodes[i].nodeName)
					{
						case ASObjectsTag:
							parseObjectsNode(root.childNodes[i]);
							break;
							
						case ASConnectorsTag:
							parseConnectorsNode(root.childNodes[i]);
							break;
							
						default:
							//! exception?
							break;
					}
				}	
				break;
				
			case ASAsmlParsingMode.ASPartialObjects:
				parseObjectsNode(root);
				break;
				
			case ASAsmlParsingMode.ASPartialConnectors:
				parseConnectorsNode(root);
				break;
		}	
				
		asmlFileDidParse();
	}
	
	/**
	 * <p>Parses the contents of an objects node.</p>
	 * 
	 * <p>This method calls {@see #parseObjectsNodeWithParent}.</p>
	 */
	private function parseObjectsNode(node:XMLNode):Void
	{
		//
		// Find and parse the theme tag, if one exists.
		//
		var len:Number = node.childNodes.length;
		for (var i:Number = 0; i < len; i++)
		{
			var childNode:XMLNode = node.childNodes[i];
			var childName:String = childNode.nodeName;
			
			if (childName != ASThemeTag) {
				continue;
			}
			
			//
			// Record the ID
			//
			var id:String = childNode.attributes.id;
			delete childNode.attributes.id;
			
			//
			// Create theme.
			//
			var themeHandler:ASTagHandler = tagHandlerForClassName(childName);
			var theme:Object = themeHandler.parseNodeWithClassName(childNode, 
				childName);
				
			//
			// Associate the theme with its id.
			//
			if (null != id) {
				m_file.associateIdWithObject(id, theme);
			}
			
			//
			// Parse the theme assets
			//
			parseObjectsNodeWithParentHandlerIsRoot(childNode, theme, 
				themeHandler, false);
			
			//
			// Remove the theme node from the object node's children
			//
			node.childNodes.splice(i, 1);
			
			//
			// Stop processing
			//
			break;
		}
		
		m_file.setRootObjects(
			parseObjectsNodeWithParentHandlerIsRoot(node, null, null, true));
	}
	
	/**
	 * Parses the contents of the objects node <code>node</code> recursively, 
	 * adding children to the <code>parent</code> <code>NSObject</code>.
	 */
	private function parseObjectsNodeWithParentHandlerIsRoot(node:XMLNode, 
		parent:Object, handler:ASTagHandler, isRoot:Boolean):NSArray
	{			
		//
		// If we're dealing with the root, create an array to fill with the 
		// root nodes.
		//
		var roots:NSArray = isRoot ? NSArray.array() : null;
		
		var len:Number = node.childNodes.length;
		for (var i:Number = 0; i < len; i++)
		{
			//
			// Extract the class name.
			//
			var child:XMLNode = node.childNodes[i];
			var className:String = child.nodeName;
			
			//
			// Ignore any whitepace nodes. 
			//
			if (className == undefined) {
				continue;
			}
			
			if (null != m_aliases.objectForKey(className)) {
				className = m_aliases.objectForKey(className).toString();
			}
			
			//
			// Record the ID
			//
			var id:String = child.attributes.id;
			delete child.attributes.id;
			
			//
			// Get the handler and create the object.
			//
			var childHandler:ASTagHandler = tagHandlerForClassName(className);
			var obj:Object = childHandler.parseNodeWithClassName(child, 
				className);

			//
			// If the object is another reader (from an include tag),
			// register this reader as an observer and attach the necessary
			// objects to the reader's file object.
			//
			if (obj instanceof ASAsmlReader) {
				var reader:ASAsmlReader = ASAsmlReader(obj);
				reader.asmlFile().setParentObjectWithHandler(parent, handler);
				
				NSNotificationCenter.defaultCenter().
					addObserverSelectorNameObject(
						this, "childFileDidParse",
						ASAsmlReader.ASAsmlFileDidParseNotification,
						reader);
				
				m_childFileCount++;
				continue;
			}
			
			//
			// Associate the object with its id.
			//
			if (null != id) {
				m_file.associateIdWithObject(id, obj);
			}
			
			//
			// If we're parsing the root, add the obj to the root objects array
			//
			if (isRoot) {
				roots.addObject(obj);
			}
			
			//
			// Parse the child tree.
			//
			parseObjectsNodeWithParentHandlerIsRoot(child, obj, childHandler,
				false);
			
			//
			// Add the child to the parent if possible.
			//
			if (null != parent && null != handler) {
				handler.addChildToParent(obj, parent, child.attributes);
			}
		}
		
		return roots;
	}

	/**
	 * Parses the contents of an connectors node recursively.
	 */	
	private function parseConnectorsNode(node:XMLNode):Void
	{
		
	}
	
	/**
	 * This method is called when an include node contained by this asml
	 * file finishes loading.
	 */
	private function childFileDidParse(ntf:NSNotification):Void
	{		
		var file:ASAsmlFile = ASAsmlFile(
			ASAsmlReader(ntf.object).asmlFile());
		var parent:Object = file.parentObject();
		var handler:ASTagHandler = file.parentHandler();
		var roots:Array = file.rootObjects().internalList();
		var refs:Array = file.referenceProperties().internalList();
		var idToObjMap:Object = file.idToObjectDictionary().internalDictionary();
		var len:Number; 
		
		//
		// Loop through the partial file's roots and add them to their parent.
		//
		len = roots.length;
		for (var i:Number = 0; i < len; i++)
		{
			handler.addChildToParent(roots[i], parent, null);
		}
		
		//
		// Add all of the reference properties of the child file to this
		// reader's file.
		//
		len = refs.length;
		for (var i:Number = 0; i < len; i++)
		{
			m_file.addReferenceProperty(ASReferenceProperty(refs[i]));
		}
		
		//
		// Add the id to object mappings contained in the child file to this
		// reader's file.
		//
		for (var id:String in idToObjMap)
		{
			m_file.associateIdWithObject(id, idToObjMap[id]);
		}
		
		//
		// Release the child reader.
		//
		ASAsmlReader(ntf.object).release();
		
		m_childFileCount--;
		asmlFileDidParse();
	}
	
	//******************************************************															 
	//*              Reference Properties
	//******************************************************
	
	/**
	 * Adds a reference property to the file to be invoked after the initial 
	 * parsing is complete.
	 */
	public function addReferenceProperty(property:ASReferenceProperty):Void
	{
		m_file.addReferenceProperty(property);
	}
	
	//******************************************************															 
	//*                 Node Handlers
	//******************************************************
	
	/**
	 * Registers a class <code>className</code> to be handled by an
	 * {@link ASTagHandler} <code>handler</code>.
	 */
	public function registerTagWithHandler(className:String, 
		handler:ASTagHandler):Boolean
	{
		if (null != m_handlers.objectForKey(className)) {
			return false;
		}
		
		m_handlers.setObjectForKey(handler, className);

		return true;
	}
	
	/**
	 * <p>Returns the {@link ASTagHandler} associated with the class name
	 * <code>className</code>.</p>
	 * 
	 * <p>If no {@link ASTagHandler} can be found, the default tag handler is 
	 * returned.</p>
	 */
	public function tagHandlerForClassName(className:String):ASTagHandler
	{
		var handler:ASTagHandler = ASTagHandler(
			m_handlers.objectForKey(className));
			
		if (null != handler) {
			return handler;
		}
		
		//
		// Return default.
		//
		return defaultTagHandler();
	}
	
	/**
	 * Sets the default tag handler to be used if the tag being processed is
	 * not associated with anything else.
	 */
	public function setDefaultTagHandler(handler:ASTagHandler):Void
	{
		m_defaultHandler = handler;
	}
	
	/**
	 * Returns the default tag handler to be used if the tag being processed is
	 * not associated with anything else.
	 */
	public function defaultTagHandler():ASTagHandler
	{
		return m_defaultHandler;
	}
	
	//******************************************************															 
	//*              Postponed Operations
	//******************************************************
	
	/**
	 * <p>Adds an operation that will be performed after the parsing step.</p>
	 * 
	 * <p>For internal use only.</p>
	 */
	public function addPostponedOperation(op:NSInvocation):Void
	{
		m_postponedOperations.addObject(op);
	}
	
	/**
	 * Invokes all operations marked as being postponed.
	 */
	private function invokePostponedOperations():Void
	{
		var it:NSEnumerator = m_postponedOperations.objectEnumerator();
		var op:NSInvocation;
		
		while (null != (op = NSInvocation(it.nextObject()))) 
		{
			op.invoke();
		}
		
		m_postponedOperations.removeAllObjects();
	}
	
	//******************************************************															 
	//*                    Aliases
	//******************************************************
	
	/**
	 * <p>Registers a classname alias. For example, the asml file may contain
	 * a "button" node, which in reality should map to the <code>NSButton</code>
	 * class. These are simply names to ease the writing of the markup file.</p>
	 * 
	 * <p>This method returns <code>true</code> if no class is currently registered
	 * with <code>nodeName</code>, or <code>false</code> if one does already
	 * exist.</p>
	 * 
	 * <p><code>className</code> should be a fully registered class path (package
	 * and class name).</p>
	 */
	public function registerAlias(nodeName:String, className:String):Boolean
	{
		if (null != m_aliases.objectForKey(nodeName)) {
			return false;
		}
		
		m_aliases.setObjectForKey(className, nodeName);

		return true;
	}
	
	//******************************************************															 
	//*                 Notifications
	//******************************************************
	
	/**
	 * <p>This notification is posted to the default notification center when
	 * the asml file specified by the url parameter in {@link #initWithUrl}
	 * finishes loading.</p>
	 * 
	 * <p>The userInfo dictionary contains the following:
	 * <ul>
	 * <li>
	 * "success": <code>true</code> if the load was successful, or 
	 * <code>false</code> otherwise.
	 * </li>
	 * </ul></p>
	 */
	public static var ASAsmlFileDidLoadNotification:Number =
		ASUtils.intern("ASAsmlFileDidLoadNotification");
		
	/**
	 * <p>This notification is posted to the default notification center when 
	 * the asml file is successfully parsed.</p>
	 * 
	 * <p>The userInfo dictionary contains the following:
	 * <ul>
	 * <li>
	 * "file": The instance of the parsed asml file. This is an instance of
	 * {@link ASAsmlFile}.
	 * </li>
	 * </ul></p>
	 */
	public static var ASAsmlFileDidParseNotification:Number =
		ASUtils.intern("ASAsmlFileDidParseNotification");
}