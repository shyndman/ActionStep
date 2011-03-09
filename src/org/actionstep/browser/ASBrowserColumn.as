/* See LICENSE for copyright and terms of use */

import org.actionstep.NSMatrix;
import org.actionstep.NSObject;
import org.actionstep.NSScrollView;

/**
 * <p>Represents a column in the browser.</p>
 * 
 * <p>For internal use.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.browser.ASBrowserColumn extends NSObject {
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private var m_isLoaded:Boolean;
	private var m_scrollView:NSScrollView;
	private var m_matrix:NSMatrix;
	private var m_title:String;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASBrowserColumn</code> class.
	 */
	public function ASBrowserColumn() {
		m_isLoaded = false;
	}
	
	/**
	 * Initializes and returns the browser column.
	 */
	public function init():ASBrowserColumn {
		super.init();
		return this;
	}
	
	/**
	 * Releases the object from memory.
	 */
	public function release():Void {
		m_matrix = null;
		m_scrollView = null;
	}
	
	//******************************************************
	//*                  Attributes
	//******************************************************
	
	/**
	 * Returns <code>true</code> if the column is loaded.
	 */
	public function isLoaded():Boolean {
		return m_isLoaded;
	}
	
	/**
	 * Sets whether the column is loaded to <code>flag</code>.
	 */
	public function setLoaded(flag:Boolean):Void {
		m_isLoaded = flag;
	}
	
	/**
	 * Returns this column's scroll view.
	 */
	public function scrollView():NSScrollView {
		return m_scrollView;
	}
	
	/**
	 * Sets the scroll view to <code>scrollView</code>.
	 */
	public function setScrollView(scrollView:NSScrollView):Void {
		m_scrollView = scrollView;
	}
	
	/**
	 * Returns this column's matrix.
	 */
	public function matrix():NSMatrix {
		return m_matrix;
	}
	
	/**
	 * Sets this column's matrix to <code>matrix</code>.
	 */
	public function setMatrix(matrix:NSMatrix):Void {
		m_matrix = matrix;
	}
	
	/**
	 * Returns this column's title.
	 */
	public function title():String {
		return m_title;
	}
	
	/**
	 * Sets this column's title to <code>title</code>.
	 */
	public function setTitle(title:String):Void {
		m_title = title;
	}
}