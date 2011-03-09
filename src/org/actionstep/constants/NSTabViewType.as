/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * These constants specify an <code>NSTabView</code>'s type.
 */
class org.actionstep.constants.NSTabViewType extends ASConstantValue {
  
  /**
   * The view includes tabs on the top of the view and has a bezeled border 
   * (the default).
   */
  static var NSTopTabsBezelBorder:NSTabViewType = new NSTabViewType(0);
  
  /**
   * Tabs are on the left of the view with a bezeled border.
   */
  static var NSLeftTabsBezelBorder:NSTabViewType = new NSTabViewType(1);
  
  /**
   * Tabs are on the bottom of the view with a bezeled border.
   */
  static var NSBottomTabsBezelBorder:NSTabViewType = new NSTabViewType(2);
  
  /**
   * Tabs are on the right of the view with a bezeled border.
   */
  static var NSRightTabsBezelBorder:NSTabViewType = new NSTabViewType(3);
  
  /**
   * The view does not include tabs and has a bezeled border.
   */
  static var NSNoTabsBezelBorder:NSTabViewType = new NSTabViewType(4);
  
  /**
   * The view does not include tabs and has a lined border.
   */
  static var NSNoTabsLineBorder:NSTabViewType = new NSTabViewType(5);
  
  /**
   * The view does not include tabs and has no border.
   */
  static var NSNoTabsNoBorder:NSTabViewType = new NSTabViewType(6);
  
  
  /**
   * Creates a new instance of <code>NSTabViewType</code>.
   * 
   * For internal use only.
   */
  private function NSTabViewType(num:Number) {
    super(num);
  }

}
