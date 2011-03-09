/* See LICENSE for copyright and terms of use */

import org.actionstep.ASTreeView;
import org.actionstep.constants.NSBorderType;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.NSBrowserCell;
import org.actionstep.NSColor;
import org.actionstep.NSImage;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeColorNames;
import org.actionstep.themes.ASThemeImageNames;
import org.actionstep.themes.ASThemeProtocol;

/**
 * Used to draw the contents of a tree node.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.ASTreeCell extends NSBrowserCell {
	
	private static var BRANCH_RIGHT_MARGIN:Number = 7;
	private static var BRANCH_LEFT_MARGIN:Number = 4;
	private static var IMAGE_RIGHT_MARGIN:Number = 4;
	
	private var m_tree:ASTreeView;
	private var m_level:Number;
	private var m_branchHitRect:NSRect;
	private var m_branchWidth:Number;
	private var m_treeNode:Object;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASTreeCell</code> class.
	 */
	public function ASTreeCell() {
		super();
		m_level = 0;
	}
	
	/**
	 * Initializes the browser cell with the text <code>text</code>.
	 */
	public function initTextCell(aString:String):ASTreeCell {
		super.initTextCell(aString);		
		return this;
	}
	
	/**
	 * Initializes the browser cell as an image cell with an image of 
	 * <code>image</code>.
	 */
	public function initImageCell(anImage:NSImage):ASTreeCell {
		super.initImageCell(anImage);	
		return this;
	}
	
	//******************************************************
	//*         Releasing the object from memory
	//******************************************************
	
	public function release():Boolean {
		super.release();
//		m_tree = null;
//		m_treeNode = null;
		return true;
	}
	
	//******************************************************
	//*            Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the ASTreeCell instance.
	 */
	public function description():String {
		return "ASTreeCell(title=" + title() + ", level=" + level() + ")";
	}
	
	//******************************************************
	//*           Setting up tree information
	//******************************************************
	
	/**
	 * Returns this cell's tree.
	 * 
	 * @see #setTree()
	 */
	public function tree():ASTreeView {
		return m_tree;
	}
	
	/**
	 * Sets this cell's tree to <code>tree</code>.
	 * 
	 * @see #tree()
	 */
	public function setTree(tree:ASTreeView):Void {
		m_tree = tree;
	}
	
	/**
	 * Returns this cell's tree node.
	 * 
	 * @see #setTreeNode()
	 */
	public function treeNode():Object {
		return m_treeNode;
	}
	
	/**
	 * Sets this cell's tree node to <code>obj</code>.
	 * 
	 * @see #treeNode()
	 */
	public function setTreeNode(obj:Object):Void {
		m_treeNode = obj;
	}
	
	//******************************************************
	//*            Setting the indentation
	//******************************************************

	/**
	 * <p>Returns the depth level of this tree cell.</p>
	 * 
	 * <p>This value represents the depth of the node this cell displays.</p>
	 * 
	 * @see #setLevel()
	 */	
	public function level():Number {
		return m_level;
	}
	
	/**
	 * <p>Sets the depth level of this tree cell.</p>
	 * 
	 * <p>This value represents the depth of the node this cell displays.</p>
	 * 
	 * @see #level()
	 */
	public function setLevel(value:Number):Void {
		m_level = value;
	}
	
	//******************************************************
	//*          Getting the branch hit rectangle
	//******************************************************
	
	/**
	 * <p>Returns the rectangle the branch image occupies.</p>
	 * 
	 * <p>Used by the tree to expand or collapse the node through mouse clicks.</p>
	 */
	public function branchHitRect():NSRect {
		return m_branchHitRect;
	}
	
	//******************************************************
	//*             Accessing graphics images
	//******************************************************
	
	/**
	 * Returns the default image for collapsed branch ASTreeCells
	 */
	public static function branchImage():NSImage {
		return NSImage.imageNamed(ASThemeImageNames.NSTreeBranchImage);
	}
	
	/**
	 * Returns the default NSImage for collapsed branch ASTreeCells that are 
	 * highlighted (a lighter version of the image returned by 
	 * {@link #branchImage}).
	 */
	public static function highlightedBranchImage():NSImage {
		return NSImage.imageNamed(ASThemeImageNames.NSHighlightedTreeBranchImage);
	}
	
	/**
	 * Returns the default image for expanded branch ASTreeCells
	 */
	public static function openBranchImage():NSImage {
		return NSImage.imageNamed(ASThemeImageNames.NSTreeOpenBranchImage);
	}
	
	/**
	 * Returns the default NSImage for expanded branch ASTreeCells that are 
	 * highlighted (a lighter version of the image returned by 
	 * {@link #openBranchImage}).
	 */
	public static function highlightedOpenBranchImage():NSImage {
		return NSImage.imageNamed(ASThemeImageNames.NSHighlightedTreeOpenBranchImage);
	}
	
	/**
	 * Always returns the image regardless of cell type.
	 */
	public function image():NSImage {
		return m_image;
	}
	
	//******************************************************                               
	//*               Determining cell sizes          
	//******************************************************
	
	/**
	 * Returns the minimum size needed to completely display the receiver.
	 */
	public function cellSize():NSSize {
		var bw:Number = branchWidth();
		var bsize:NSSize;
		var csize:NSSize = NSSize.ZeroSize;
		
		//
		// Determine the border size
		//
		if (m_bordered) {
			bsize = NSBorderType.NSLineBorder.size;
		} else if(m_bezeled) {
			bsize = NSBorderType.NSBezelBorder.size;;
		} else {
			bsize = NSSize.ZeroSize;
		}
		
		//
		// Add branch image space
		//
		csize.width += m_branchWidth + BRANCH_LEFT_MARGIN + BRANCH_RIGHT_MARGIN;
    	
    	//
    	// Add indentation
    	//
    	csize.width += level() * m_tree.indentationPerLevel();
    	
    	//
    	// Add image size if we have one
    	//
    	if (image() != null) {
    		csize.width += image().size().width;
    	}
    	else if (alternateImage() != null) {
    		csize.width += alternateImage().size().width;
    	}
    	csize.width += IMAGE_RIGHT_MARGIN;
    	
    	//
    	// Add the text size
    	//
    	csize.width += font().getTextExtent(stringValue()).width;
    	
    	//
    	// Add the border to the cell size
    	//
    	csize.width += bsize.width * 2;
    	csize.height += bsize.height * 2;
    	
		return csize;
	}
	
	public function branchWidth():Number {
		//
		// Determine the branch width if necessary
		//
		if (m_branchWidth == null) {
			var img1:NSImage = getClass().openBranchImage();
			var img2:NSImage = getClass().branchImage();
			m_branchWidth = Math.max(img1.size().width, img2.size().width);
			m_branchHitRect = new NSRect(0, 0, m_branchWidth, m_branchWidth); 
		}
		
		return m_branchWidth;	
	}
	
	//******************************************************
	//*               Drawing the cell
	//******************************************************
	
	/**
	 * Draws the interior of the tree cell.
	 */
	public function drawInteriorWithFrameInView(cellFrame:NSRect, 
			controlView:NSView):Void {
		setControlView(controlView);
		
		//
		// Apply the offset to the cell frame
		//
		var dX:Number = level() * m_tree.indentationPerLevel();
		var contentFrame:NSRect = cellFrame.clone();
		contentFrame.origin.x += dX;
		contentFrame.size.width -= dX;
		
		//
		// Variable setup
		//
		var theme:ASThemeProtocol = ASTheme.current();
		var bw:Number = branchWidth();
		var expanded:Boolean = m_tree.isItemExpanded(treeNode());
		var g:ASGraphics = controlView.graphics();
		var showsFp:Boolean = showsFirstResponder();
		var mc:MovieClip = controlView.mcBounds();
		var tf:TextField = textField();
		var titleRect:NSRect = contentFrame.clone();
		var branchImg:NSImage = null;
		var cellImg:NSImage = null;
		var textColor:NSColor;
		var backColor:NSColor;
		
		//
		// Determine colors and images
		//
		if (isHighlighted() || state()) {
			if (!showsFp) {
				textColor = theme.colorWithName(
					ASThemeColorNames.ASBrowserSelectionText);
				backColor = theme.colorWithName(
					ASThemeColorNames.ASBrowserSelectionBackground);
			}
			
			//
			// Default to first responder colors
			//
			if (showsFp || textColor == null) {
				textColor = theme.colorWithName(
					ASThemeColorNames.ASBrowserFirstResponderSelectionText);	
			}
			if (showsFp || backColor == null) {
				backColor = theme.colorWithName(
					ASThemeColorNames.ASBrowserFirstResponderSelectionBackground);
			}
			
			//
			// Get a branch image if we aren't a leaf
			//
			if (!m_isLeaf) {
				branchImg = expanded
					? getClass().highlightedOpenBranchImage() 
					: getClass().highlightedBranchImage();
			}
			
			cellImg = alternateImage();
			if (cellImg == null) {
				cellImg = image();
			}
		} else {
			textColor = theme.colorWithName(ASThemeColorNames.ASBrowserText);
			backColor = theme.colorWithName(ASThemeColorNames.ASBrowserMatrixBackground);

			if (!m_isLeaf) {
				branchImg = expanded
					? getClass().openBranchImage()
					: getClass().branchImage();
			}
			
			cellImg = image();
		}
		
		//
		// Fill the background
		//
		g.brushDownWithBrush(backColor);
		g.drawRectWithRect(cellFrame, null, null);
		g.brushUp();
		
		//
		// Draw the branch image if there is one
		//
		if (branchImg != null) {
			var size:NSSize = branchImg.size();
			var position:NSPoint = contentFrame.origin.clone();
			
			position.x += BRANCH_LEFT_MARGIN;
			position.y = Math.max(titleRect.midY() - (size.height/2.), 0.);
			
			m_branchHitRect.origin = position.clone();
			
			branchImg.lockFocus(mc);
			branchImg.drawAtPoint(position);
			branchImg.unlockFocus();
			
			titleRect.size.width -= size.width + BRANCH_LEFT_MARGIN;
		}
		
		//
		// Skip 8 points + m_branchWidth from the left border
		//
		titleRect.origin.x += BRANCH_RIGHT_MARGIN + m_branchWidth;
		titleRect.size.width -= BRANCH_RIGHT_MARGIN + m_branchWidth;
		
		//
		// Draw the cell image if there is one
		//
		if (cellImg != null) {
			var size:NSSize;
			var position:NSPoint = NSPoint.ZeroPoint;
			
			size = cellImg.size();
			position.x = titleRect.minX();
			position.y = Math.max(titleRect.midY() - (size.height/2.),0.);

			cellImg.lockFocus(mc);
			cellImg.drawAtPoint(position);
			cellImg.unlockFocus();
			
			titleRect.origin.x += size.width + IMAGE_RIGHT_MARGIN;
			titleRect.size.width -= size.width + IMAGE_RIGHT_MARGIN;
		}
		
		// Draw the body of the cell
		tf.text = stringValue();
		validateTextField(titleRect, textColor);
	}
}