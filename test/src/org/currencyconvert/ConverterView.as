import org.actionstep.*;
import org.actionstep.layout.ASHBox;
import org.actionstep.layout.ASVBox;
import org.currencyconvert.*;

/**
 * Handles creating the GUI elements and receiving events
 *
 * @author	Ben Longoria
 * @version	0.5
 */
class org.currencyconvert.ConverterView extends NSObject {
	
	public static var BORDER:Number = 5;
	
	public static var ROW_HEIGHT:Number = 22;
	public static var ROW_WIDTH:Number = 150;
	
	private var m_converterController:ConverterController;
	private var m_rateField:NSTextField;
	private var m_dollarField:NSTextField;
	private var m_totalField:NSTextField;
	private var m_convertButton:NSButton;
	
	/**
	 * --Designated Initializer-- Initializes the with the ConverterController class
	 *
	 * @param	converterController	Instance of the ConverterController class.
	 * @returns	An instance of the class init'd with the ConverterController class
	 */
	public function initWithController(converterController:ConverterController):ConverterView {
		
		super.init();
		
		m_converterController = converterController;
		
		//create and set views
		var conWindow:NSWindow;
		var conView:NSView;
		var conForm:NSForm;
		
		//window
		conWindow = (new NSWindow()).initWithContentRectStyleMask(new NSRect(50,50,350,175), NSWindow.NSTitledWindowMask  | NSWindow.NSResizableWindowMask);
		conWindow.setTitle("Currency Converter");
		conView = new NSView();
		conView.initWithFrame(new NSRect(0,0,20,20));
		conWindow.setContentView(conView);
		
		//vbox to hold hboxes
		var vbox:ASVBox = (new ASVBox()).init();
		vbox.setBorder(BORDER);
		conView.addSubview(vbox);
		
		vbox.addView(createExchangeRatePair());
		vbox.addViewWithMinYMargin(createDollarsToConvertPair(), BORDER);
		vbox.addViewWithMinYMargin(createConvertedAmountPair(), BORDER);
		
		//action button
		m_convertButton = (new NSButton()).initWithFrame(new NSRect((ROW_WIDTH*2)-75, (ROW_HEIGHT*3) + (BORDER*4), 80, 20));
		m_convertButton.setTitle("Convert");
		m_convertButton.setTarget(this);
		m_convertButton.setAction("convertCurrency");
		conView.addSubview(m_convertButton);
		
		//tab order
		m_rateField.setNextKeyView(m_dollarField);
		m_dollarField.setNextKeyView(m_totalField);
		m_totalField.setNextKeyView(m_convertButton);
		m_convertButton.setNextKeyView(m_rateField);
		conWindow.setInitialFirstResponder(m_rateField);
		
		
		return this;
	}
	
	/**
	 * Take care of original init, handle by calling designated initializer
	 */
	public function init():ConverterView {
		
		var converterController:ConverterController 
			= (new ConverterController()).initWithView(this);
		
		return initWithController(converterController);
	}
	
	/**
	 * Action for m_convertButton
	 */
	public function convertCurrency():Void {
		
		var amt:Number =  parseFloat(m_dollarField.stringValue());
		var rate:Number = parseFloat(m_rateField.stringValue());
		
		m_converterController.convertAmount(amt, rate);
	}
	
	/**
	 * @returns	Amount in total field
	 */
	public function total():Number {
		return parseFloat(m_totalField.stringValue());
	}
	
	/**
	 * @param	total	Amount after conversion
	 */
	public function setTotal(total:Number):Void {
		m_totalField.setStringValue(total.toString());
		m_totalField.setNeedsDisplay(true);
		trace("m_totalField was set: " + total.toString());
	}
	
	/**
	 * First row
	 */
	private function createExchangeRatePair():NSView {
		var exchangeBox:ASHBox = (new ASHBox()).init();
		
		var exchangeLabel:ASLabel = new ASLabel();
		exchangeLabel.initWithFrame(new NSRect(0,0,ROW_WIDTH,ROW_HEIGHT));
		exchangeLabel.setStringValue("Exchange Rate Per $1:");
		exchangeBox.addView(exchangeLabel);
		
		m_rateField = new NSTextField();
		m_rateField.initWithFrame(new NSRect(160,5,ROW_WIDTH,ROW_HEIGHT));
		m_rateField.setStringValue("0");
		exchangeBox.addView(m_rateField);
		
		return exchangeBox;
	}
	
	/**
	 * Second row
	 */
	private function createDollarsToConvertPair():NSView {
		var convertBox:ASHBox = (new ASHBox()).init();
		
		var convertLabel:ASLabel = new ASLabel();
		convertLabel.initWithFrame(new NSRect(0,0,150,ROW_HEIGHT));
		convertLabel.setStringValue("Dollars to Convert:");
		convertBox.addView(convertLabel);
		
		m_dollarField = new NSTextField();
		m_dollarField.initWithFrame(new NSRect(160,5,ROW_WIDTH,ROW_HEIGHT));
		m_dollarField.setStringValue("0");
		convertBox.addView(m_dollarField);
		
		return convertBox;
	}
	
	/**
	 * Third row
	 */
	private function createConvertedAmountPair():NSView {
		var totalBox:ASHBox = (new ASHBox()).init();
		
		var totalLabel:ASLabel = new ASLabel();
		totalLabel.initWithFrame(new NSRect(0,0,ROW_WIDTH,ROW_HEIGHT));
		totalLabel.setStringValue("Amount in other Currency:");
		totalBox.addView(totalLabel);
		
		m_totalField = new NSTextField();
		m_totalField.initWithFrame(new NSRect(160,5,ROW_WIDTH,ROW_HEIGHT));
		m_totalField.setStringValue("0");
		m_totalField.setEditable(false);
		totalBox.addView(m_totalField);
		
		return totalBox;
	}
	
}
