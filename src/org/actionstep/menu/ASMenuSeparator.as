/* See LICENSE for copyright and terms of use */  

import org.actionstep.NSMenuItem;

/**
 * <p>An <code>NSMenuItem</code> subclass representing a separator.</p>
 * 
 * <p>Used by <code>org.actionstep.NSMenu</code> and its related classes.</p>
 * 
 * @author Tay Ray Chuan.
 */
class org.actionstep.menu.ASMenuSeparator extends NSMenuItem {
	public function init():NSMenuItem {
	  super.initWithTitleActionKeyEquivalent("-----------", null, "");
	  m_enabled = false;
	  m_changesState = false;
	  m_isSeparator = true;
	  return this;
	}
}