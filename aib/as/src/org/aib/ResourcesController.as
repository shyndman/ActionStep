/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSScrollView;
import org.actionstep.NSTabView;
import org.actionstep.NSTabViewItem;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.aib.AIBApplication;
import org.aib.AIBObject;
import org.aib.resource.AsmlPropertiesView;
import org.aib.resource.ClassesView;
import org.aib.resource.ImagesView;
import org.aib.resource.InstancesView;
import org.aib.resource.SoundsView;
import org.aib.resource.ResourceWindow;

/**
 * Displays resources available for use.
 * 
 * TODO Expand comment
 * 
 * @author Scott Hyndman
 */
class org.aib.ResourcesController extends AIBObject {
	
	//******************************************************															 
	//*                    Constants
	//******************************************************
	
	private static var PADDING:Number = 5;
	private static var DEFAULT_WIDTH:Number = 400;
	private static var DEFAULT_HEIGHT:Number = 200;
	
	//******************************************************															 
	//*                 Class variables
	//******************************************************
	
	private static var g_instance:ResourcesController;
	
	//******************************************************															 
	//*                 Member variables
	//******************************************************
	
	private var m_window:NSWindow;
	private var m_tabs:NSTabView;
	private var m_curContents:NSView;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ResourcesController</code> class.
	 * 
	 * The class is a singleton. Access the controller using
	 * <code>ResourceWindow#instance()</code>.
	 */
	private function ResourcesController() {
	}
	
	/**
	 * Initializes the resources controller.
	 */
	public function init():ResourcesController {
		super.init();
		createWindow();
		createContentView();
				
		return this;
	}
	
	/**
	 * Creates the window for the controller.
	 */
	private function createWindow():Void {
		m_window = (new ResourceWindow()).initWithContentRectStyleMask(
			new NSRect(20, 300, DEFAULT_WIDTH, DEFAULT_HEIGHT),
			NSWindow.NSClosableWindowMask 
			| NSWindow.NSMiniaturizableWindowMask
			| NSWindow.NSResizableWindowMask
			| NSWindow.NSTitledWindowMask);
		m_window.rootView().setHasShadow(true);
		m_window.display();
		m_window.setBackgroundColor(ASColors.lightGrayColor()
			.adjustColorBrightnessByFactor(1.4));
	}
	
	/**
	 * Creates the content view for the resources window.
	 */
	private function createContentView():Void {
		var stg:NSView = m_window.contentView();
		var stgFrm:NSRect = stg.frame();
		var typeHolderHeight:Number = 36;
		
		//
		// Create tab view and tabs
		//
		m_tabs = new NSTabView();
		m_tabs.initWithFrame((NSRect.withOriginSize(
				NSPoint.ZeroPoint, m_window.contentSize())
			).insetRect(PADDING, PADDING));
		m_tabs.setAutoresizingMask(
			NSView.HeightSizable |
			NSView.WidthSizable);
		stg.addSubview(m_tabs);

		m_tabs.addTabViewItem(createInstancesTab());
		m_tabs.addTabViewItem(createClassesTab());
		m_tabs.addTabViewItem(createImagesTab());
		m_tabs.addTabViewItem(createSoundsTab());
		m_tabs.addTabViewItem(createAsmlPropertiesTab());
		
		m_tabs.selectFirstTabViewItem(this);
	}
	
	/**
	 * Creates the instances tab
	 */
	private function createInstancesTab():NSTabViewItem {
		var item:NSTabViewItem = (new NSTabViewItem()).initWithIdentifier("instances");
		item.setLabel(AIBApplication.stringForKeyPath("Resources.Instances.Name"));
		item.setView(createTabScrollViewWithDocument(
			(new InstancesView()).init()));
		return item;
	}
	
	/**
	 * Creates the classes tab
	 */
	private function createClassesTab():NSTabViewItem {
		var item:NSTabViewItem = (new NSTabViewItem()).initWithIdentifier("classes");
		item.setLabel(AIBApplication.stringForKeyPath("Resources.Classes.Name"));
		item.setView(createTabScrollViewWithDocument(
			(new ClassesView()).init()));
		return item;
	}
	
	/**
	 * Creates the images tab
	 */
	private function createImagesTab():NSTabViewItem {
		var item:NSTabViewItem = (new NSTabViewItem()).initWithIdentifier("images");
		item.setLabel(AIBApplication.stringForKeyPath("Resources.Images.Name"));
		item.setView(createTabScrollViewWithDocument(
			(new ImagesView()).init()));
		return item;
	}
	
	/**
	 * Creates the sounds tab
	 */
	private function createSoundsTab():NSTabViewItem {
		var item:NSTabViewItem = (new NSTabViewItem()).initWithIdentifier("sounds");
		item.setLabel(AIBApplication.stringForKeyPath("Resources.Sounds.Name"));
		item.setView(createTabScrollViewWithDocument(
			(new SoundsView()).init()));
		return item;
	}
	
	/**
	 * Creates the ASML properties tab
	 */
	private function createAsmlPropertiesTab():NSTabViewItem {
		var item:NSTabViewItem = (new NSTabViewItem()).initWithIdentifier("asml");
		item.setLabel(AIBApplication.stringForKeyPath("Resources.ASML.Name"));
		item.setView(createTabScrollViewWithDocument(
			(new AsmlPropertiesView()).init()));
		return item;
	}
	
	/**
	 * Creates a scrollview for a tab, using <code>aView</code> as its document
	 * view.
	 */
	private function createTabScrollViewWithDocument(aView:NSView):NSScrollView {
		var sv:NSScrollView = (new NSScrollView()).initWithFrame(
			m_tabs.contentRect()
		);

		aView.setFrameSize(sv.contentSize());
		sv.setDocumentView(aView);
		return sv;
	}
	
	//******************************************************
	//*                Getting the window
	//******************************************************
	
	/**
	 * Returns the window used by the resource controller.
	 */
	public function window():NSWindow {
		return m_window;
	}
	
	//******************************************************															 
	//*               Getting the instance
	//******************************************************
	
	/**
	 * Returns the resource controller instance.
	 */
	public static function instance():ResourcesController {
		if (null == g_instance) {
			g_instance = (new ResourcesController()).init();
		}
		
		return g_instance;
	}
}