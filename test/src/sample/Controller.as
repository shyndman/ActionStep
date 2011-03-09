import org.actionstep.NSTextField;

/**
 * @author Scott Hyndman
 */
class sample.Controller 
{
	private var m_src:NSTextField;
	private var m_dest:NSTextField;
	
	public function setSrc(tf:NSTextField)
	{
		m_src = tf;
	}
	
	public function setDest(tf:NSTextField)
	{
		m_dest = tf;
	}
	
	public function copyText():Void
	{
		m_dest.setStringValue(m_src.stringValue());
		m_dest.setNeedsDisplay(true);
	}
}