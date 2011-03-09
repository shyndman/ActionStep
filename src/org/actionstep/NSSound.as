/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.NSDictionary;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSObject;
import org.actionstep.NSException;

/**
 * Represents a sound.
 * 
 * This offers a layer of abstraction around Macromedia's Sound class, and hides
 * strange behaviour that class exhibits.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSSound extends NSObject {

	private static var g_namedSounds:NSDictionary;
	
	private var m_internalSound:Sound;
	private var m_delegate:Object;
	private var m_name:String;
	private var m_isLoaded:Boolean;
	private var m_isPlaying:Boolean;
	private var m_currentPosition:Number;
	private var m_volume:Number;
	
	private var m_linkageID:String;
	private var m_url:String;	
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Constructs a new instance of NSSound.
	 */
	public function NSSound()
	{
		m_internalSound = new Sound();
		m_linkageID = null;
		m_url = null;
		m_name = null;
		m_delegate = null;
		m_isLoaded = false;
		m_isPlaying = false;
		m_currentPosition = 0;
		m_volume = 1;
		
		addCompleteHandlerToSound();
	}
	
	/**
	 * Initializes a newly created NSSound with a Sound object.
	 */
	public function initWithSound(sound:Sound):NSSound
	{
		m_internalSound = sound;
		m_isLoaded = true;
		return this;
	}
	
	/**
	 * Initializes the newly created NSSound with the MP3 found at 
	 * <code>url</code>.
	 * 
	 * An NSSoundDidLoadNotification is posted to the default notification 
	 * center when the sound finishes loading.
	 */
	public function initWithContentsOfURL(url:String):NSSound
	{
		var self:NSSound = this;

		//
		// Create load handler
		//		
		m_internalSound.onLoad = function(success:Boolean)
		{
			self["m_isLoaded"] = success;
			
			//
			// Post notification
			//
			NSNotificationCenter.defaultCenter().
				postNotificationWithNameObjectUserInfo(
					NSSound.NSSoundDidLoadNotification,
					self,
					NSDictionary.dictionaryWithObjectForKey(
						success, "succeeded"));
		};
		
		m_internalSound.loadSound(url);
		m_url = url;
		return this;
	}
	
	/**
	 * Initializes a newly created NSSound instance with the library sound
	 * associated with the linkage ID <code>linkageID</code>.
	 */
	public function initWithLinkageID(linkageID:String):NSSound
	{
		m_linkageID = linkageID;
		
		m_internalSound.attachSound(linkageID);		
		m_isLoaded = true;
		
		m_internalSound.onSoundComplete = null;
		addCompleteHandlerToSound();
		
		return this;
	}
	
	//******************************************************															 
	//*                    Properties
	//******************************************************
	
	/**
	 * Returns a string representation of the object.
	 */
	public function description():String 
	{
		var ret:String = "NSSound(";
		
		if (null != name()) {
			ret += "name=" + name() + ",";	
		}
		
		ret += "isLoaded=" + isLoaded() + ",isPlaying=" + isPlaying();
		
		if (null != m_linkageID) {
			ret += ",linkageID=" + m_linkageID;
		}
		else if (null != m_url) {
			ret += ",url=" + m_url;	
		}
		
		ret += ",delegate=" + delegate();
		
		return ret + ")";
	}
	
	/**
	 * Returns the internal <code>Sound</code> used by this instance.
	 */
	public function internalSound():Sound 
	{
		return m_internalSound;	
	}
	
	
	/**
	 * Returns <code>true</code> if the sound is loaded, or <code>false</code>
	 * otherwise.
	 * 
	 * This is an ActionStep only method.
	 */
	public function isLoaded():Boolean
	{
		return m_isLoaded;
	}
	
	/**
	 * Returns the name under which this sound is registered.
	 * 
	 * @see #setName
	 * @see #soundNamed
	 */
	public function name():String 
	{
		return m_name;
	}
	
	/**
	 * Registers this sound with a name so that it can be accessed by using
	 * <code>NSSound.soundWithName(String)</code>. If this sound already has
	 * a name, the old name is deregistered. This method returns 
	 * <code>true</code> if the sound is successfully registered, and 
	 * <code>false</code> if a sound with this name already exists.
	 * 
	 * @see #name
	 * @see #soundNamed
	 */
	public function setName(name:String):Boolean 
	{
		if (undefined == g_namedSounds) {
			g_namedSounds = NSDictionary.dictionary();
		}
		
		//
		// Name already exists.
		//
		if (null != g_namedSounds.objectForKey(name)) {
			return false;
		}
		
		//
		// Deregister old name if one exists
		//
		if (null != m_name) {
			g_namedSounds.removeObjectForKey(name);
		}
		
		//
		// Register name
		//		
		g_namedSounds.setObjectForKey(this, name);	
		m_name = name;
		
		return true;
	}
	
	//******************************************************															 
	//*                     Playing
	//******************************************************
	
	/**
	 * Returns <code>true</code> if the sound is playing, and <code>false</code> 
	 * otherwise.
	 */
	public function isPlaying():Boolean 
	{
		return m_isPlaying;
	}
	
	/**
	 * Pauses audio playback. Returns <code>true</code> if successful, or 
	 * <code>false</code> otherwise.
	 */
	public function pause():Boolean 
	{
		if (!m_isLoaded) 
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSInvalidOperationException",
				"You cannot pause a sound that has not loaded.",
				null);
			trace(e);
			throw e;
		}
		
		if (!isPlaying()) {
			return false;
		}
		
		//
		// Record current position
		//
		m_currentPosition = m_internalSound.position;
		
		//
		// Stop specific sound if there is a linkage ID. This is to get around
		// weirdness in MM's object model.
		//
		if (null != m_linkageID) {
			m_internalSound.stop(m_linkageID);
		}
		else {
			m_internalSound.stop();
		}
		
		m_isPlaying = false;
		
		return true;
	}
	
	/**
	 * Starts the sound.
	 */
	public function play():Boolean
	{
		if (!m_isLoaded) 
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSInvalidOperationException",
				"You cannot play a sound that has not loaded.",
				null);
			trace(e);
			throw e;
		}
		
		if (isPlaying()) {
			return false;
		}
		
		m_currentPosition = 0;
		m_internalSound.start();
		m_isPlaying = true;
		
		return true;
	}
	
	/**
	 * Resumes playing of a sound after it has been paused. Returns 
	 * <code>true</code> if successful, or <code>false</code> otherwise.
	 */
	public function resume():Boolean
	{
		if (!m_isLoaded) 
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSInvalidOperationException",
				"You cannot resume a sound that has not loaded.",
				null);
			trace(e);
			throw e;
		}
		
		if (isPlaying()) {
			return false;
		}
		
		m_internalSound.start(m_currentPosition / 1000);
		m_isPlaying = true;
		
		return true;
	}
	
	/**
	 * Stops the sound.
	 */
	public function stop():Boolean
	{
		if (!m_isLoaded) 
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSInvalidOperationException",
				"You cannot stop a sound that has not loaded.",
				null);
			trace(e);
			throw e;
		}

		if (!isPlaying()) {
			return false;
		}
				
		//
		// Stop specific sound if there is a linkage ID. This is to get around
		// weirdness in MM's object model.
		//
		if (null != m_linkageID) {
			m_internalSound.stop(m_linkageID);
		}
		else {
			m_internalSound.stop();
		}
		
		m_isPlaying = false;
		m_currentPosition = 0;
		
		return true;
	}
	
	//******************************************************															 
	//*               Setting the volume
	//******************************************************
	
	/**
	 * Returns a value from 0.0 to 1.0 representing the volume of the sound.
	 * 
	 * The default value is 1.0.
	 */
	public function volume():Number {
		return m_volume;
	}
	
	/**
	 * Sets the volume of the sound to <code>volume</code>.
	 * 
	 * Volume is a value from 0.0 to 1.0, where 0.0 is silent and 1.0 is
	 * maximum volume.
	 */
	public function setVolume(volume:Number):Void {
		if (volume < 0) {
			volume = 0;
		}
		else if (volume > 1) {
			volume = 1;
		}
		
		m_volume = volume;
		m_internalSound.setVolume(volume * 100);
	}
	
	//******************************************************															 
	//*                    Delegate
	//******************************************************
	
	/**
	 * Returns the delegate for this sound. 
	 * 
	 * @see #setDelegate
	 */
	public function delegate():Object
	{
		return m_delegate;	
	}
	
	/**
	 * Sets the delegate for this sound. When the sound finishes playing, the
	 * <code>soundDidFinishPlaying(NSSound, Boolean)</code> is invoked on
	 * the delegate.
	 * 
	 * @see #delegate
	 */
	public function setDelegate(aDelegate:Object):Void
	{
		m_delegate = aDelegate;
	}
	
	//******************************************************															 
	//*               Protected Methods
	//******************************************************
	
	/**
	 * Invoked when the sound finishes playing.
	 */
	private function soundDidFinishPlaying():Void
	{
		delegate()["soundDidFinishPlaying"](this, true);
	}
	
	private function addCompleteHandlerToSound():Void
	{
		var self:NSSound = this;
		
		m_internalSound.onSoundComplete = function()
		{
			self["soundDidFinishPlaying"](self, true); //! check 2nd arg
		};
	}
	
	//******************************************************															 
	//*                  Naming Sounds
	//******************************************************
	
	/**
	 * Returns the sound named <code>name</code>.
	 * 
	 * @see #name
	 * @see #setName
	 */
	public static function soundNamed(name:String):NSSound
	{
		return NSSound(g_namedSounds.objectForKey(name));
	}
	
	//******************************************************															 
	//*                 Notifications
	//******************************************************
	
	/**
	 * This notification is posted to the default notification center when
	 * a sound initialized through initWithContentsOfURL() finishes loading.
	 * 
	 * The userdata collection contains the following fields:
	 *   "succeeded":
	 */
	public static var NSSoundDidLoadNotification:Number 
		= ASUtils.intern("NSSoundDidLoadNotification");
}