/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSObject;
import org.actionstep.NSImage;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.predicates.Person extends NSObject {
	public static var SEX_MALE:String = "Male";
	public static var SEX_FEMALE:String = "Female";
	
	public var firstName:String;
	public var lastName:String;
	public var age:Number;
	public var sex:String;
	public var canDrive:Boolean;
	public var marks:NSArray;
	public var friends:NSArray;
	
	/**
	 * Returns a string representation of the Person instance.
	 */
	public function description():String {
		return "Person(\n" 
			+ "firstName=" + firstName + ", \n"
			+ "lastName=" + lastName + ", \n"
			+ "age=" + age + ", \n"
			+ "sex=" + sex + ", \n"
			+ "canDrive=" + canDrive + ", \n"
			+ "marks=" + marks + ", \n" 
			+ "friends=" + friends + ")";
	}
	
	/**
	 * Returns the image representing this person's gender.
	 */
	public function genderImage():NSImage {
		return NSImage.imageNamed(sex + "Image");
	}
}