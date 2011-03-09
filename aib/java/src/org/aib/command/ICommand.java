package org.aib.command;

import org.aib.except.InvalidCommandStringException;

/**
 * Performs an operation.
 */
public interface ICommand {
	
	/**
	 * @param args The arguments used by the command.
	 */
	public void setArguments(String[] args) throws InvalidCommandStringException;
	
	/**
	 * Executes the operation.
	 * 
	 * @return The string to return to the client.
	 */
	public String execute();
}
