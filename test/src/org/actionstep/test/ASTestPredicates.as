/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSPredicate;
import org.actionstep.NSRange;
import org.actionstep.NSSet;
import org.actionstep.test.ASRandomObjectGenerator;
import org.actionstep.test.predicates.Person;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestPredicates {
	public static function test():Void {
		NSApplication.sharedApplication().run();
				
		var people:NSArray = generatePeopleArray();
		
		//
		// Drivers over 60
		//	
		var pred:NSPredicate = NSPredicate.predicateWithFormat(
			"canDrive == TRUE && age > 60");
		trace("Drivers over 60");
		trace(people.filteredArrayUsingPredicate(pred));
		
		//
		// Young men
		//
		pred = NSPredicate.predicateWithFormat(
			"age >= 18 && age <= 25 && sex == \"" + Person.SEX_MALE + "\"");
		trace("Young men");
		trace(people.filteredArrayUsingPredicate(pred));

		//
		// Passing averages
		//
		pred = NSPredicate.predicateWithFormat("average(marks) >= 50");
		trace("Passing Averages");
		trace(people.filteredArrayUsingPredicate(pred));
		
		//
		// At least one failing grade
		//
		pred = NSPredicate.predicateWithFormat("ANY marks < 50");
		trace("At least one failing grade");
		trace(people.filteredArrayUsingPredicate(pred));
		
		//
		// Honour roll
		//
		pred = NSPredicate.predicateWithFormat("ALL marks >= 80");
		trace("Honour roll");
		trace(people.filteredArrayUsingPredicate(pred));
		
		//
		// Names containing an A (case insensitive)
		//
		pred = NSPredicate.predicateWithFormat("firstName CONTAINS[c] \"a\"");
		trace("First names containing the letter a");
		trace(people.filteredArrayUsingPredicate(pred));
		
		//
		// Names containing an Å (case insensitive, diacitric insensitive)
		//
		pred = NSPredicate.predicateWithFormat("firstName CONTAINS[cd] \"Å\"");
		trace("First names containing the letter Å (diacitric insensitive)");
		trace(people.filteredArrayUsingPredicate(pred));
	}
	
	public static function generatePeopleArray():NSArray {
		var rog:ASRandomObjectGenerator = new ASRandomObjectGenerator();
		rog.setClass(Person);
		rog.addStringMemberWithLengthRange("firstName", new NSRange(4, 8));
		rog.addStringMemberWithLengthRange("lastName", new NSRange(4, 8));
		rog.addNumberMemberWithRange("age", new NSRange(10, 60));
		rog.addSetElementMemberWithSet("sex", NSSet.setWithArray(
			[Person.SEX_MALE, Person.SEX_FEMALE]));
		rog.addBooleanMember("canDrive");
		rog.addNumberArrayMemberWithLengthRangeUseArray("marks",
			new NSRange(2, 0), new NSRange(20, 81), false);
		
		return rog.generateInstanceArray(50);
	}
}