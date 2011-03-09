/* See LICENSE for copyright and terms of use */

import org.aib.AIBObject;
import org.actionstep.ASUtils;
import org.actionstep.NSArray;
import org.actionstep.NSImage;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSNotification;
import org.actionstep.NSDictionary;

/**
 * Loads images.
 * 
 * @author Scott Hyndman
 */
class org.aib.util.ImageLoader extends AIBObject {
	
	/**
	 * <p>Fired when an image loader finishes loading all its queued images.</p>
	 * 
	 * <p>The userInfo dictionary contains the following:</p>
	 * <ul>
	 * <li><code>"Images"</code> (NSArray) - The loaded images.</li>
	 * </ul>
	 */
	public static var ImagesDidLoadNotification:Number =
		ASUtils.intern("ImagesDidLoadNotification");
		
	//******************************************************
	//*                   Class members
	//******************************************************
	
	private static var g_instance:ImageLoader;
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_isLoading:Boolean;
	private var m_baseUrl:String;
	private var m_loadCnt:Number;
	private var m_total:Number;
	private var m_loadedImages:NSArray;
	private var m_nc:NSNotificationCenter;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ImageLoader</code> class.
	 */
	public function ImageLoader() {
		m_isLoading = false;
		m_baseUrl = "";
		m_nc = NSNotificationCenter.defaultCenter();
	}
	
	/**
	 * Initializes the image loader.
	 */
	public function init():ImageLoader {
		return this;
	}
	
	//******************************************************
	//*               Setting the base URL
	//******************************************************
	
	/**
	 * <p>Returns the base URL that is appended to image source paths when
	 * loading images.</p>
	 * 
	 * @see #setBaseUrl()
	 */
	public function baseUrl():String {
		return m_baseUrl;
	}
	
	/**
	 * <p>Sets the base URL that is appended to image source paths when
	 * loading images to <code>aString</code>.</p>
	 * 
	 * @see baseUrl()
	 */
	public function setBaseUrl(aString:String):Void {
		m_baseUrl = aString;
	}
	
	//******************************************************
	//*                  Loading images
	//******************************************************
	
	/**
	 * Returns <code>true</code> if the image loader is currently loading
	 * images.
	 */
	public function isLoading():Boolean {
		return m_isLoading;
	}
	
	/**
	 * <p>Begins loading the images as described in the <code>imageInfo</code>
	 * array.</p>
	 * 
	 * <p>Each element of <code>imageInfo</code> should be structured as 
	 * follows:<br/>
	 * <code>{src:String[, name:String]}</code>
	 * </p>
	 * 
	 * <p>If {@link #isLoading()} is <code>true</code>, images will not be 
	 * loaded.</p>
	 */
	public function loadImages(imageInfo:NSArray):Void {
		if (isLoading()) {
			return;
		}
		m_isLoading = true;
		m_loadedImages = NSArray.array();
		m_total = imageInfo.count();
		m_loadCnt = 0;
		
		//
		// Begin loading the images
		//
		var base:String = baseUrl();
		var arr:Array = imageInfo.internalList();
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var img:NSImage = new NSImage();
			img.initWithContentsOfURL(base + arr[i].src);
			
			//
			// Set name
			//
			if (arr[i].name != undefined) {
				img.setName(arr[i].name);
			}
			
			//
			// Register for load notification
			//
			m_nc.addObserverSelectorNameObject(this, "imageDidLoad",
				NSImage.NSImageDidLoadNotification, 
				img);
		}
	}
	
	/**
	 * Fired when an image finishes loading.
	 */
	private function imageDidLoad(ntf:NSNotification):Void {
		
		m_loadedImages.addObject(ntf.object);
		
		//
		// Remove observer
		//
		m_nc.removeObserverNameObject(this, NSImage.NSImageDidLoadNotification,
			ntf.object);
			
		//
		// Check if we're complete
		//
		if (++m_loadCnt == m_total) {
			m_isLoading = false;
			
			//
			// Post notification
			//
			var userInfo:NSDictionary = NSDictionary.dictionary();
			userInfo.setObjectForKey(m_loadedImages, "Images");
			m_nc.postNotificationWithNameObjectUserInfo(
				ImagesDidLoadNotification,
				this,
				userInfo);
		}
	}
	
	//******************************************************
	//*                Getting the instance
	//******************************************************
	
	/**
	 * Returns the image loader instance.
	 */
	public static function instance():ImageLoader {
		if (g_instance == null) {
			g_instance = (new ImageLoader()).init();
		}
		
		return g_instance;
	}
}