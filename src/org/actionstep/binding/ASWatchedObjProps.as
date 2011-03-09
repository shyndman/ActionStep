/* See LICENSE for copyright and terms of use */

/**
 * @author Tay Ray Chuan
 */

class org.actionstep.binding.ASWatchedObjProps {
	private var m_observers:Object;
	
	public function ASWatchedObjProps() {
		m_observers = {};
	}
	
	public function hasWrappedSetter(setter:String):Boolean {
		return m_observers[setter]!=null;
	}
	
	public function addObserverForSetter(ob:Object, setter:String):Void {
		if(m_observers[setter]==null) {
			m_observers[setter]=[];
		}
		var x:Array = m_observers[setter];
		x.push(ob);
	}
	
	public function observers(s:String):Array {
		return m_observers[s];
	}
	
	public function removeSetter(setter:String):Void {
		delete m_observers[setter];
	}
}