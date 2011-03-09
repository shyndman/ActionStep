/* See LICENSE for copyright and terms of use */

import org.aib.AIBObject;

/**
 * Handles communication with the Java file worker program.
 * 
 * @author Scott Hyndman
 */
class org.aib.FileSystemAccessor extends AIBObject {
	private static var g_instance:FileSystemAccessor;
	private var m_socket:XMLSocket;
	private var m_host:String;
	private var m_port:Number;
	
	/**
	 * Creates a new instance of the <code>FileAccessor</code> class.
	 */
	public function FileSystemAccessor() {
	}
	
	/**
	 * Initializes and returns the file accessor with the host name and port
	 * number of that the Java file worker uses to communicate.
	 */
	public function initWithHostPort(host:String, port:Number):FileSystemAccessor {
		m_host = host;
		m_port = port;
		
		//
		// Build the socket
		//
		var self:FileSystemAccessor = this;
		m_socket = new XMLSocket();
		m_socket.onConnect = function(success:Boolean):Void {
			self.__socketDidConnect(success);
		};
		m_socket.onClose = function():Void {
			self.__socketDidClose();
		};
		m_socket.onData = function(data:String):Void {
			self.__socketReceivedData(data);
		};
		m_socket.connect(m_host, m_port);
		
		return this;
	}
	
	//******************************************************
	//*            Responding to socket events
	//******************************************************
	
	/**
	 * <p>Fired when a connection to the server is established.</p>
	 * 
	 * <p>For internal use only.</p>
	 */
	public function __socketDidConnect(success:Boolean):Void {
		
	}
	
	/**
	 * <p>Fired when the socket receives data.</p>
	 * 
	 * <p>For internal use only.</p>
	 */
	public function __socketReceivedData(data:String):Void {
		
	}
	
	/**
	 * <p>Fired when the socket closes it's connection with the server.</p>
	 * 
	 * <p>For internal use only.</p>
	 */
	public function __socketDidClose():Void {
		
	}
	
	//******************************************************
	//*               Getting the instance
	//******************************************************
	
	/**
	 * Returns the file accessor instance.
	 */
	public static function instance():FileSystemAccessor {
		if (g_instance == null) {
			g_instance = new FileSystemAccessor();
			g_instance.init();
		}
		
		return g_instance;
	}
}