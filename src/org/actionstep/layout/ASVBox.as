/* See LICENSE for copyright and terms of use */

import org.actionstep.layout.ASGrid;
import org.actionstep.NSView;
import org.actionstep.NSBox;
import org.actionstep.NSRect;
import org.actionstep.constants.NSTitlePosition;
import org.actionstep.constants.NSBorderType;

/**
 * This is an ASTable with a single column. It offers a much simpler API, and
 * supports separators.
 * 
 * <code>#init()</code> should be used to initialize an instance of this class.
 * 
 * To add a view to the VBox layout, the <code>#addView()</code> method or one
 * of its related methods should be used.
 * 
 * To see an example using this class, see
 * <code>org.actionstep.test.ASTestVBox</code>.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.layout.ASVBox extends ASGrid
{
	private var m_hasViews:Boolean;
	private var m_defaultMinYMargin:Number;
	
	//******************************************************															 
	//*                    Construction
	//******************************************************
	
	/**
	 * Constructs a new instance of ASHBox.
	 */
	public function ASVBox()
	{
		super();
		
		m_hasViews = false;
		m_defaultMinYMargin = 0;
	}
	
	/**
	 * Initializes a default ASHBox with a single cell.
	 */
	public function init():ASVBox
	{
		super.initWithNumberOfRowsNumberOfColumns(1, 1);
		return this;
	}
	
	//******************************************************															 
	//*                   Properties
	//******************************************************
	
	/**
	 * Returns a string representation of the HBox.
	 */
	public function description():String
	{
		return "ASVBox()";
	}
	
	/**
	 * Returns the default minimum Y margin that is applied to new views.
	 */
	public function defaultMinYMargin():Number
	{
		return m_defaultMinYMargin;
	}
	
	/**
	 * Sets the default minimum Y margin to <code>aMargin</code>.
	 */
	public function setDefaultMinYMargin(aMargin:Number):Void
	{
		m_defaultMinYMargin = aMargin;
	}
	
	/**
	 * Returns the number of views held by this VBox.
	 */
	public function numberOfViews():Number
	{
		if (m_hasViews)
			return m_numRows;
		else
			return 0;
	}
	
	//******************************************************															 
	//*                  Adding Views
	//******************************************************
	
	/**
	 * Adds <code>aView</code> below the last view added with the 
	 * default minimum y margin and the resize flag set to true.
	 */
	public function addView(aView:NSView):Void
	{
		addViewEnableYResizingWithMinYMargin(aView, true, m_defaultMinYMargin);
	}

	/**
	 * Adds <code>aView</code> below the last view added with the 
	 * default minimum y margin and the resize flag set to <code>flag</code>.
	 */	
	public function addViewEnableYResizing(aView:NSView, flag:Boolean):Void
	{
		addViewEnableYResizingWithMinYMargin(aView, flag, m_defaultMinYMargin);		
	}
	
	/**
	 * Adds <code>aView</code> below the last view added with a 
	 * minimum y margin of <code>aMargin</code> and the resize flag set to true.
	 */
	public function addViewWithMinYMargin(aView:NSView, aMargin:Number):Void
	{
		addViewEnableYResizingWithMinYMargin(aView, true, aMargin);		
	}
	
	/**
	 * Adds <code>aView</code> below the last view added with a 
	 * minimum y margin of <code>aMargin</code> and the resize flag set to
	 * <code>flag</code>.
	 */
	public function addViewEnableYResizingWithMinYMargin(aView:NSView, 
		flag:Boolean, aMargin:Number):Void
	{			
		if (m_hasViews)
		{	
			var entries:Number = m_numRows;		
			super.addRow();
			super.setYResizingEnabledForRow(flag, entries);
			
			super.putViewAtRowColumnWithMinXMarginMaxXMarginMinYMarginMaxYMargin
				(aView, entries, 0,	0, 0, aMargin, 0);
		}
		else // !m_hasViews
		{
			super.setYResizingEnabledForRow(flag, 0);
			super.putViewAtRowColumnWithMinXMarginMaxXMarginMinYMarginMaxYMargin
				(aView, 0, 0, 0, 0, 0, 0);
				
			m_hasViews = true;
		}
	}
	
	//******************************************************															 
	//*                  Separators
	//******************************************************
	
	/**
	 * Adds a separator with a default min x margin.
	 */
	public function addSeparator():Void
	{
		addSeparatorWithMinYMargin(m_defaultMinYMargin);
	}
	
	/**
	 * Adds a separator with a min x margin of <code>aMargin</code>.
	 */
	public function addSeparatorWithMinYMargin(aMargin:Number):Void
	{
		var sep:NSView = getSeparator(aMargin);
		addViewEnableYResizingWithMinYMargin(sep, false, aMargin);
	}
	
	/**
	 * Gets a separator for use inside this VBox.
	 * 
	 * This method can be overridden to create something more interesting.
	 */
	public function getSeparator(aMargin:Number):NSView
	{
		var sep:NSBox = (new NSBox()).initWithFrame(new NSRect(0, 0, 2, 2));
		sep.setAutoresizingMask(NSView.MinYMargin | NSView.MaxYMargin
			| NSView.WidthSizable);
		sep.setTitlePosition(NSTitlePosition.NSNoTitle);
		sep.setBorderType(NSBorderType.NSGrooveBorder);
		return sep;
	}
}