/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSRange;
import org.actionstep.NSSet;
import org.actionstep.test.ASRandomObjectGenerator;
import org.actionstep.test.predicates.Person;

/**
 * Tests Key-Value coding
 * 
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestKVC {
	public static function test():Void {
		//
		// Start the app (just so the debugger works)
		//
		NSApplication.sharedApplication().run();
		
		//
		// Create a random object generator for "friend" objects.
		//		
		var child:ASRandomObjectGenerator = new ASRandomObjectGenerator();
		child.setClass(Person);
		child.addStringMemberWithLengthRange("firstName", new NSRange(4, 8));
		child.addStringMemberWithLengthRange("lastName", new NSRange(4, 8));
		child.addNumberMemberWithRange("age", new NSRange(10, 60));
		child.addSetElementMemberWithSet("sex", NSSet.setWithArray(
			[Person.SEX_MALE, Person.SEX_FEMALE]));
		child.addBooleanMember("canDrive");
		child.addNumberArrayMemberWithLengthRangeUseArray("marks",
			new NSRange(2, 0), new NSRange(20, 81), false);
			
		//
		// Create a random object generator for the parent Person object, which
		// will contain friends
		//
		var parent:ASRandomObjectGenerator = new ASRandomObjectGenerator();
		parent.setClass(Person);
		parent.addStringMemberWithLengthRange("firstName", new NSRange(4, 8));
		parent.addStringMemberWithLengthRange("lastName", new NSRange(4, 8));
		parent.addNumberMemberWithRange("age", new NSRange(10, 60));
		parent.addSetElementMemberWithSet("sex", NSSet.setWithArray(
			[Person.SEX_MALE, Person.SEX_FEMALE]));
		parent.addBooleanMember("canDrive");
		parent.addNumberArrayMemberWithLengthRangeUseArray("marks",
			new NSRange(2, 0), new NSRange(20, 81), false);
		parent.addObjectArrayMemberWithLengthGeneratorUseArray("friends",
			new NSRange(5, 0), child, false);
			
		//
		// Generate a single parent object
		//
		var person:Person = Person(parent.generateInstance());
		
		//
		// Test array indexers
		//
		trace(person.valueForKeyPath("friends[FIRST].sex")); // first
		trace(person.valueForKeyPath("friends[LAST].sex")); // last
		trace(person.valueForKeyPath("friends[SIZE]")); // count
		trace(person.valueForKeyPath("friends[4].sex")); // 4th friend's sex
		trace(person.valueForKeyPath("friends[400].sex")); // should be null
		trace(person.valueForKeyPath("friends.sex")); // all the friend's sexes
		trace(person.valueForKeyPath("friends.@unionOfObjects.sex")); // should be the same as above
	}
}