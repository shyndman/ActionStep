package org.aib.command;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Common command utilities.
 * 
 * @author Scott
 */
public final class CommandUtils {
	
	public static List<Map<String, String>> extractObjectArguments(String[] args) {
		ArrayList<Map<String, String>> ret = new ArrayList<Map<String, String>>();
		
		for (int i = 0; i < args.length; i++) {
			Map<String, String> map = new HashMap<String, String>();
			String objString = args[i].substring(1, args[i].lastIndexOf("}"));
			String[] props = objString.split(";");
			for (int j = 0; j < props.length; j++) {
				String[] parts = props[j].split(":");
				map.put(parts[0].trim(), parts[1].trim());
			}
			ret.add(map);
		}
		
		return ret;
	}
}
