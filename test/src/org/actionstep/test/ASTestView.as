/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.NSDragOperation;
import org.actionstep.NSColor;
import org.actionstep.NSDraggingSource;
import org.actionstep.NSEvent;
import org.actionstep.NSImage;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.themes.ASThemeImageNames;

/**
 * This class, despite its name, does not test the <code>NSView</code> class.
 * 
 * It is used by other tests to create a view with properties the test uses.
 * 
 * @author Scott Hyndman
 * @author Richard Kilmer
 */
class org.actionstep.test.ASTestView extends NSView implements NSDraggingSource {
	
  private var m_backgroundColor:NSColor;
  private var m_borderColor:NSColor;
  private var m_headerView:ASTestView;
  private var m_cornerView:ASTestView;
  private var m_dndEnabled:Boolean;
  
  public function ASTestView() {
    m_backgroundColor = new NSColor(0xBEC3C9);
    m_dndEnabled = false;
  }
  
  public function setDndEnabled(value:Boolean):Void {
    m_dndEnabled = value;
  }
  
  public function setBackgroundColor(color:NSColor) {
    m_backgroundColor = color;
  }
  
  public function backgroundColor():NSColor {
    return m_backgroundColor;
  }
  
  public function setBorderColor(color:NSColor) {
    m_borderColor = color;
  }
  
  public function borderColor():NSColor {
    return m_borderColor;
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
	
  public function acceptsFirstResponder():Boolean {
    return true;
  }
  
  public function addHeaderView():Void {
    m_headerView = ASTestView(
    	(new ASTestView()).initWithFrame(new NSRect(0, 0, 40, 30)));
    m_headerView.setBackgroundColor(new NSColor(0x990000));
  }
  
  public function headerView():NSView {
    return m_headerView;
  }
  
  public function addCornerView():Void {
    m_cornerView = ASTestView(
    	(new ASTestView()).initWithFrame(new NSRect(0, 0, 40, 20)));
    m_cornerView.setBackgroundColor(new NSColor(0x009933));
  }
  
  public function cornerView():NSView {
    return m_cornerView;
  }
  
  public function drawRect(rect:NSRect) {
    with(m_mcBounds) {
      clear();
      if (m_borderColor != null) {
        lineStyle(1, m_borderColor.value, 100);
      } else {
        lineStyle(1, m_backgroundColor.value, 100);
      }
      beginFill(m_backgroundColor.value, 100);
      moveTo(0,0);
      lineTo(rect.size.width-1, 0);
      lineTo(rect.size.width-1, rect.size.height-1);
      lineTo(0, rect.size.height-1);
      lineTo(0, 0);
      endFill();
    }
    
  }
}
  