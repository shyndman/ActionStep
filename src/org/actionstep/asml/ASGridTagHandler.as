/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASAsmlReader;
import org.actionstep.asml.ASDefaultTagHandler;
import org.actionstep.asml.ASParsingUtils;
import org.actionstep.asml.ASTagHandler;
import org.actionstep.layout.ASGrid;
import org.actionstep.NSInvocation;
import org.actionstep.NSRect;

/**
 * This tag handler is used to handle <code>grid</code> tags. It creates
 * {@link ASGrid} instances.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASGridTagHandler extends ASDefaultTagHandler 
	implements ASTagHandler 
{
	//
	// Row and cell descriptor object types
	//
	private static var ASGridCellType:Number = 1;
	private static var ASGridRowType:Number = 2;
	
	/**
	 * The reader from which this tag handler is being executed.
	 */
	private var m_reader:ASAsmlReader;
	
	/**
	 * Creates a new instance of the <code>ASGridTagHandler</code> class
	 * with the {@link ASAsmlReader} <code>reader</code>.
	 */
	public function ASGridTagHandler(reader:ASAsmlReader)
	{
		m_reader = reader;
	}
	
	/**
	 * Adds the child view <code>child</code> to the grid.
	 */
	public function addChildToParent(child:Object, parent:Object, 
		remainingChildAttributes:Object):Void 
	{
		//
		// Parent is an ASGrid, so let's add the view contained in the
		// cell descriptor object.
		//
		if (parent instanceof ASGrid)
		{
			var grid:ASGrid = ASGrid(parent);
			
			//
			// Add each cell in the row one at a time.
			//
			var len:Number = child.views.length;
			for (var i:Number = 0; i < len; i++)
			{
				var cell:Object = child.views[i];
				grid.putViewAtRowColumnWithMinXMarginMaxXMarginMinYMarginMaxYMargin(
					cell.view, cell.row, cell.column, 
					cell.minXMargin, cell.maxXMargin,
					cell.minYMargin, cell.maxYMargin);
					
				if (cell.row == 0) {
					grid.setXResizingEnabledForColumn(cell.column,
						cell.enableXResizing);
				}
			}
			
			grid.setYResizingEnabledForRow(child.enableYResizing,
				child.views[0].row);
			
		}
		else if (parent.type == ASGridRowType)
		{
			//
			// In this case the parent is a row descriptor object, and the 
			// child is a child descriptor object that contains a newly
			// created view.
			//
			// We add the child into the view array of the parent.
			//
			child.row = parent.row;
			parent.views[child.column] = child;			
		}
		else // parent.type == ASGridCellType
		{
			//
			// In this case the parent is a cell descriptor object and the 
			// child is a view. All we do is associate the view with the cell
			// descriptor.
			//
			parent.view = child;
		}
	}

	/**
	 * Parses a grid, row or cell tag.
	 */
	public function parseNodeWithClassName(node:XMLNode, className:String)
		:Object 
	{
		//
		// Deal with grid case
		//
		if ("cell" != className && "row" != className && "column" != className) {
			return super.parseNodeWithClassName(node, className);
		}
		
		//
		// Match this cell/row with an index.
		//
		var siblings:Array = node.parentNode.childNodes;
		var idx:Number;
		
		var len:Number = siblings.length;
		for (var i:Number = 0; i < len; i++)
		{
			if (node == siblings[i])
			{
				idx = i;
				break;
			}
		}
		
		//
		// Construct a special cell/row object that contains information
		// pertaining to this cell/row, so that it can be properly added
		// to the grid.
		//
		var ret:Object = {};
				
		if ("cell" == className) 
		{
			ret.type = ASGridCellType;
			ret.column = idx;
			var margin:Number = ret.minXMargin = ret.maxXMargin = 
				ret.minYMargin = ret.maxYMargin =
					ASParsingUtils.extractTypedValueForAttributeKey(
						node.attributes, "margin", true, 0);
						
			var xMargin:Number = ret.minXMargin = ret.maxXMargin =
				ASParsingUtils.extractTypedValueForAttributeKey(
					node.attributes, "xMargins", true, margin);
					
			var yMargin:Number = ret.minYMargin = ret.maxYMargin =
				ASParsingUtils.extractTypedValueForAttributeKey(
					node.attributes, "yMargins", true, margin);
					
			ret.minXMargin = ASParsingUtils.extractTypedValueForAttributeKey(
					node.attributes, "minXMargin", true, xMargin);
			ret.maxXMargin = ASParsingUtils.extractTypedValueForAttributeKey(
					node.attributes, "maxXMargin", true, xMargin);
			ret.minYMargin = ASParsingUtils.extractTypedValueForAttributeKey(
					node.attributes, "minYMargin", true, yMargin);
			ret.maxYMargin = ASParsingUtils.extractTypedValueForAttributeKey(
					node.attributes, "maxYMargin", true, yMargin);
					
			//
			// Column x-resizing
			//
			ret.enableXResizing = ASParsingUtils.extractTypedValueForAttributeKey(
					node.attributes, "enableXResizing", true, true);
		}
		else
		{
			ret.type = ASGridRowType;
			ret.row = idx;
			ret.views = new Array(siblings.length);
			ret.enableYResizing = ASParsingUtils.extractTypedValueForAttributeKey(
				node.attributes, "enableYResizing", true, true);
		}
		
		return ret;
	}

	/**
	 * Initializes the grid with the correct number of rows and columns.
	 */
	private function initializeObject(obj:Object, frm:NSRect, node:XMLNode):Void
	{
		obj.initWithNumberOfRowsNumberOfColumns(node.childNodes.length,
			node.childNodes[0].childNodes.length);
		
		//
		// Defer a setFrame call
		//
		if (null != frm)
		{
			var op:NSInvocation = NSInvocation.
				invocationWithTargetSelectorArguments(obj, "setFrame", frm);
			m_reader.addPostponedOperation(op);
		} else {
			if (node.attributes.width != null) {
				var op:NSInvocation = NSInvocation.
					invocationWithTargetSelectorArguments(obj, "setFrameWidth", 
					Number(node.attributes.width));
				m_reader.addPostponedOperation(op);
			}
			else if (node.attributes.height != null) {
				var op:NSInvocation = NSInvocation.
					invocationWithTargetSelectorArguments(obj, "setFrameHeight", 
					Number(node.attributes.height));
				m_reader.addPostponedOperation(op);
			}
		}
	}
}