import org.actionstep.NSArray;
import org.actionstep.NSImage;
import org.actionstep.NSNotification;
import org.actionstep.NSToolbar;
import org.actionstep.NSToolbarItem;
import org.actionstep.toolbar.ASToolbarDelegate;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.toolbar.ASToolbarTestDelegate implements ASToolbarDelegate {
	
	public function toolbarWillAddItem(notification:NSNotification):Void {
		
	}

	public function toolbarDidRemoveItem(notification:NSNotification):Void {
		
	}

	public function toolbarItemForItemIdentifierWillBeInsertedIntoToolbar(
			toolbar:NSToolbar, itemIdentifier:String, flag:Boolean):NSToolbarItem {
		var item:NSToolbarItem = (new NSToolbarItem()).initWithItemIdentifier(itemIdentifier);
		
		switch (itemIdentifier) {
			case "CrayonsItem":
			item.setImage((new NSImage()).initWithContentsOfURL("test/picker_crayons.png"));
			item.setLabel("Crayons");
			item.setToolTip("Crayons");
			item.setVisibilityPriority(140);
			item.setTarget(this);
			item.setAction("itemPressed");
			break;
		
			case "SlidersItem":
			item.setImage((new NSImage()).initWithContentsOfURL("test/picker_sliders.png"));
			item.setLabel("Color Sliders");
			item.setToolTip("Color Sliders");
			item.setVisibilityPriority(180);
			item.setTarget(this);
			item.setAction("itemPressed");
			break;
			
			case "WheelItem":
			item.setImage((new NSImage()).initWithContentsOfURL("test/picker_wheel.png"));
			item.setLabel("Color Wheel");
			item.setToolTip("Color Wheel");
			item.setVisibilityPriority(200);
			item.setTarget(this);
			item.setAction("itemPressed");
			break;
			
			case "ListsItem":
			item.setImage((new NSImage()).initWithContentsOfURL("test/picker_lists.png"));
			item.setLabel("Color Palettes");
			item.setToolTip("Color Palettes");
			item.setVisibilityPriority(160);
			item.setTarget(this);
			item.setAction("itemPressed");
			break;
		}
		
		return item;
	}

	public function toolbarDefaultItemIdentifiers(toolbar:NSToolbar):NSArray {
		return NSArray.arrayWithArray([
			"WheelItem",
			"SlidersItem",
			"ListsItem",
			"CrayonsItem",
			NSToolbarItem.NSToolbarFlexibleSpaceItemIdentifier
			]);
	}

	public function toolbarSelectableItemIdentifiers(toolbar:NSToolbar):NSArray {
		return NSArray.arrayWithArray([
			"CrayonsItem", 
			"SlidersItem", 
			"ListsItem",
			"WheelItem"]);
	}

	public function itemPressed(item:NSToolbarItem):Void {
		trace(item.label());
	}
}