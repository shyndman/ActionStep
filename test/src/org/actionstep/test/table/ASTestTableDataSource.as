/* See LICENSE for copyright and terms of use */

import org.actionstep.binding.NSKeyValueCoding;
import org.actionstep.constants.NSDragOperation;
import org.actionstep.constants.NSTableViewDropOperation;
import org.actionstep.NSArray;
import org.actionstep.NSDraggingInfo;
import org.actionstep.NSIndexSet;
import org.actionstep.NSObject;
import org.actionstep.NSPasteboard;
import org.actionstep.NSRange;
import org.actionstep.NSSet;
import org.actionstep.NSTableColumn;
import org.actionstep.NSTableDataSource;
import org.actionstep.NSTableView;
import org.actionstep.test.ASRandomObjectGenerator;
import org.actionstep.test.predicates.Person;
import org.actionstep.ASDebugger;
import org.actionstep.NSImage;
import org.actionstep.themes.ASThemeImageNames;

/**
 * A test data source for the table tests.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.test.table.ASTestTableDataSource extends NSObject 
		implements NSTableDataSource {
	private var m_internalData:NSArray;
	
	/**
	 * Creates a new instance of the <code>ASTestTableDataSource</code> class.
	 */
	public function ASTestTableDataSource() {
	}
	
	/**
	 * Initializes the data source.
	 */
	public function initWithCount(num:Number):ASTestTableDataSource {
		var gen:ASRandomObjectGenerator = new ASRandomObjectGenerator();
		gen.setClass(Person);
		gen.addStringMemberWithLengthRange("firstName", new NSRange(4, 8));
		gen.addStringMemberWithLengthRange("lastName", new NSRange(4, 8));
		gen.addNumberMemberWithRange("age", new NSRange(10, 60));
		gen.addSetElementMemberWithSet("sex", NSSet.setWithArray(
			[Person.SEX_MALE, Person.SEX_FEMALE]));
		gen.addBooleanMember("canDrive");
		
		m_internalData = gen.generateInstanceArray(num);
				
		return this;
	}
	
	/**
	 * Returns the number of objects represented by this data source.
	 */
	public function numberOfRowsInTableView(aTableView:NSTableView):Number {
		return m_internalData.count();
	}

	/**
	 * Returns the object value for a row and table column.
	 */
	public function tableViewObjectValueForTableColumnRow(
			aTableView:NSTableView, 
			aTableColumn:NSTableColumn, 
			rowIndex:Number):Object {
		var obj:Object = m_internalData.objectAtIndex(rowIndex);
		var key:String = keyForTableColumn(aTableColumn);
		var ret:Object = NSKeyValueCoding.valueWithObjectForKeyPath(obj, key);
				
		return ret;
	}

	public function tableViewObjectValuesForTableColumnRange(
			aTableView:NSTableView, 
			aTableColumn:NSTableColumn, 
			range:NSRange):NSArray {
		if (aTableColumn.identifier() == null) {
			return null;
		}
				
		var rows:NSArray = m_internalData.subarrayWithRange(range);
		
		var key:String = keyForTableColumn(aTableColumn);
		var ret:NSArray = NSArray(NSKeyValueCoding.valueWithObjectForKeyPath(rows, 
			"@unionOfObjects." + key));	
		if (key == "sex") {
			var arr:Array = ret.internalList();
			var len:Number = arr.length;
			for (var i:Number = 0; i < len; i++) {
				var sex:String = arr[i];
				var img:NSImage;
				if (sex == Person.SEX_MALE) {
					img = NSImage.imageNamed(ASThemeImageNames.NSSmallRadioButtonImage);
				} else {
					img = NSImage.imageNamed(ASThemeImageNames.NSMiniHighlightedSwitchImage);
				}
				
				ret.replaceObjectAtIndexWithObject(
					i, img);
			}
		}
			
		return ret;	
	}
	
	/**
	 * Sets the object value for a row and table column.
	 */
	public function tableViewSetObjectValueForTableColumnRow(
			aTableView:NSTableView, 
			anObject:Object, 
			aTableColumn:NSTableColumn, 
			rowIndex:Number):Void {
		var obj:Object = m_internalData.objectAtIndex(rowIndex);
		NSKeyValueCoding.setValueWithObjectForKeyPath(obj, anObject,
			keyForTableColumn(aTableColumn));
			
		if (aTableColumn.identifier() == "age") {
			aTableView.reloadData();
		}
	}
	
	/**
	 * Always returns <code>true</code>.
	 */
	public function tableViewAcceptDropRowDropOperation(
			aTableView:NSTableView, 
			info:NSDraggingInfo, row:Number, 
			operation:NSTableViewDropOperation):Boolean {
		return true;
	}

	public function tableViewSortDescriptorsDidChange(aTableView:NSTableView, 
			oldDescriptors:NSArray):Void {
		m_internalData.sortUsingDescriptors(aTableView.sortDescriptors());
		aTableView.reloadData();
	}

	public function tableViewValidateDropProposedRowProposedDropOperation(
		aTableView:NSTableView, validateDrop:NSDraggingInfo, row:Number, 
		operation:NSTableViewDropOperation):NSDragOperation {
		return null;
	}

	public function tableViewWriteRowsWithIndexesToPasteboard(
			aTableView:NSTableView, rowIndexes:NSIndexSet, 
			pboard:NSPasteboard):Boolean {
		return null;
	}
	
	//******************************************************
	//*                   Helper methods
	//******************************************************
	
	/**
	 * Returns the property name for <code>aTableColumn</code>.
	 */
	private function keyForTableColumn(aTableColumn:NSTableColumn):String {
		return aTableColumn.identifier().toString();
	}
}