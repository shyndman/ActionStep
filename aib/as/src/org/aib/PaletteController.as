/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColoredView;
import org.actionstep.ASColors;
import org.actionstep.ASDebugger;
import org.actionstep.ASStringFormatter;
import org.actionstep.ASUtils;
import org.actionstep.constants.NSButtonType;
import org.actionstep.constants.NSDragOperation;
import org.actionstep.constants.NSMatrixMode;
import org.actionstep.NSArray;
import org.actionstep.NSCell;
import org.actionstep.NSDraggingSource;
import org.actionstep.NSImage;
import org.actionstep.NSMatrix;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.aib.AIBApplication;
import org.aib.AIBObject;
import org.aib.palette.PaletteButtonCell;
import org.aib.palette.PaletteProtocol;
import org.aib.ui.ToolWindow;

/**
 * The palette controller. This controller creates the palette window
 * which contains palettes that are used for creating instances of controls.
 * 
 * @author Scott Hyndman
 */
class org.aib.PaletteController extends AIBObject 
	implements NSDraggingSource {
	
	//******************************************************															 
	//*                    Constants
	//******************************************************
	
	private static var DEFAULT_WIDTH:Number = 300;
	private static var DEFAULT_HEIGHT:Number = 200;
	
	//******************************************************															 
	//*                 Class variables
	//******************************************************
	
	private static var g_instance:PaletteController;
	
	//******************************************************															 
	//*                 Member variables
	//******************************************************
	
	private var m_window:NSWindow;
	private var m_typeSelector:NSMatrix;
	private var m_palettes:NSArray;
	private var m_paletteContentView:NSView;
	private var m_curContents:NSView;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>PaletteController</code> class.
	 * 
	 * The class is a singleton. Access the controller using
	 * <code>PaletteController#instance()</code>.
	 */
	private function PaletteController() {
		m_palettes = NSArray.array();
	}
	
	/**
	 * Initializes the palette controller.
	 */
	public function init():PaletteController {
		super.init();
		createWindow();
		createContentView();
		return this;
	}
	
	/**
	 * Creates the window for the controller.
	 */
	private function createWindow():Void {
		m_window = (new ToolWindow()).initWithContentRectStyleMask(
			new NSRect(300, 60, DEFAULT_WIDTH, DEFAULT_HEIGHT),
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
	 * Creates the content view for the controller window.
	 */
	private function createContentView():Void {
		var stg:NSView = m_window.contentView();
		var stgFrm:NSRect = stg.frame();
		var typeHolderHeight:Number = 45;
		
		//
		// Create holder
		//		
		var typeHolder:ASColoredView = new ASColoredView();
		typeHolder.initWithFrame(new NSRect(-2,0,stgFrm.size.width+4,typeHolderHeight));
		typeHolder.setAutoresizingMask(NSView.WidthSizable);
		typeHolder.setBackgroundColor(null);
		typeHolder.setBorderColor(ASColors.blackColor());
		stg.addSubview(typeHolder);
		
		//
		// Create prototype cell
		//
		var pButtonCell:PaletteButtonCell = new PaletteButtonCell();
		pButtonCell.initImageCell(null);
		pButtonCell.setButtonType(NSButtonType.NSPushOnPushOffButton);		
		
		//
		// Create matrix
		//
		m_typeSelector = new NSMatrix();
		m_typeSelector.initWithFrameModePrototypeNumberOfRowsNumberOfColumns(
			NSRect.ZeroRect, 
			NSMatrixMode.NSRadioModeMatrix,
			pButtonCell,
			0, 0);
		m_typeSelector.setAllowsEmptySelection(false);
		m_typeSelector.setIntercellSpacing(new NSSize(3,3));
		m_typeSelector.setCellSize(new NSSize(35, 35));
		m_typeSelector.setTarget(this);
		m_typeSelector.setAction("paletteTypeDidChange");
		typeHolder.addSubview(m_typeSelector);
		
		//
		// Create content view
		//
		m_paletteContentView = new NSView();
		m_paletteContentView.initWithFrame(new NSRect(0,typeHolderHeight,
			stgFrm.size.width,stgFrm.size.height - typeHolderHeight));
		m_paletteContentView.setAutoresizingMask(
			NSView.HeightSizable
			| NSView.WidthSizable);
		stg.addSubview(m_paletteContentView);
	}
	
	//******************************************************															 
	//*               Setting the palettes
	//******************************************************
	
	/**
	 * Creates the palettes using the class names found in <code>types</code> 
	 * and adds their representations to the palette window.
	 */
	public function createPalettesWithTypes(types:NSArray):Void {
		var ttFormat:String = AIBApplication.stringForKeyPath(
			"Palettes.ToolTipFormat");
			
		var arr:Array = types.internalList();
		var len:Number = arr.length;
		
		//
		// Create the palettes
		//
		for (var i:Number = 0; i < len; i++) {
			var cls:Function = eval(arr[i]);
			var p:PaletteProtocol = PaletteProtocol(
				ASUtils.createInstanceOf(cls));
			
			//
			// Make sure the palette was created.
			//
			if (p == null) {
				trace("The palette named " + arr[i] + " could not be created.",
					ASDebugger.WARNING);
				continue;
			}
			
			//
			// Initialize and add the palette
			//
			p.initWithPaletteController(this);
			m_palettes.addObject(p);
			
			//
			// Update the matrix
			//
			m_typeSelector.addColumn();
			var cell:NSCell = m_typeSelector.cellAtRowColumn(0, i);
			cell.setTag(i);
			cell.setTitle("");
			cell.setImage(p.buttonImage());
			m_typeSelector.setToolTipForCell(
				ASStringFormatter.formatString(
					ttFormat,
					NSArray.arrayWithObject(p.buttonTipText())), 
				cell);
		}
		
		m_typeSelector.sizeToCells();
		m_typeSelector.setNeedsDisplay(true);
		paletteTypeDidChange(m_typeSelector);
	}
	
	//******************************************************															 
	//*                 Action handlers
	//******************************************************
	
	/**
	 * Fired when the palette type is changed by clicking on its related button.
	 */
	private function paletteTypeDidChange(sender:Object):Void {		
		//
		// Get the palette
		//
		var palette:PaletteProtocol = PaletteProtocol(
			m_palettes.objectAtIndex(m_typeSelector.selectedCell().tag()));
			
		//
		// Change the window title
		//
		m_window.setTitle(AIBApplication.stringForKeyPath(
			"Palettes.WindowTitle") + " - " + palette.paletteName());
		
		//
		// Add the palette contents to the palette window
		//
		var contents:NSView = palette.paletteContents();
		
		if (m_curContents != null) {
			m_paletteContentView.replaceSubviewWith(m_curContents,
				contents);
		} else {
			m_paletteContentView.addSubview(contents);
		}
		
		m_curContents = contents;
	}
	
	//******************************************************															 
	//*              NSDraggingSource Methods
	//******************************************************
	
	function draggingSourceOperationMask():Number {
		return NSDragOperation.NSDragOperationCopy.valueOf();
	}

	function ignoreModifierKeysWhileDragging():Boolean {
		return true;
	}

	function draggedImageBeganAt(anImage:NSImage, aPoint:NSPoint):Void {
	}

	function draggedImageEndedAtOperation(anImage:NSImage, aPoint:NSPoint, 
		operation:NSDragOperation):Void {
	}

	function draggedImageMovedTo(anImage:NSImage, aPoint:NSPoint):Void {
	}
	
	//******************************************************
	//*                Getting the window
	//******************************************************
	
	/**
	 * Returns the window used by the palette window.
	 */
	public function window():NSWindow {
		return m_window;
	}
	
	//******************************************************															 
	//*               Getting the instance
	//******************************************************
	
	/**
	 * Returns the palette window instance.
	 */
	public static function instance():PaletteController {
		if (null == g_instance) {
			g_instance = (new PaletteController()).init();
		}
		
		return g_instance;
	}
}