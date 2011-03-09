/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.NSArray;
import org.actionstep.NSObject;
import org.actionstep.NSRange;
import org.actionstep.NSSet;

/**
 * Generates instances of a class when provided with specifics about members.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.test.ASRandomObjectGenerator extends NSObject {
	
	//******************************************************
	//*                     Constants
	//******************************************************
	
	private static var TYPE_STRING:Number = 1;
	private static var TYPE_NUMBER:Number = 2;
	private static var TYPE_DATE:Number = 3;
	private static var TYPE_BOOL:Number = 4;
	private static var TYPE_SET_ELEMENT:Number = 5;
	private static var TYPE_NUMBER_ARRAY:Number = 6;
	private static var TYPE_OBJECT_ARRAY:Number = 7;
	private static var TYPE_CONSTANT:Number = 8;
	
	//******************************************************
	//*                      Members
	//******************************************************
	
	private var m_class:Function;
	private var m_members:Object;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASRandomObjectGenerator</code> class.
	 */
	public function ASRandomObjectGenerator() {
		m_class = Object;
		m_members = {};
	}
	
	//******************************************************
	//*                Setting the class
	//******************************************************
	
	/**
	 * Sets the class of the instances that will be generated to 
	 * <code>cls</code>.
	 * 
	 * The default class is <code>Object</code>.
	 */
	public function setClass(cls:Function):Void {
		m_class = cls;
	}
	
	//******************************************************
	//*              Adding member variables
	//******************************************************
	
	/**
	 * Adds a string member named <code>name</code> with a length of 
	 * <code>length</code>.
	 */
	public function addStringMemberWithLengthRange(name:String, range:NSRange):Void {
		m_members[name] = {type: TYPE_STRING, range: range};
	}
	
	/**
	 * Adds a number member named <code>name</code> with a range of 
	 * <code>range</code>.
	 */
	public function addNumberMemberWithRange(name:String, range:NSRange):Void {
		m_members[name] = {type: TYPE_NUMBER, range: range};
	}
	
	/**
	 * Adds a boolean member named <code>name</code>.
	 */
	public function addBooleanMember(name:String):Void {
		m_members[name] = {type: TYPE_BOOL};
	}
	
	/**
	 * Adds a member named <code>name</code> who's value will be randomly
	 * selected from the values contained in <code>elements</code>. 
	 */
	public function addSetElementMemberWithSet(name:String, elements:NSSet):Void {
		m_members[name] = {type: TYPE_SET_ELEMENT, elements: elements};
	}
	
	/**
	 * Adds a member named <code>name</code> who's value will be an array of
	 * randomly generated numbers constrained by <code>range</code>. The array
	 * will contain a number of elements constrained by <code>length</code>.
	 * 
	 * If <code>useArray</code> is <code>true</code>, the native 
	 * <code>Array</code> class will be used. If <code>false</code>, an
	 * <code>NSArray</code> will be generated. 
	 */
	public function addNumberArrayMemberWithLengthRangeUseArray(name:String, 
			length:NSRange, range:NSRange, useArray:Boolean):Void {
		m_members[name] = {
			type: TYPE_NUMBER_ARRAY, 
			length: length,
			range: range, 
			useArray: useArray};
	}

	/**
	 * Adds a member named <code>name</code> who's value will be an array of
	 * randomly generated objects as created by the random object generator
	 * <code>generator</code>. The array will contain a number of elements
	 * as constrained by <code>length</code>.
	 * 
	 * If <code>useArray</code> is <code>true</code>, the native 
	 * <code>Array</code> class will be used. If <code>false</code>, an
	 * <code>NSArray</code> will be generated. 
	 */
	public function addObjectArrayMemberWithLengthGeneratorUseArray(name:String,
			length:NSRange, generator:ASRandomObjectGenerator, useArray:Boolean)
			:Void {
		m_members[name] = {
			type: TYPE_OBJECT_ARRAY, 
			length: length, 
			generator: generator, 
			useArray: useArray};
	}
	
	/**
	 * Adds a constant member named <code>name</code>. The value of this member
	 * will always be <code>val</code>.
	 */
	public function addConstantMemberWithValue(name:String, val:Object):Void {
		m_members[name] = {
			type: TYPE_CONSTANT,
			constant: val};
	}
	
	//******************************************************
	//*               Generating instances
	//******************************************************
	
	/**
	 * Generates an array of instances based on the members added to the 
	 * generator.
	 * 
	 * The number of instances generated is <code>length</code>.
	 */
	public function generateInstanceArray(length:Number):NSArray {
		var arr:NSArray = NSArray.array();
		
		for (var i:Number = 0; i < length; i++) {
			arr.addObject(generateInstance());
		}
		
		return arr;
	}
	
	/**
	 * Generates an instance of the class based on the members added to the
	 * generator.
	 */
	public function generateInstance():Object {
		var obj:Object = ASUtils.createInstanceOf(m_class);
		
		for (var member:String in m_members) {
			obj[member] = generateMemberValue(m_members[member]);
		}
		
		return obj;
	}
	
	/**
	 * Creates a member value based on the member descriptor.
	 */
	private function generateMemberValue(info:Object):Object {
		var obj:Object;
		
		switch (info.type) {
			case TYPE_NUMBER:
				var rng:NSRange = info.range;
				obj = random(rng.length) + rng.location;
				break;
				
			case TYPE_STRING:
				var rng:NSRange = info.range;
				var len:Number = random(rng.length) + rng.location;
				obj = "";
				
				for (var i:Number = 0; i < len; i++) {
					var c:String = String.fromCharCode(random(26) + 65);
					obj += random(2) == 1 ? c : c.toLowerCase();
				}
				
				break;
				
			case TYPE_DATE:
				var start:Number = info.start.getTime();
				var end:Number = info.end.getTime();
				
				obj = new Date(random(end - start) + start);
				break;
				
			case TYPE_BOOL:
				obj = random(2) == 1 ? true : false;
				break;
				
			case TYPE_SET_ELEMENT:
				obj = NSSet(info.elements).anyObject();
				break;
				
			case TYPE_NUMBER_ARRAY:
				var lenrng:NSRange = NSRange(info.length); 
				var len:Number = random(lenrng.length) + lenrng.location;
				var rng:NSRange = info.range;
				var arr:Array = [];
				
				for (var i:Number = 0; i < len; i++) {
					arr.push(random(rng.length) + rng.location);
				}
				
				if (!info.useArray) {
					obj = NSArray.arrayWithArray(arr);
				} else {
					obj = arr;
				}
				
				break;
				
			case TYPE_OBJECT_ARRAY:
				var lenrng:NSRange = NSRange(info.length); 
				var len:Number = random(lenrng.length) + lenrng.location;
				var gen:ASRandomObjectGenerator = info.generator;
				var arr:NSArray = gen.generateInstanceArray(len);;
								
				if (!info.useArray) {
					obj = arr.internalList();
				} else {
					obj = arr;
				}
				
				break;
				
			case TYPE_CONSTANT:
				obj = info.constant;
				break;
		}
		
		return obj;
	}

}