package org.aib.except;

/**
 * Thrown when the server receives a command string it cannot understand.
 * 
 * @author Scott
 */
public class InvalidCommandStringException extends Exception {

	/**
	 * Exception ID.
	 */
	private static final long serialVersionUID = 8257315794150947875L;
	
	/**
	 * Creates a new InvalidCommandStringException with no message.
	 */
	public InvalidCommandStringException() {
		super();
	}
	
	/**
	 * Creates a new InvalidCommandStringException with a message.
	 * @param message The message
	 */
	public InvalidCommandStringException(String message) {
		super(message);
	}
}
