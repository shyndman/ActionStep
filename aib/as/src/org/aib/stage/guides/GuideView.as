/* See LICENSE for copyright and terms of use */

import org.actionstep.NSView;
import org.aib.stage.guides.GuideInfo;
import org.aib.controls.EditableWindow;

/**
 * Used to display a {@link GuideInfo} object in an AIB window.
 * 
 * @author Scott Hyndman
 */
class org.aib.stage.guides.GuideView extends NSView {
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_info:GuideInfo;
	private var m_window:EditableWindow;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>GuideView</code> class.
	 */
	public function GuideView() {
	}
	
	/**
	 * Initializes the guide view with a window and guide info.
	 */
	public function initWithWindowGuideInfo(window:EditableWindow, 
			info:GuideInfo):GuideView {
		m_info = info;
		m_window = window;
		return this;		
	}
}