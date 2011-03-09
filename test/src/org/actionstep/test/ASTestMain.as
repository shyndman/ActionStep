
/* See LICENSE for copyright and terms of use */
 
import org.actionstep.ASDebugger;
import org.actionstep.test.ASTestSheet;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.plastic.ASPlasticTheme;
import org.actionstep.test.ASTestWindowStyles;

/**
 * This is the main entry point for all test classes.
 */
class org.actionstep.test.ASTestMain { 

  public static function main() {
    Stage.align="LT";
    Stage.scaleMode="noScale";
    ASDebugger.setLevel(ASDebugger.DEBUG);
	ASTheme.setCurrent(new ASPlasticTheme());
	
    try
    { 
      ASTestSheet.test();; // Change this line to run other tests    
    }
    catch (e:Error)   
    {
      trace(e.message);
    }
  }
}