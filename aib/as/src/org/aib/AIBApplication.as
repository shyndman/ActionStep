/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.ASGradientView;
import org.actionstep.ASUtils;
import org.actionstep.graphics.ASGradient;
import org.actionstep.graphics.ASGraphicUtils;
import org.actionstep.graphics.ASLinearGradient;
import org.actionstep.menu.NSMenuView;
import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSMenu;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.plastic.ASPlasticTheme;
import org.aib.AIBObject;
import org.aib.configuration.AppSettings;
import org.aib.configuration.ConfigSections;
import org.aib.controls.EditableButton;
import org.aib.controls.EditableViewDecorator;
import org.aib.controls.EditableWindow;
import org.aib.InspectorController;
import org.aib.localization.StringTable;
import org.aib.menu.MenuBuilder;
import org.aib.menu.MenuTarget;
import org.aib.PaletteController;
import org.aib.ResourcesController;
import org.aib.stage.guides.ActionStepGuidelines;
import org.aib.stage.guides.GuidelineProtocol;
import org.aib.ui.ToolWindow;
import org.aib.UserPrefs;
import org.aib.util.ImageLoader;

import flash.geom.Matrix;

/**
 * Main entry point for the application.
 * 
 * @author Scott Hyndman
 */
class org.aib.AIBApplication extends AIBObject {
	
	//******************************************************															 
	//*                    Constants
	//******************************************************
	
	public static var AIB_URL:String 			= "aib/";
	public static var RESOURCES_PATH:String 	= "res/";
	public static var CONFIG_FILE_PATH:String 	= RESOURCES_PATH + "app.config";
	public static var LANG_PATH:String			= RESOURCES_PATH;
	public static var IMAGES_PATH:String		= RESOURCES_PATH + "images/";
	
	//******************************************************															 
	//*                   Class members
	//******************************************************
	
	private static var g_applicationDefaults:NSDictionary;
	private static var g_stringTable:StringTable;
	private static var g_stringTableLoaded:Boolean;
	private static var g_librariesToLoad:Number;
	private static var g_lang:String;
	private static var g_imagesLoaded:Boolean;
	private static var g_guidelines:GuidelineProtocol;
	private static var g_usingGuidelines:Boolean;
	
	//******************************************************															 
	//*                  Member variables
	//******************************************************
	
	private var m_userPrefs:UserPrefs;
	private var m_palette:PaletteController;
	private var m_inspector:InspectorController;
	private var m_resources:ResourcesController;
	private var m_backgroundWindow:NSWindow;
	private var m_menuTarget:MenuTarget;
		
	//******************************************************															 
	//*                    Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the AIB application.
	 * 
	 * The constructor is private because there is only ever one application.
	 */
	private function AIBApplication() {
	}
	
	/**
	 * Initializes the application.
	 */
	public function init():AIBApplication {
		super.init();
		
		//
		// Build background window
		//
		createBackgroundWindow(); 
		
		//
		// Run the application
		//
		NSApplication.sharedApplication().run();
		ASUtils.initializeClassesWithPackage(_global.org.aib, "org.aib");
		
		//
		// Register as notification observer
		//
		NSNotificationCenter.defaultCenter().addObserverSelectorNameObject(
			this, "stageDidResize", 
			NSApplication.ASStageDidResizeNotification,
			null);
		
		//
		// Load the configuration file.
		//
		loadConfigFile(AIB_URL + CONFIG_FILE_PATH);
		
		return this;
	}
	
	/**
	 * Creates the AIB UI.
	 */
	private function createUI():Void {
		//
		// Decorate the view classes
		//
		EditableViewDecorator.decorateViewsWithPackage(
			_global.org.aib.controls);
		
		//
		// Build the guidelines object
		//
		createGuidelines();
		
		//
		// Build the palette window
		//
		m_palette = PaletteController.instance();
		m_palette.createPalettesWithTypes(
			AppSettings.sectionWithName(ConfigSections.PALETTES));
		m_palette.window().setFrame(m_userPrefs.paletteFrame());
			
		//
		// Build the inspector window
		//
		m_inspector = InspectorController.instance();
		m_inspector.createInspectorsWithTypes(
			AppSettings.sectionWithName(ConfigSections.INSPECTORS));
		m_inspector.window().setFrame(m_userPrefs.inspectorFrame());
		
		//
		// Build the resources window
		//
		m_resources = ResourcesController.instance();
		m_resources.window().setFrame(m_userPrefs.resourcesFrame());
		
		//
		// Create the default window
		//
		createDefaultWindow();
		
		//
		// Create the menu
		//
		createMainMenu();
	}
	
	/**
	 * Creates the default application window
	 */
	private function createDefaultWindow():Void {
		var wnd:EditableWindow = new EditableWindow();
		wnd.initWithContentRect(new NSRect(40, 80, 400, 300));
		wnd.setBackgroundColor(ASColors.whiteColor());
		wnd.setTitle(stringForKeyPath("Defaults.WindowTitle"));
		wnd.display();
		
		var btn:EditableButton = new EditableButton();
		btn.initWithFrame(new NSRect(10, 10, 100, 25));
		wnd.contentView().addSubview(btn); 
	}
	
	/**
	 * Creates the window that fills the stage background.
	 */
	private function createBackgroundWindow():Void {
		m_backgroundWindow = (new ToolWindow()).initWithContentRectStyleMask(
			new NSRect(0, 0, Stage.width, Stage.height),
			NSWindow.NSBorderlessWindowMask);
		m_backgroundWindow.setLevel(NSWindow.NSDesktopWindowLevel);
		var content:ASGradientView = new ASGradientView();
		content.initWithFrame(new NSRect(0, 0, Stage.width, Stage.height));
		content.setAutoresizingMask(NSView.HeightSizable | NSView.WidthSizable);
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(1024, 1024, 
			ASGraphicUtils.convertDegreesToRadians(ASGradient.ANGLE_TOP_TO_BOTTOM),
			0, 0);
		var gradient:ASGradient = new ASLinearGradient(
			[
				ASColors.lightGrayColor(),
				ASColors.grayColor()
			],
			[0, 255],
			matrix);
		content.setGradient(gradient);
		m_backgroundWindow.setContentView(content);
		m_backgroundWindow.display();
	}
	
	/**
	 * Creates the guidelines.
	 */
	private function createGuidelines():Void {
		g_usingGuidelines = true;
		g_guidelines = (new ActionStepGuidelines()).init();
	}
	
	/**
	 * Creates the main menu for the application.
	 * 
	 */
	private function createMainMenu():Void {
		m_menuTarget = (new MenuTarget()).initWithApplication(this);
		var menu:NSMenu = MenuBuilder.buildMenuWithTarget(m_menuTarget);
		menu.window().display();
	}
	
	//******************************************************															 
	//*              Loading necessary assets
	//******************************************************
	
	/**
	 * Begins loading the configuration file at <code>url</code>.
	 * 
	 * <code>#configFileDidLoad()</code> is called upon completion.
	 */
	private function loadConfigFile(url:String):Void {
		AppSettings.loadConfigWithContentsOfURLObjectSelector(url,
			this, "configFileDidLoad");
	}
	
	/**
	 * Fired when the config file finishes loading.
	 * 
	 * This begins the loading of external libraries and the string table.
	 */
	private function configFileDidLoad(ntf:NSNotification):Void {
		g_lang = AppSettings.appSettingWithName("language");
		
		//
		// Begin loading string table
		//
		loadStringTable(AIB_URL + LANG_PATH + g_lang + "/strings.xml");
		
		//
		// Load images
		//
		loadImages();
		
		//
		// Load external libraries
		//
		loadLibraries();
		
		//
		// Load user preferences
		//
		loadUserPreferences();
	}
	
	/**
	 * Begins loading the images described in the <code>"images"</code> 
	 * section of the configuration file.
	 */
	private function loadImages():Void {
		g_imagesLoaded = false;
		
		var loader:ImageLoader = ImageLoader.instance();
		loader.setBaseUrl(AIB_URL + IMAGES_PATH);
		loader.loadImages(AppSettings.sectionWithName(ConfigSections.IMAGES));
		NSNotificationCenter.defaultCenter().addObserverSelectorNameObject(
			this, "imagesDidLoad",
			ImageLoader.ImagesDidLoadNotification,
			loader);
	}
	
	/**
	 * Fired when the images finish loading.
	 */
	private function imagesDidLoad(ntf:NSNotification):Void {
		g_imagesLoaded = true;
		
		if (assetsLoaded()) {
			applicationAssetsDidLoad();
		}
	}
	
	/**
	 * Loads the user preferences.
	 */
	private function loadUserPreferences():Void {
		userPrefsDidLoad(null);
	}
	
	/**
	 * Fired when the user preferences finish loading.
	 */
	private function userPrefsDidLoad(ntf:NSNotification):Void {
		m_userPrefs = new UserPrefs();
	}
	
	/**
	 * Creates the application string table.
	 */
	private function loadStringTable(url:String):Void {		
		//
		// Create string table
		//
		g_stringTableLoaded = false;
		g_stringTable = (new StringTable()).initWithContentsOfURL(url);
		
		//
		// Register for notification
		//
		NSNotificationCenter.defaultCenter().addObserverSelectorNameObject(
			this, "stringTableDidLoad", 
			StringTable.StringTableDidLoadNotification,
			g_stringTable);
	}
	
	/**
	 * Fired when the string table finishes loading.
	 * 
	 * This results in the application beginning.
	 */
	private function stringTableDidLoad(ntf:NSNotification):Void {
		g_stringTableLoaded = Boolean(ntf.userInfo.objectForKey("AIBSuccess"));

		if (assetsLoaded()) {
			applicationAssetsDidLoad();
		}
	}

	/**
	 * Loads all requested external libraries.
	 */
	private function loadLibraries():Void {
		var libs:NSArray = AppSettings.sectionWithName(
			ConfigSections.LIBRARIES);
		
		g_librariesToLoad = libs == null ? 0 : libs.count();
		var arr:Array = libs.internalList();
		
		for (var i:Number = 0; i < g_librariesToLoad; i++) {
			NSApplication.loadLibraryWithCallbackSelectorData(
				arr[i].toString(), this, "libraryDidLoad", i);
		}		
	}
	
	/**
	 * Called when a library is loaded.
	 */
	private function libraryDidLoad(data:Object, success:Boolean):Void {
		g_librariesToLoad--;
		
		if (assetsLoaded()) {
			applicationAssetsDidLoad();
		}
	}
	
	/**
	 * Returns <code>true</code> if the application assets have loaded. 
	 */
	private function assetsLoaded():Boolean {
		return g_librariesToLoad == 0 && g_stringTableLoaded 
			&& m_userPrefs != null && g_imagesLoaded;
	}
	
	/**
	 * Called when all the application assets have finished loading.
	 */	
	private function applicationAssetsDidLoad():Void {		
		createUI();
	}
	
	//******************************************************															 
	//*             Getting application strings
	//******************************************************
	
	/**
	 * Returns the string table used by AIB.
	 */
	public static function stringTable():StringTable {
		return g_stringTable;
	}
	
	/**
	 * <p>Returns the string with the key path <code>keyPath</code> from the 
	 * application's current string pool.</p>
	 * 
	 * <p>This is important for localization issues.</p>
	 * 
	 * @see StringTable
	 */
	public static function stringForKeyPath(keyPath:String):String {
		return g_stringTable.stringForKeyPath(keyPath);
	}
	
	//******************************************************
	//*               Getting the guidelines
	//******************************************************
	
	/**
	 * Returns the guidelines used by this application.
	 */
	public static function guidelines():GuidelineProtocol {
		return g_guidelines;
	}
	
	public static function usingGuidelines():Boolean {
		return g_usingGuidelines;
	}
	
	public static function setUsingGuidelines(flag:Boolean):Void {
		g_usingGuidelines = flag;
	}
	
	//******************************************************
	//*               Notification observers
	//******************************************************
	
	/**
	 * Resizes the background window.
	 */
	private function stageDidResize(ntf:NSNotification):Void {
		m_backgroundWindow.setFrame(NSRect.withOriginSize(
			NSPoint.ZeroPoint,
			NSSize(ntf.userInfo.objectForKey("ASNewSize"))));
		NSMenuView.setBounds(NSSize(ntf.userInfo.objectForKey("ASNewSize")));
	}
	
	//******************************************************															 
	//*                  Main entry point
	//******************************************************
	
	/**
	 * The main entry point for the application.
	 */
	public static function main():Void {
		Stage.align="LT";
		Stage.scaleMode="noScale";
		ASTheme.setCurrent(new ASPlasticTheme());
		//ASDebugger.setLevel(ASDebugger.DEBUG);
		var app:AIBApplication =(new AIBApplication()).init();
	}
}