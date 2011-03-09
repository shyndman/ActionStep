/* See LICENSE for copyright and terms of use */

import org.actionstep.NSCell;
import org.actionstep.NSView;
import org.actionstep.NSFont;
import org.actionstep.NSImage;
import org.actionstep.NSRect;
import org.actionstep.NSControl;

import org.actionstep.constants.NSTextAlignment;

/**
 * Base class for cells that dispatch action messages to targets in response
 * to user input.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.NSActionCell extends NSCell {
  
  private static var g_controlClass:Function = org.actionstep.NSControl;

  private var m_action:String;
  private var m_target:Object;
  private var m_tag:Number;
  
  //******************************************************
  //*                Copying a cell
  //******************************************************
  
  public function copyWithZone():NSActionCell {
    var ret:NSActionCell = NSActionCell(super.copyWithZone());
    ret.m_action = m_action;
    ret.m_target = m_target;
    ret.m_tag = m_tag;
    return ret;
  }
  
  //******************************************************															 
  //*           Configuring an NSActionCell
  //******************************************************
  
  public function setAlignment(alignment:NSTextAlignment) {
    super.setAlignment(alignment);
    if (m_controlView != null) {
      if (m_controlView instanceof g_controlClass) {
        NSControl(m_controlView).updateCell(this);
      }
    }
  }
  
  public function setBezeled(value:Boolean) {
    m_bezeled = value;
    if (m_bezeled) {
      m_bordered = false;
    }
    if (m_controlView != null) {
      if (m_controlView instanceof g_controlClass) {
        NSControl(m_controlView).updateCell(this);
      }
    }
  }

  public function setBordered(value:Boolean) {
    m_bordered = value;
    if (m_bordered) {
      m_bezeled = false;
    }
    if (m_controlView != null) {
      if (m_controlView instanceof g_controlClass) {
        NSControl(m_controlView).updateCell(this);
      }
    }
  }
  
  public function setEnabled(value:Boolean) {
    m_enabled = value;
    if (m_controlView != null) {
      if (m_controlView instanceof g_controlClass) {
        NSControl(m_controlView).updateCell(this);
      }
    }
  }

  public function setFont(font:NSFont) {
    super.setFont(font);
    if (m_controlView != null) {
      if (m_controlView instanceof g_controlClass) {
        NSControl(m_controlView).updateCell(this);
      }
    }
  }

  public function setImage(image:NSImage) {
    super.setImage(image);
    if (m_controlView != null) {
      if (m_controlView instanceof g_controlClass) {
        NSControl(m_controlView).updateCell(this);
      }
    }
  }
  
  //******************************************************															 
  //*         Obtaining and setting cell values
  //******************************************************
  
  public function doubleValue():Number {
    var ctrl:NSView = controlView();
    if (ctrl != null) {
      if (ctrl instanceof g_controlClass
          && NSControl(ctrl).currentEditor() != null) {
        NSControl(ctrl).validateEditing();
      }
    }
    return super.doubleValue();
  }

  public function floatValue():Number {
    var ctrl:NSView = controlView();
    if (ctrl != null) {
      if (ctrl instanceof g_controlClass
          && NSControl(ctrl).currentEditor() != null) {
        NSControl(ctrl).validateEditing();
      }
    }
    return super.floatValue();
  }

  public function intValue():Number {
    var ctrl:NSView = controlView();
    if (ctrl != null) {
      if (ctrl instanceof g_controlClass
          && NSControl(ctrl).currentEditor() != null) {
        NSControl(ctrl).validateEditing();
      }
    }
    return super.intValue();
  }

  public function stringValue():String {
    var ctrl:NSView = controlView();
    if (ctrl != null) {
      if (ctrl instanceof g_controlClass
          && NSControl(ctrl).currentEditor() != null) {
        NSControl(ctrl).validateEditing();
      }
    }
    return super.stringValue();
  }

  public function setObjectValue(value:Object) {
    super.setObjectValue(value);
    if (m_controlView != null) {
      var cls:Function = getClass().g_controlClass;
      if (cls == null) {
        cls = g_controlClass;
      }
      if (m_controlView instanceof cls) {
        NSControl(m_controlView).updateCell(this);
      }
    }
  }

  //******************************************************															 
  //*            Displaying the NSActionCell
  //******************************************************
  
  public function drawWithFrameInView(cellFrame:NSRect, inView:NSView) {
    if (m_controlView != inView) {
      m_controlView = inView;
    }
    super.drawWithFrameInView(cellFrame, inView);
  }

  //******************************************************															 
  //*            Assigning target and action
  //******************************************************
  
  public function setAction(value:String) {
    m_action = value;
  }
  
  public function action():String {
    return m_action;
  }
  
  public function setTarget(value:Object) {
    m_target = value;
  }
  
  public function target():Object {
    return m_target;
  }
  
  //******************************************************															 
  //*                Assigning a tag
  //******************************************************
  
  public function setTag(value:Number) {
    m_tag = value;
  }
  
  public function tag():Number {
    return m_tag;
  }
  
  
}