package org.aib.command;

import org.aib.common.Action;
import org.aib.common.Outlet;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.aib.except.InvalidCommandStringException;

/**
 * <p>
 * Writes out a class stub in a format AIB can understand. The stub will contain
 * outlets and actions. The command string arguments are in the following
 * format:
 * </p>
 * fullClassPath:String, {type:(ACTION|OUTLET); name:String[; objType:String]}
 * 
 * @author Scott
 */
public class WriteClassStubCommand implements ICommand {

	protected String classPath;

	protected List<Outlet> outlets;

	protected List<Action> actions;

	public WriteClassStubCommand() {
		outlets = new ArrayList<Outlet>();
		actions = new ArrayList<Action>();
	}

	public void setArguments(String[] args)
			throws InvalidCommandStringException {
		if (args.length == 0) {
			throw new InvalidCommandStringException(
					"This command requires at least a class path");
		}

		classPath = args[0];

		//
		// Extract objects
		//
		List<Map<String, String>> objects = CommandUtils
				.extractObjectArguments(args);
		
		//
		// Parse objects
		//
		for (Map<String, String> map : objects) {
			if (!map.containsKey("type")) {
				throw new InvalidCommandStringException("type not specified");
			}
			
			if (!map.containsKey("name")) {
				throw new InvalidCommandStringException("name not specified");
			}
			
			if (map.get("type") == "ACTION") {
				actions.add(new Action(map.get("name")));
			}
			else if (map.get("type") == "OUTLET") {
				if (!map.containsKey("retType")) {
					throw new InvalidCommandStringException("retType not specified");
				}
				outlets.add(new Outlet(map.get("name"), map.get("retType")));
			} else {
				throw new InvalidCommandStringException("invalid type");
			}
		}
	}

	public String execute() {
		// TODO Auto-generated method stub
		return null;
	}

	/**
	 * Registers the command with the factory.
	 */
	static {
		CommandFactory.registerCommand("writeClassStub",
				new WriteClassStubCommand());
	}
}
