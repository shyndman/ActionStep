package org.aib.server;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class SocketServer {

	private ServerSocket serverSocket;
	
	/**
	 * Constructs the SocketServer and starts listening to ports.
	 */
	public SocketServer() {
		init();
	}
	
	/**
	 * Initializes the socket server.
	 */
	private void init() {
		//
		// Start the server socket
		//
		try {
			serverSocket = new ServerSocket(Constants.SERVER_PORT);
		} catch (IOException e) {
			System.err.println("Unable to listen on port " + Constants.SERVER_PORT);
			System.exit(1);
		}
		
		//
		// Listen for client connection
		//
		while (true) {
			Socket clientSocket = null;
			try {
				System.out.println("Waiting for a client to connect");
				clientSocket = this.serverSocket.accept();
				ClientConnection con = new ClientConnection(clientSocket, this);

				System.out.println("Client connected to me");
				Thread t = new Thread(con);
				t.start();
			} catch (IOException e) {
				System.err.println("Accept failed.");
				// this.serverSocket.close();//TODO
				System.exit(1);
			}
		}
	}
}
