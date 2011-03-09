/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Constants that correspond to a cell in an ASUpDownCell.
 *
 * @author Tay Ray Chuan
 */

class org.actionstep.constants.ASUpDownCellPart extends ASConstantValue {

	public static var ASUpCell:ASUpDownCellPart = new ASUpDownCellPart(0);
	public static var ASDownCell:ASUpDownCellPart = new ASUpDownCellPart(1);

	private function ASUpDownCellPart(num:Number) {
	  super(num);
	}
}