/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;
import flash.display.BitmapData;

/**
 * @author Tay Ray Chuan
 */

class org.actionstep.test.menu.ASTestLogo extends NSObject {
	public var bitmap:BitmapData;

	private var m_mc:MovieClip;
	private var m_mcl:MovieClipLoader;
	private var m_symbolName:String;

	private var m_target:Object;
	private var m_sel:String;

	public function ASTestLogo(mc:MovieClip) {
		m_mc = mc.createEmptyMovieClip("ASTestLogo_Holder", mc.getNextHighestDepth());
		m_mcl = new MovieClipLoader();
		m_mcl.addListener(this);
	}

	public function initWithLocationSymbol(url:String, name:String):ASTestLogo {
		m_symbolName = name;
		m_mcl.loadClip(url, m_mc);

		return this;
	}

	private function onLoadError(target:MovieClip, error:String, httpStatus:Number):Void {
		//trace(asFatal(httpStatus+": "+error));

		 bitmap = new BitmapData(10, 10, false, 0xFF0000);
		m_target[m_sel].call(m_target, bitmap);
	}

	private function onLoadInit(target:MovieClip):Void {
		var mc:MovieClip = target.attachMovie(
		m_symbolName, "bd-temp", target.getNextHighestDepth());
		bitmap = new BitmapData(mc._width, mc._height, true, null);
		bitmap.draw(mc);

		m_target[m_sel].call(m_target, bitmap);
	}

	public function setTarget(o:Object):Void {
		m_target = o;
	}

	public function setSelector(sel:String):Void {
		m_sel = sel;
	}
}