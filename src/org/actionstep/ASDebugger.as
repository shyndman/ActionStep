/* See LICENSE for copyright and terms of use */

import org.actionstep.debug.ASDebuggingPanel;
import org.actionstep.NSException;

/**
 * The ActionStep debugger.
 *
 * By routing your trace output to <code>ASDebugger.debugPanelTrace</code>, you
 * will be shown a debug panel in your output swf that displays formatted trace
 * messages.
 *
 * @author Richard Kilmer
 * @author Tay Ray Chuan
 * @author Scott Hyndman
 */
class org.actionstep.ASDebugger extends org.actionstep.NSObject {

	//******************************************************
	//*                    Levels
	//******************************************************

	static var ALL:Number = 6;
	static var DEBUG:Number = 5;
	static var INFO:Number = 4;
	static var WARNING:Number = 3;
	static var ERROR:Number = 2;
	static var FATAL:Number = 1;
	static var NONE:Number = 0;

	static var LEVELS:Array = [
		"[NONE]",
		"[FATAL]",
		"[ERROR]",
		"[WARNING]",
		"[INFO]",
		"[DEBUG]",
		"[ALL]"];

	//******************************************************
	//*                    Constants
	//******************************************************

	static var DEFAULT_HOSTNAME:String = "127.0.0.1";
	static var DEFAULT_PORT:Number = 4500;
	static var DEFAULT_PAD:String = "\t";

	//******************************************************
	//*                  Class members
	//******************************************************

	static var handlers:Array = [];
	static var instance:ASDebugger;
	static var block:Object;
	static var g_level:Number;

	//******************************************************
	//*               Debug helper methods
	//******************************************************

	public static function debug(object:Object):Object {
		return {ASDebuggerObject:object, ASDebuggerLevel:DEBUG};
	}

	public static function info(object:Object):Object {
		return {ASDebuggerObject:object, ASDebuggerLevel:INFO};
	}

	public static function warning(object:Object):Object {
		return {ASDebuggerObject:object, ASDebuggerLevel:WARNING};
	}

	public static function error(object:Object):Object {
		return {ASDebuggerObject:object, ASDebuggerLevel:ERROR};
	}

	public static function fatal(object:Object):Object {
		return {ASDebuggerObject:object, ASDebuggerLevel:FATAL};
	}

	//******************************************************
	//*                 Member variables
	//******************************************************

	private var m_hostname:String;
	private var m_connected:Boolean;
	private var m_identifier:String;
	private var m_connection:XMLSocket;
	private var m_port:Number;
	private var m_pending:Array;

	//******************************************************
	//*                    Construction
	//******************************************************

	/**
	 * Creates a new instance of the <code>ASDebugger</code> class.
	 */
	private function ASDebugger(hostname:String, given_port:Number) {
		if (hostname != undefined) {
			this.m_hostname = hostname;
		} else {
			this.m_hostname = DEFAULT_HOSTNAME;
		}

		if (given_port != undefined) {
			m_port = given_port;
		} else {
			m_port = DEFAULT_PORT;
		}

		g_level = DEBUG;
		m_pending = [];
	}

	//******************************************************
	//*                 Trace functions
	//******************************************************

	/**
	 * Helper function for ASDebugger.*trace functions. Parses arguments
	 * and does some string processing, before returning an array containing
	 * information wanted by the *trace function.
	 *
	 * Note: If a <code>null</code> value is returned, parsing failed, or
	 * <code>object</code> is an instance of <code>NSException</code>
	 *
	 * @return <code>null</code> if failed, or <code>Array</code> if
	 * successful
	 */
	private static function processTrace(object:Object, level:Number, className:String, file:String, line:Number):Array {
		// We need to shift all the params if the level is not provided
		if (line == undefined) {
			line = Number(file);
			file = className;
			className = String(level);
			level = g_level;
		}

		if (object instanceof NSException) {
			NSException(object).addReference(className, file, line);
			return null;
		}

		if (object.ASDebuggerObject != undefined) {
			level = object.ASDebuggerLevel;
			object = object.ASDebuggerObject;
		}

		if(level == null) {
			if(g_level == null) {
				level = DEBUG;
			} else {
				level = g_level;
			}
		} else {
			if (level >= ALL) {
				level = DEBUG;
			}
			else if (level <= NONE) {
				level = FATAL;
			}
		}

		notifyHandlers(object, level, className, file, line);

		 //don't show abs path
		var x:Array = file.split("/");
		file = x[x.length-1];

		//don't display for some classes
		var arr:Array=className.split("::");
		var klass:String = arr[0];		//refers to the function to helped

		if(block[klass]) {
			return null;
		}

		var func:String = arr[1];			//refers to the function to helped
		return [level, klass, line, func, object];
	}

	/**
	 * Outputs a message at the supplied level.	Level defaults to
	 * INFO if not supplied.	This method is used by the MTASC compiler
	 * through using the -trace org.actionstep.ASDebugger.trace method.
	 *
	 * @param object The object to output (via toString)
	 * @param level The level (DEBUG, INFO, WARNING, ERROR, FATAL)
	 * @param className The class the trace is in
	 * @param file The file the trace is in
	 * @param line The line number that trace is on
	 *
	 */
	public static function trace(object:Object, level:Number, className:String, file:String, line:Number) {
		if (ASDebugger.instance == undefined) {
			ASDebugger.start(g_level);
		}

		var out:Array = processTrace.apply(arguments.callee, arguments);

		if(out == null) {	//this means that we have to return
			return;
		}
		// copy out the necessary stuff
		level = out[0];
		var klass:String = out[1];
		line = out[2];
		var func:String = out[3];
		object=out[4];

		// determine whether the message should be traced based on level
		if (level > g_level) {
			return;
		}

		ASDebugger.instance.send(LEVELS[level]+" "+object.toString()+" -- "+klass+":"+line+" ("+func+")");
	}

	/**
	 * Traces output to an instance of <code>ASDebuggingPanel</code>.
	 */
	public static function debugPanelTrace(object:Object, level:Number, className:String, file:String, line:Number) {
		var out:Array = processTrace.apply(arguments.callee, arguments);

		if(out == null) {
			//this means that we have to return
			return;
		}
		//copy out the necessary stuff
		level = out[0];
		var klass:String = out[1];
		line = out[2];
		var func:String = out[3];
		object=out[4];

		// determine whether the message should be traced based on level
		if (level > g_level) {
			return;
		}

		ASDebuggingPanel.traceLine(level, object.toString(), klass, func, line);
	}

	public static function SWFConsoleTrace(object:Object, level:Number, className:String, file:String, line:Number) {
		var out:Array = processTrace.apply(arguments.callee, arguments);

		if(out == null) {
			//this means that we have to return
			return;
		}
		//copy out the necessary stuff
		level = out[0];
		var klass:String = out[1];
		line = out[2];
		var func:String = out[3];
		object=out[4];

		// determine whether the message should be traced based on level
		if (level > g_level) {
			return;
		}

		getURL("javascript:showText('" + LEVELS[level]+" "+object.toString()+" -- "+klass+":"+line+" ("+className.split("::")[1]+")')");
	}

	/**
	* Prints the source of flash var
	*/
	public static function dump(obj:Object, level:Number):String {
		if(obj == null) {
			return null;
		}
		if(level==null) {
			level=0;
		}

		var margin:String = "";
		var len:Number=level;
		while(len--) {
			margin+=DEFAULT_PAD;
		}
		
		if (obj instanceof XML) {
			obj.constructor = XML;
		}

		switch( obj.constructor ){

			case Number:
				return obj.toString();

			case String:
				return	"String(" + obj + ")";

			case Array:
				var els:Array = [];
				for(var key:Object in obj){
					els[els.length] = "\n"
					+margin
					+ key
					+ ":"
					+ dump(obj[key], level+1);
				}
				return "Array("+els.join(", ")+")";

			case XML:
				return dumpXmlNode(obj.firstChild);

			case XMLNode:
				return dumpXmlNode(obj);

			case Object:
			case TextField:	//default + dom
			default:
				if(obj.toString==Object.prototype.toString) {
					var els:Array = [];
					for(var key:Object in obj){
						els[els.length] = "\n"
						+margin
						+ key
						+ ":"
						+ dump(obj[key], level+1);
					}
					return "Object("+els.join(", ")+")";
				} else {
					return obj.toString();
				}
		}
	}

	public static function dumpXmlNode(node:Object, tabs:String):String {
		var str:String = "";

		if (tabs == null) {
			tabs = "";
		}

		if (node.nodeValue != undefined) {
			str += tabs + node.nodeValue + "\n";
		}
		else if (node.nodeName != null) {
			str += tabs + "&lt;" + node.nodeName;
			for (var i:String in node.attributes) {
				str += " " + i + "=\"" + node.attributes[i] + "\"";
			}
			if (node.firstChild != null) {
				str += "&gt;\n";
				for (var n:Number = 0; n < node.childNodes.length; n++) {
					str += dumpXmlNode(node.childNodes[n], tabs + "\t");
				}
				str += tabs + "&lt;/" + node.nodeName + "&gt;\n";
			} else {
				str += " /&gt;\n";
			}
		}
		return str;
	}

	//******************************************************
	//*                   Handlers
	//******************************************************

	public static function addHandler(obj:Object, sel:String):Void {
		handlers.push({obj: obj, sel: sel});
	}

	public static function notifyHandlers(object:Object, level:Number, className:String, file:String, line:Number) {
		var len:Number = handlers.length;
		for (var i:Number = 0; i < len; i++) {
			var obj:Object = handlers[i].obj;
			var sel:String = handlers[i].sel;

			obj[sel].call(obj, object, level, className, file, line);
		}
	}

	//******************************************************
	//*                     Levels
	//******************************************************

	/**
	 * Sets the level of the debugger
	 *
	 * @param level The level (DEBUG, INFO, WARNING, ERROR, FATAL)
	 */
	public static function setLevel(level:Number) {
		if (ASDebugger.instance == undefined) {
			ASDebugger.start(level);
		} else {
			ASDebugger.instance.setCurrentLevel(level);
		}
	}

	function setCurrentLevel(value:Number) {
		g_level = value;
	}

	/**
	 * Returns the level of the debugger.
	 */
	function level():Number {
		return g_level;
	}

	public static function start(level:Number, hostname:String, given_port:Number):ASDebugger {
		ASDebugger.instance = new ASDebugger(hostname, given_port);
		if (level != undefined) {
			ASDebugger.instance.setCurrentLevel(level);
		}
		ASDebugger.instance.begin();
		return ASDebugger.instance;
	}

	public function begin() {
		m_connection = new XMLSocket();
		var self:ASDebugger = this;
		m_connection.onConnect = function(success:Boolean) {
			self.onConnect(success);
		};
		// used quotes since it's not in mtasc's intrinsics
		if(System.security["sandboxType"] == "localTrusted" || System.security["sandboxType"] == "remote") {
			m_connection.connect(m_hostname, m_port);
		}
	}

	public function onClose():Void {
	}

	public function onConnect(isConnected:Boolean):Void {
		m_connected = isConnected;
		if(isConnected) {
			block ={	};
			//eg:
			//block["org/actionstep/test/ASTestSheet.as"] = true;
			var x:String = "";
			for(var i:Object in block) {
				x+="\n\t"+i+"";
			}
			if(x!="") {
				send(">>Blocked classes:"+x);
			}
			//spit out pending messages, in chronological order
			for(var i:Number=0;i<m_pending.length;i++) {
				send(m_pending[i]);
			}
		}
	}

	public function send(message:String) {
		if(m_connected==true) {
			m_connection.send(message);
		} else {
			m_pending.push(message);
		}
	}
}
