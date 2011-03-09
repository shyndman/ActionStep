/* See LICENSE for copyright and terms of use */

import org.actionstep.layout.ASGrid;
import org.actionstep.NSView;
import org.actionstep.NSBox;
import org.actionstep.NSRect;
import org.actionstep.constants.NSTitlePosition;
import org.actionstep.constants.NSBorderType;

/**
 * This is an ASTable with a single row. It offers a much simpler API, and
 * supports separators.
 * 
 * <code>#init()</code> should be used to initialize an instance of this class.
 * 
 * To add a view to the HBox layout, the <code>#addView()</code> method or one
 * of its related methods should be used.
 * 
 * To see an example using this class, see
 * <code>org.actionstep.test.ASTestHBox</code>.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.layout.ASHBox extends ASGrid
{
	private var m_hasViews:Boolean;
	private var m_defaultMinXMargin:Number;
	
	//******************************************************															 
	//*                    Construction
	//******************************************************
	
	/**
	 * Constructs a new instance of ASHBox.
	 */
	public function ASHBox()
	{
		super();
		
		m_hasViews = false;
		m_defaultMinXMargin = 0;
	}
	
	/**
	 * Initializes a default ASHBox with a single cell.
	 */
	public function init():ASHBox
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
		return "ASHBox()";
	}
	
	/**
	 * Returns the default minimum X margin that is applied to new views.
	 */
	public function defaultMinXMargin():Number
	{
		return m_defaultMinXMargin;
	}
	
	/**
	 * Sets the default minimum X margin to <code>aMargin</code>.
	 */
	public function setDefaultMinXMargin(aMargin:Number):Void
	{
		m_defaultMinXMargin = aMargin;
	}
	
	/**
	 * Returns the number of views held by this HBox.
	 */
	public function numberOfViews():Number
	{
		if (m_hasViews)
			return m_numCols;
		else
			return 0;
	}
	
	//******************************************************															 
	//*                  Adding Views
	//******************************************************
	
	/**
	 * Adds <code>aView</code> to the right of the last view added with the 
	 * default minimum x margin and the resize flag set to true.
	 */
	public function addView(aView:NSView):Void
	{
		addViewEnableXResizingWithMinXMargin(aView, true, m_defaultMinXMargin);
	}

	/**
	 * Adds <code>aView</code> to the right of the last view added with the 
	 * default minimum x margin and the resize flag set to <code>flag</code>.
	 */	
	public function addViewEnableXResizing(aView:NSView, flag:Boolean):Void
	{
		addViewEnableXResizingWithMinXMargin(aView, flag, m_defaultMinXMargin);		
	}
	
	/**
	 * Adds <code>aView</code> to the right of the last view added with a 
	 * minimum x margin of <code>aMargin</code> and the resize flag set to true.
	 */
	public function addViewWithMinXMargin(aView:NSView, aMargin:Number):Void
	{
		addViewEnableXResizingWithMinXMargin(aView, true, aMargin);		
	}
	
	/**
	 * Adds <code>aView</code> to the right of the last view added with a 
	 * minimum x margin of <code>aMargin</code> and the resize flag set to
	 * <code>flag</code>.
	 */
	public function addViewEnableXResizingWithMinXMargin(aView:NSView, 
		flag:Boolean, aMargin:Number):Void
	{	
		if (m_hasViews)
		{	
			var entries:Number = m_numCols;
			
			super.addColumn();
			super.setXResizingEnabledForColumn(flag, entries);
			
			super.putViewAtRowColumnWithMinXMarginMaxXMarginMinYMarginMaxYMargin
				(aView, 0, entries,	aMargin, 0, 0, 0);
		}
		else // !m_hasViews
		{
			super.setXResizingEnabledForColumn(flag, 0);
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
		addSeparatorWithMinXMargin(m_defaultMinXMargin);
	}
	
	/**
	 * Adds a separator with a min x margin of <code>aMargin</code>.
	 */
	public function addSeparatorWithMinXMargin(aMargin:Number):Void
	{
		var sep:NSView = getSeparator(aMargin);
		addViewEnableXResizingWithMinXMargin(sep, false, aMargin);
	}
	
	/**
	 * Gets a separator for use inside this HBox.
	 * 
	 * This method can be overridden to create something more interesting.
	 */
	public function getSeparator(aMargin:Number):NSView
	{
		var sep:NSBox = (new NSBox()).initWithFrame(new NSRect(0, 0, 2, 2));
		sep.setAutoresizingMask(NSView.MinXMargin | NSView.MaxXMargin
			| NSView.HeightSizable);
		sep.setTitlePosition(NSTitlePosition.NSNoTitle);
		sep.setBorderType(NSBorderType.NSGrooveBorder);
		return sep;
	}
}