/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.NSRect;
import org.actionstep.NSPoint;

/**
 * Displays a series of equally sized views in a tiled format.
 * 
 * @author Scott Hyndman
 */
class org.aib.ui.TileView extends NSView {
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_tiles:NSArray;
	private var m_tileSize:NSSize;
	private var m_tileSpacing:NSSize;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>TileView</code> class.
	 */
	public function TileView() {
		m_tiles = NSArray.array();
	}
	
	/**
	 * Initializes the tile view with a frame of <code>aRect</code>, a tile
	 * size of <code>size</code> and tile spacing of <code>spacing</code>.
	 * 
	 * @see #tileSize()
	 * @see #tileSpacing()
	 */
	public function initWithFrameTileSizeSpacing(aRect:NSRect, size:NSSize, 
			spacing:NSSize):TileView {
		super.initWithFrame(aRect);
		setTileSize(size);
		setTileSpacing(spacing);
		return this;
	}
	
	//******************************************************
	//*               Setting tile attributes
	//******************************************************
	
	/**
	 * Returns the size of the tiles.
	 */
	public function tileSize():NSSize {
		return m_tileSize.clone();
	}
	
	/**
	 * <p>Sets the size of the tiles to <code>aSize</code>.</p>
	 * 
	 * <p>This method should be followed by a call to {@link #tile} if you would
	 * like the changes to be made immediately.</p>
	 */
	public function setTileSize(aSize:NSSize):Void {
		if (aSize.isEqual(tileSize())) {
			return;
		}
		
		m_tileSize = aSize.clone();
		
		//
		// Resize tiles
		//
		var arr:Array = m_tiles.internalList();
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			NSView(arr[i]).setFrameSize(aSize);
		} 
	}
	
	/**
	 * Returns the spacing between tiles and their peers, and tiles and the
	 * borders of the view.
	 */
	public function tileSpacing():NSSize {
		return m_tileSpacing.clone();
	}
	
	/**
	 * <p>Sets the spacing between tiles and their peers, and tiles and the
	 * borders of the view to <code>aSize</code></p>
	 * 
	 * <p>This method should be followed by a call to {@link #tile} if you would
	 * like the changes to be made immediately.</p>
	 */
	public function setTileSpacing(aSize:NSSize):Void {
		m_tileSpacing = aSize.clone();
	}
	
	//******************************************************
	//*              Adding and removing tiles
	//******************************************************
	
	/**
	 * <p>Adds a tile to the end of the tile list.</p>
	 * 
	 * <p>This marks the receiver as needing redisplay.</p>
	 */
	public function addTile(aView:NSView):Void {
		insertTileAtIndex(aView, m_tiles.count());
	}
	
	/**
	 * <p>Inserts a tile into the tile list at the index <code>index</code>.</p>
	 * 
	 * <p>This marks the receiver as needing redisplay.</p>
	 */
	public function insertTileAtIndex(aView:NSView, index:Number):Void {
		addSubview(aView);
		aView.setFrameSize(tileSize());
		m_tiles.insertObjectAtIndex(aView, index);
		setNeedsDisplay(true);
	}
	
	/**
	 * <p>Removes the tile <code>aView</code> from the tile list.</p>
	 * 
	 * <p>If the tile list is changed, the receiver is marked as needing 
	 * redisplay.</p>
	 */
	public function removeTile(aView:NSView):Void {
		var count:Number = m_tiles.count();
		m_tiles.removeObject(aView);
		if (count != m_tiles.count()) {
			setNeedsDisplay(true);
		}
	}
	
	//******************************************************
	//*                 Drawing the view
	//******************************************************
	
	/**
	 * Arranges the views according to the spacing and size rules.
	 */
	public function tile():Void {
		var frame:NSRect = frame();
		var size:NSSize = tileSize();
		var spacing:NSSize = tileSpacing();
		var tiles:Array = m_tiles.internalList();
		
		//
		// Get the available width
		//
		var width:Number = frame.size.width;
		width -= spacing.width;
		
		//
		// Calculate the number of columns and rows
		//
		var cols:Number = Math.floor(width / (spacing.width + size.width));
		var rows:Number = Math.ceil(tiles.length / cols);
		
		//
		// Build x and y positions
		//
		var xPositions:Array = [spacing.width];
		for (var i:Number = 1; i < cols; i++) {
			xPositions[i] = xPositions[i - 1] + spacing.width + size.width;
		}
		
		var yPositions:Array = [spacing.height];
		for (var i:Number = 1; i < rows; i++) {
			yPositions[i] = yPositions[i - 1] + spacing.height + size.height;
		}
		
		//
		// Position everything
		//
		for (var i:Number = 0; i < rows; i++) { // rows
			for (var j:Number = 0; j < cols; j++) { // columns
				var origin:NSPoint = new NSPoint(xPositions[j], yPositions[i]);
				NSView(tiles[i * cols + j]).setFrameOrigin(origin);
			}
		}
	}
	
	public function drawRect(aRect:NSRect):Void {
		tile();
	}
}