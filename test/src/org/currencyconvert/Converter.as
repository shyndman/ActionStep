import org.actionstep.*;

/**
 * This is the model class for the CurrencyConverter
 *
 * @author	Ben Longoria
 * @version	0.5
 */
class org.currencyconvert.Converter extends NSObject {
	
	/**
	 * Converts the currency
	 *
	 * @param	amt_p	Amount to convert.
	 * @param	rate_p	Rate at which to convert.
	 * @returns The converted amount
	 */
	public function convertAmount(amt:Number, rate:Number):Number {
		return amt * rate;
	}

}
