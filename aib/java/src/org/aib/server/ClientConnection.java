package org.aib.server;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

import org.aib.command.CommandFactory;
import org.aib.command.ICommand;
import org.aib.except.InvalidCommandStringException;

/**
 * Represents a connection to a client. Handles communication.
 * 
 * @author Scott
 */
public class ClientConnection implements Runnable {

	protected Socket socket;
	protected SocketServer server;
	protected PrintWriter out;
	protected BufferedReader in;
	
	/**
	 * Creates a new instance of the <code>ClientConnection</code> class.
	 * 
	 * @param socket The client's socket
	 * @param server The socket server
	 */
	public ClientConnection(Socket socket, SocketServer server) {
		this.socket = socket;
		this.server = server;
	}

	/**
	 * Listens and writes to the socket.
	 */
	public void run() {
		try {
			out = new PrintWriter(socket.getOutputStream(), true);
			in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
			String inputLine;
			ICommand cmd;
			
			while ((inputLine = in.readLine()) != null) {
				try {
					cmd = CommandFactory.createCommand(inputLine);
				} catch (InvalidCommandStringException e) {
					System.err.println("Invalid command string.\n" + e.toString());
					continue;
				}
				
				String res = cmd.execute();
				
				if (res != null) {
					out.print(res + "\0");
				}
			}
			
			out.close();
			in.close();
			socket.close();
		} catch (IOException e) {
			System.out.println("IOE in run");
			out.close();			
		}
	}
}
