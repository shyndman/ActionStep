/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
//import org.actionstep.NSException;
import org.actionstep.NSSet;
import org.actionstep.NSSize;
import org.actionstep.NSDate;

/**
 * A collection of utilities used by ActionStep.
 *
 * @author Tay Ray Chuan
 * @author Richard Kilmer
 * @author Scott Hyndman
 */
class org.actionstep.ASUtils {
  private static var g_internedObject:Object = new Object();
  private static var g_internedIndex:Number = 0;
  private static var g_classes:NSArray;
  /**
   * Mappings between diacritic characters and their standard counterparts.
   */
  private static var g_letterMappings:NSDictionary;

  /**
   * Turns the String <code>string</code> into a number.
   *
   * This is used extensively by notifications.
   */
  public static function intern(string:String):Number {
    var intern:Number = g_internedObject[string];
    if(intern == undefined) {
      intern = g_internedIndex++;
      g_internedObject[string] = intern;
    }
    return intern;
  }

  /**
   * Turns the Number <code>number</code> into the string that was used to
   * generate the number using <code>#intern()</code>.
   */
  public static function extern(number:Number):String {
    for(var x:Object in g_internedObject) {
      if (g_internedObject[x] == number) {
        return x;
      }
    }
    return null;
  }

  /**
   * Creates an instance of the supplied class.
   *
   * @author Simon Wacker (as2lib)
   */
  public static function createInstanceOf(klass:Function, args:Array):Object {
    if (!klass) {
      return null;
    }

    if (args == null) {
      args = [];
    }

    var result:Object = new Object();
    result.__proto__ = klass.prototype;
    result.__constructor__ = klass;
    klass.apply(result, args);
    return result;
  }


  /**
   * Strict type-checking of elements.
   * Might be slow, so use for debug.
   */
  public static function chkElem (list:Object, type:Function):Object {
    for(var i:Object in list) {
      if(!(list[i] instanceof type))  return {who: i};
    }
    return true;
  }

  /**
   * Multi-purpose function.
   * eg. ASUtils.findMatch([NSCell, NSControl], arguments.caller, "prototype");
   * eg. ASUtils.findMatch([NSApplication], result);
   */
  public static function findMatch (suspects:Array, caller:Object, ext:String):NSDictionary {
    var i:String, x:Object, j:String;
    var f:Boolean = false;  //flag
    var aspf:Function = _global.ASSetPropFlags;  //shortcut

    for(i in suspects) {
      x = suspects[i];
      if(ext!=null)  x=x[ext];
      aspf(x, null, 6, true);
      for(j in x) {
        if(x[j]==caller) {
          f=true;
          break;
        }
      }
      aspf(x, null, 7);
      if(f)  break;
    }

    try {
      if(!f) {
        return NSDictionary.dictionaryWithObjectsAndKeys
        (f, "found");
      } else {
        return NSDictionary.dictionaryWithObjectsAndKeys
        (f, "found", j, "prop", suspects[i].prototype.toString(), "obj", ext, "ext");
      }
    } catch (e:Error) {
      trace(e);
      throw e;
    }
  }

  /**
   * Returns <code>true</code> if <code>obj</code> is a string, or
   * <code>false</code> otherwise.
   */
  public static function isString(obj:Object):Boolean {
    return (typeof(obj) == "string") ? true : obj instanceof String;
  }

  /**
   * Returns <code>true</code> if <code>obj</code> is a boolean, or
   * <code>false</code> otherwise.
   */
  public static function isBoolean(obj:Object):Boolean {
    return (typeof(obj) == "boolean") ? true : obj instanceof Boolean;
  }

  /**
   * Returns <code>true</code> if <code>obj</code> is a number, or
   * <code>false</code> otherwise.
   */
  public static function isNumber(obj:Object):Boolean {
    return (typeof(obj) == "number") ? true : obj instanceof Number;
  }

  /**
   * Returns <code>true</code> if <code>obj</code> is a collection, or
   * <code>false</code> otherwise.
   *
   * A collection is an instance one of the following:
   *   - Array
   *   - NSSet
   *   - NSArray
   */
  public static function isCollection(obj:Object):Boolean {
    return obj instanceof Array
    	|| obj instanceof NSSet
    	|| obj instanceof NSArray;
  }

  /**
   * Returns <code>true</code> if <code>obj</code> is a date, or
   * <code>false</code> otherwise.
   *
   * A date is an instance one of the following:
   *   - Date
   *   - NSDate
   *   - NSCalendarDate
   */
  public static function isDate(obj:Object):Boolean {
    return obj instanceof Date
    	|| obj instanceof NSDate;
  }

  /**
   * Extracts and returns a date extracted from obj. If obj is a date, a copy
   * of obj is returned. If obj is an NSDate, the NSDate's internal date is
   * returned.
   */
  public static function extractNativeDate(obj:Object):Date {
    if (obj instanceof Date) {
      return new Date(obj.getTime());
    }
    else if (obj instanceof NSDate) {
      return NSDate(obj).internalDate();
    }

    return null;
  }

  /**
   * Extracts and returns the internal array from <code>collection</code>, or
   * <code>null</code> if the operation could not be performed.
   *
   * <code>collection</code> can be an instance of the following:
   * 	- <code>NSArray</code>
   * 	- <code>NSSet</code>
   * 	- <code>Array</code>
   *
   * If <code>collection</code> is already an array, it is returned as is.
   */
  public static function extractArrayFromCollection(collection:Object):Object {
    if (collection instanceof Array) {
      return collection;
    }
    else if (collection instanceof NSArray) {
    	return NSArray(collection).internalList();
    }
    else if (collection instanceof NSSet) {
    	return NSSet(collection).internalList();
    }

    return null;
  }

  /**
   * Returns the number of occurences of token in str.
   */
  public static function countIndicesOf(str:String, token:String):Number {
    return ASUtils.indicesOfString(str, token).length;
  }

  /**
   * Returns the indicies of one sting in another.
   */
  public static function indicesOfString(str:String, token:String):Array {
    var result:Array = new Array();
    var curpos:Number = 0;

    while (curpos != -1 && curpos < str.length) {
      curpos = str.indexOf(token, curpos);

      if (curpos != -1) {
        result.push(curpos);
        ++curpos;
      }
    }

    return result;
  }

  /**
   * Removes whitespace from the beginning and end of a string.
   */
  public static function trimString(str:String):String {
    var end:Number = str.length;
    var start:Number = 0;
    var white:Object = new Object();
    white["_"+" ".charCodeAt(0)] = 1;
    white["_"+"\n".charCodeAt(0)] = 1;
    white["_"+"\r".charCodeAt(0)] = 1;
    white["_"+"\t".charCodeAt(0)] = 1;
    while(white["_"+str.charCodeAt(--end)]);
    while(white["_"+str.charCodeAt(start++)]);
    return str.slice(start-1,end+1);
  }

  /**
   * Returns a <code>aString</code> modified so that all diacritic characters
   * have been resolved into the standard charset.
   */
  public static function dediacriticfyString(aString:String):String {
    if (g_letterMappings == null) {
      createDiacriticMapping();
    }

    //! TODO Experiment with arrays here
    var newString:String = "";
    var mapping:Object = g_letterMappings.internalDictionary();
    var len:Number = aString.length;
    for (var i:Number = 0; i < len; i++) {
      var c:String = aString.charAt(i);
      if (mapping[c] != null) {
        c = mapping[c];
      }
      newString += c;
    }

    return newString;
  }

  private static function createDiacriticMapping():Void {
    g_letterMappings = NSDictionary.dictionary();

    g_letterMappings.setObjectForKey("A", "À");
    g_letterMappings.setObjectForKey("A", "Á");
    g_letterMappings.setObjectForKey("A", "Â");
    g_letterMappings.setObjectForKey("A", "Ã");
    g_letterMappings.setObjectForKey("A", "Ä");
    g_letterMappings.setObjectForKey("A", "Å");
    g_letterMappings.setObjectForKey("a", "à");
    g_letterMappings.setObjectForKey("a", "á");
    g_letterMappings.setObjectForKey("a", "â");
    g_letterMappings.setObjectForKey("a", "ã");
    g_letterMappings.setObjectForKey("a", "ä");
    g_letterMappings.setObjectForKey("a", "å");

    g_letterMappings.setObjectForKey("C", "Ç");
    g_letterMappings.setObjectForKey("c", "ç");

    g_letterMappings.setObjectForKey("E", "È");
    g_letterMappings.setObjectForKey("E", "É");
    g_letterMappings.setObjectForKey("E", "Ê");
    g_letterMappings.setObjectForKey("E", "Ë");
    g_letterMappings.setObjectForKey("e", "è");
    g_letterMappings.setObjectForKey("e", "é");
    g_letterMappings.setObjectForKey("e", "ê");
    g_letterMappings.setObjectForKey("e", "ë");

    g_letterMappings.setObjectForKey("I", "Ì");
    g_letterMappings.setObjectForKey("I", "Í");
    g_letterMappings.setObjectForKey("I", "Î");
    g_letterMappings.setObjectForKey("I", "Ï");
    g_letterMappings.setObjectForKey("i", "ì");
    g_letterMappings.setObjectForKey("i", "í");
    g_letterMappings.setObjectForKey("i", "î");
    g_letterMappings.setObjectForKey("i", "ï");

    g_letterMappings.setObjectForKey("N", "Ñ");
    g_letterMappings.setObjectForKey("n", "ñ");

    g_letterMappings.setObjectForKey("O", "Ò");
    g_letterMappings.setObjectForKey("O", "Ó");
    g_letterMappings.setObjectForKey("O", "Ô");
    g_letterMappings.setObjectForKey("O", "Õ");
    g_letterMappings.setObjectForKey("O", "Ö");
    g_letterMappings.setObjectForKey("o", "ò");
    g_letterMappings.setObjectForKey("o", "ó");
    g_letterMappings.setObjectForKey("o", "ô");
    g_letterMappings.setObjectForKey("o", "õ");
    g_letterMappings.setObjectForKey("o", "ö");

    g_letterMappings.setObjectForKey("U", "Ù");
    g_letterMappings.setObjectForKey("U", "Ú");
    g_letterMappings.setObjectForKey("U", "Û");
    g_letterMappings.setObjectForKey("U", "Ü");
    g_letterMappings.setObjectForKey("u", "ù");
    g_letterMappings.setObjectForKey("u", "ú");
    g_letterMappings.setObjectForKey("u", "û");
    g_letterMappings.setObjectForKey("u", "ü");

    g_letterMappings.setObjectForKey("Y", "Ý");
    g_letterMappings.setObjectForKey("y", "ý");
    g_letterMappings.setObjectForKey("y", "ÿ");
  }

  /**
   * Capitalizes each word in the provided string and returns the result.
   */
  public static function capitalizeWords(words:String):String
  {
    var arrWords:Array = words.split(" ");

    var len:Number = arrWords.length; // apparently faster according to MM
    for (var i:Number = 0; i < len; i++)
    {
      var word:String = arrWords[i];
      arrWords[i] = word.charAt(0).toUpperCase() + word.substring(1);
    }

    return arrWords.join(" ");
  }

  /**
   * Returns <code>true</code> if <code>obj</code> contains a method
   * name <code>sel</code>.
   */
  public static function respondsToSelector(obj:Object, sel:String):Boolean {
    return (obj[sel] != undefined) && (obj[sel] instanceof Function);
  }

  /**
   * Returns a a scaled <code>size</code> with proportions intact, made to
   * fit within the size <code>maxSize</code>.
   */
  public static function scaleSizeToSize(size:NSSize, maxSize:NSSize):NSSize
  {
    var arWidth:Number = maxSize.width / size.width;
    var arHeight:Number = maxSize.height / size.height;
    var h:Number;
    var w:Number;

    if (arHeight >= arWidth)
    {
      h = size.height * arWidth;
      w = size.width * arWidth;
    }
    else
    {
      h = size.height * arHeight;
      w = size.width * arHeight;
    }

    return new NSSize(w, h);
  }

  /**
   * Records all classes in a static array, and calls <code>#initialize</code>
   * on every class containing the method.
   *
   * This method also decorates classes with <code>__className</code> and
   * <code>__packageName</code> variables.
   */
  public static function initializeClasses():Void {
    g_classes = new NSArray();
    initializeClassesWithPackage(_global, "");
  }

  /**
   * Initializes each class in <code>package</code>, and initializes sub
   * packages recursively.
   */
  public static function initializeClassesWithPackage(package:Object,
      packageName:String):Void {

    var basePackageName:String = packageName;
    if (basePackageName.length > 0) {
      basePackageName += ".";
    }

    for (var key:String in package) {
      var obj:Object = package[key];
      if (typeof(obj) == "function" || obj instanceof Function) { // class
        //
        // Call initialize method if possible
        //
        if (respondsToSelector(obj, "initialize")) {
          obj["initialize"].call(obj);
        }

        //
        // Decorate class
        //
        obj.__className = key;
        obj.__packageName = packageName;
        obj.__packageRef = package;

        //
        // Add class to classes array
        //
        g_classes.addObject(obj);
      }
      else if (typeof(obj) == "movieclip" || obj instanceof MovieClip) {
        continue; // do nothing
      }
      else if (obj instanceof Object) { // package
        initializeClassesWithPackage(obj, basePackageName + key);
      }
    }
  }

  //******************************************************
  //*                   XML stuff
  //******************************************************

  /**
   * Returns the root node of the tree containing <code>node</code>.
   */
  public static function rootNodeOfNode(node:XMLNode):XMLNode {
    var parent:XMLNode = node;

    while (parent.parentNode != null) {
      parent = parent.parentNode;
    }

    return parent;
  }

  //******************************************************
  //*                   URL stuff
  //******************************************************

  /**
   * Returns the protocol of url, or <code>null</code> if
   * the connection does not have a url or if no protocol is specified by
   * the url.
   */
  public static function protocolOfURL(url:String):String {
    if (null == url) {
      return null;
    }

    var parts:Array = url.split(":");
    if (parts.length == 1) {
      return null;
    }

    return parts[0];
  }

  /**
   * Returns the port of <code>url</code>, or <code>null</code> if
   * the connection does not have a url or if no port is specified by
   * the url.
   */
  public static function portOfURL(url:String):Number {
    if (null == url) {
      return null;
    }

    var parts:Array = url.split(":");
    if (parts.length <= 2) {
      return null;
    }

    return Number(parts[2]); //! FIXME This won't work when auth info in url
  }
}