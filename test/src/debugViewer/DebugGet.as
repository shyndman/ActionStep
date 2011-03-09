import org.actionstep.ASDebugger;
import org.actionstep.debug.ASDebuggingPanel;

class debugViewer.DebugGet {

	//******************************************************
	//*                  Class members
	//******************************************************

	static var instance:DebugGet;

	//******************************************************
	//*                 Member variables
	//******************************************************

	private var m_hostname:String;
	private var m_connected:Boolean;
	private var m_identifier:String;
	private var m_connection:XMLSocket;
	private var m_port:Number;

	//******************************************************
	//*                    Construction
	//******************************************************

	/**
	 * Creates a new instance of the <code>DebugGet</code> class.
	 */
	private function DebugGet(hostname:String, given_port:Number) {
		if (hostname != undefined) {
			m_hostname = hostname;
		} else {
			m_hostname = ASDebugger.DEFAULT_HOSTNAME;
		}

		if (given_port != undefined) {
			m_port = given_port;
		} else {
			m_port = ASDebugger.DEFAULT_PORT;
		}
	}

	public static function start(hostname:String, given_port:Number):DebugGet {
		DebugGet.instance = new DebugGet(hostname, given_port);
		DebugGet.instance.begin();
		return DebugGet.instance;
	}

	public function begin():Void {
		m_connection = new XMLSocket();
		var self:DebugGet = this;
		m_connection.onConnect = function(success:Boolean) {
			self.onConnect(success);
		};
		m_connection.onData = function(data:String) {
			if(data=="") {
				return;
			}
			self.onMessage(data);
		};
		m_connection.connect(m_hostname, m_port);
		m_connection.send("DEBUG_OUTPUT");
	}

	public function onClose():Void {
	}

	public function onConnect(isConnected:Boolean):Void {
		m_connected = isConnected;
	}

	public function onMessage(message:String):Void {
		var bracket:Number = message.indexOf("]");

		var levelName:String = message.substring(0, bracket+1);
		var level:Number;
		for(var i:String in ASDebugger.LEVELS) {
			if(ASDebugger.LEVELS[i]==levelName) {
				level = parseInt(i);
				break;
			}
		}

		if(level==null) {
			ASDebuggingPanel.traceLine(ASDebugger.FATAL,
			"unknown level: "+message+", "+message.indexOf("]"), "debugViewer.DebugGet",
			"onMessage");
			return;
		}

		var arr:Array = message.split(" -- ");
		var obj:String = String(arr[0]).substring(bracket+2);
		var data:String = arr[arr.length - 1];
		var colon:Number = data.indexOf(":");
		var space:Number = data.indexOf(" ");

		var klass:String = data.substring(0, colon);
		var line:Number = parseInt(data.substring(colon+1, space));
		var func:String = data.substring(space+2, data.indexOf(")"));

		ASDebuggingPanel.traceLine(level, obj, klass, func, line);
	}

	public function send(message:String):Void {
		m_connection.send(message);
	}
}