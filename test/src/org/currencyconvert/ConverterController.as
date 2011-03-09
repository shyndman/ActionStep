import org.actionstep.*;
import org.currencyconvert.*;

/**
 * Handles creating the view, and processing it's actions
 *
 * @author	Ben Longoria
 * @version	0.5
 */
class org.currencyconvert.ConverterController extends NSObject {
	
	private var m_converter:Converter;
	private var m_converterView:ConverterView;
	
	/**
	 * --Designated Initializer-- An instance of the class init'd with the Converter model
	 *
	 * @param	converter	Instance of the Converter class
	 * @returns Instance of this class init'd with the Converter model
	 */
	public function initWithModel(converter:Converter):ConverterController {
		
		super.init();
		
		m_converter = converter;
		//create view
		m_converterView	= (new ConverterView()).initWithController(this);
		
		return this;
	}
	
	/**
	 * Init'd without creating the view
	 *
	 * @param	converterView	View class
	 * @returns Instance of this class init'd with the Converter model
	 */
	public function initWithView(converterView:ConverterView):ConverterController {
		super.init();
		
		m_converter = Converter((new Converter()).init());
		m_converterView = converterView;
		
		return this;
	}
	
	/**
	 * Take care of original init, handle by calling designated initializer
	 */
	public function init():ConverterController {
		m_converter = Converter((new Converter()).init());
		return initWithModel(m_converter);
	}
	
	/**
	 * Passes this on to the call on to Converter instance
	 *
	 * @param	amt	Amount to convert.
	 * @param	rate	Rate at which to convert.
	 */
	public function convertAmount(amt:Number, rate:Number):Void {
		
		var convertedAmount:Number = m_converter.convertAmount(amt, rate);
				
		m_converterView.setTotal(convertedAmount);
		
	}
	
}
