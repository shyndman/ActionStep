/* See LICENSE for copyright and terms of use */

import org.actionstep.*;
import org.actionstep.layout.*;
import org.actionstep.rpc.*;
import org.actionstep.rpc.remoting.*;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestRecordSet {
	private var m_grid:ASGrid;

	public static function test():Void {
		var inst:ASTestRecordSet = new ASTestRecordSet();
	}

	public function ASTestRecordSet() {
		//
		// Create app and window
		//
		var app:NSApplication = NSApplication.sharedApplication();
		var wnd:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0,0,450,350));
		var stage:NSView = wnd.contentView();

		//
		// Create controls
		//
		var grid:ASGrid = (new ASGrid()).init();
		m_grid = grid;

		var box:NSBox = (new NSBox()).initWithFrame(
			wnd.frame().scaledRect(0, -50));
		box.setTitle("Data:");
		//box.setContentView(grid);
		stage.addSubview(grid);

		var btn:NSButton = (new NSButton()).initWithFrame(
			new NSRect(0, 0, 100, 35));
		btn.setStringValue("Get");
		btn.setFrameOrigin(new NSPoint(0, stage.frame().maxY()-btn.frame().size.height));
		stage.addSubview(btn);

		//
		// Create the service object
		//
		var service:ASRemotingService = (new ASRemotingService()).initWithNameGatewayURLTracing(
			"MyRecordSet",  // service name
			"http://localhost/amfphp/gateway.php", // gateway URL
			true); // will trace status messages

		//
		// Set the timeout
		//
		service.setTimeout(ASRpcConstants.ASNoTimeOut);

		var self:ASTestRecordSet = this;
		btn.setAction("trigger");
		btn.setTarget({
			trigger: function():Void {
				var call:ASRemotingPendingCall = service.data();
				call.setResponder(self);
			}
		});
		btn.sendActionTo(btn.action(), btn.target());

//		didReceiveResponse();

		//
		// Run the app
		//
		app.run();
	}

		//
		// Responder-related
		//
		private function didReceiveResponse(response:ASResponse):Void {
			var rs:ASRecordSet = ASRecordSet(response.response());

			//
			// Add recordset manipulations here
			//
			rs.removeColumn(String(rs.columnNames().objectAtIndex(0)));

			updateDisplayWithData(rs);
		}

		private function didEncounterError(fault:ASFault):Void {
			trace(fault.description(), ASDebugger.ERROR);
		}

		//
		// Display-related
		//
		private function updateDisplayWithData(rs:ASRecordSet):Void {
			var cols:NSArray = rs.columnNames();
			var rows:NSArray = rs.rowValues();
			var x:Number = cols.count();
			var y:Number = rows.count();

			//m_grid.release();
			m_grid.initWithNumberOfRowsNumberOfColumns(y+1, x);

			// Add columns
			for(var i:Number=0; i<x; i++) {
				m_grid.putViewAtRowColumnWithMinXMarginMaxXMarginMinYMarginMaxYMargin(
					createHeaderCell(String(cols.objectAtIndex(i))), 0, i, 0, 0, 0, 0);
			}

			// Add rows
			for(var i:Number=0; i<x; i++) {
				for(var j:Number=0; j<y; j++) {
					m_grid.putViewAtRowColumnWithMinXMarginMaxXMarginMinYMarginMaxYMargin(
						createRowCell(String(rows.objectAtIndex(j)[i])), j+1, i, 0, 0, 0, 0);
				}
			}
		}

		private function createHeaderCell(value:String):NSTextField {
			var tf:NSTextField = createTextField(value);
			var font:NSFont = tf.font();
			tf.setFont(NSFont.boldFontWithFont(font));
			return tf;
		}

		private function createRowCell(value:String):NSTextField {
			var tf:NSTextField = createTextField(value);
			tf.setTextColor(ASColors.redColor());
			return tf;
		}

		private function createTextField(value:String):NSTextField {
			var tf:NSTextField = (new NSTextField()).initWithFrame(
				new NSRect(0, 0, 50, 20));
			tf.setAutoresizingMask(NSView.WidthSizable);
			tf.setSelectable(false);
			tf.setEditable(false);
			tf.setDrawsBackground(false);
			tf.setBackgroundColor(ASColors.clearColor());
			tf.setStringValue(value);
			var size:NSSize = tf.font().getTextExtent(value);
			size.width += 5;
			tf.setFrameSize(size);
			return tf;
		}
}