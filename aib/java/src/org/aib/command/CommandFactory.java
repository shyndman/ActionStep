package org.aib.command;

import java.util.HashMap;
import java.util.Map;

import org.aib.except.InvalidCommandStringException;

/**
 * Handles the creation of commands from command strings sent by the client.
 * 
 * @author Scott
 */
public class CommandFactory {
	
	private static Map<String, ICommand> commands = new HashMap<String, ICommand>();
	
	/**
	 * Registers a named command with the factory.
	 * 
	 * @param name The name of the command.
	 * @param cmd The command
	 */
	public static void registerCommand(String name, ICommand cmd) {
		commands.put(name, cmd);
	}
	
	/**
	 * Creates a command using a complete command string.
	 * 
	 * @param commandString The command string
	 * @return The command
	 * @throws InvalidCommandStringException If <code>commandString</code>
	 * could not be understood.
	 */
	public static ICommand createCommand(String commandString) 
			throws InvalidCommandStringException {
		//
		// Get the command
		//
		String name = commandString.substring(0, commandString.indexOf("("));
		ICommand cmd = commands.get(name);
		
		if (cmd == null) {
			throw new InvalidCommandStringException(name + " is not a known command");
		}
		
		//
		// Extract arguments
		//
		String argString = commandString.substring(
				commandString.indexOf("(") + 1, commandString.lastIndexOf(")"));
		
		if (argString.length() > 0) {
			cmd.setArguments(argString.split(","));
		} else {
			cmd.setArguments(new String[] {});
		}
		
		return cmd;
	}
}
