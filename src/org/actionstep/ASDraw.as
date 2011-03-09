/* See LICENSE for copyright and terms of use */

import org.actionstep.NSPoint;
import org.actionstep.NSRect;

import flash.display.BitmapData;
import flash.geom.Matrix;

/**
 * A collection of useful drawing methods.
 *
 * @author Richard Kilmer
 */
class org.actionstep.ASDraw {

  public static var ANGLE_LEFT_TO_RIGHT:Number =   0;
  public static var ANGLE_TOP_TO_BOTTOM:Number =  90;
  public static var ANGLE_RIGHT_TO_LEFT:Number = 180;
  public static var ANGLE_BOTTOM_TO_TOP:Number = 270;

  public static var DEFAULT_THICKNESS:Number = 0;

  public static var TRACE_FLAG:Boolean = false;

  public static function setTrace(value:Boolean)
  {
    TRACE_FLAG = value;
  }

  /////////////////////////////////////////////////////////////////////////////
  // BOX METHODS
  /////////////////////////////////////////////////////////////////////////////

  public static function fillRect(mc:MovieClip, x:Number, y:Number, width:Number, height:Number, color:Number, alpha:Number) {
    if (color == undefined) return;
    if (alpha == undefined) alpha = 100;
    mc.lineStyle(undefined, 0, 0);
    mc.beginFill(color, alpha);
    mc.moveTo(x,y);
    mc.lineTo(x+width, y);
    mc.lineTo(x+width, y+height);
    mc.lineTo(x, y+height);
    mc.lineTo(x, y);
    mc.endFill();
  }

  public static function fillRectWithRect(mc:MovieClip, rect:NSRect, color:Number, alpha:Number) {
    fillRect(mc, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, color, alpha);
  }

  public static function drawRect(mc:MovieClip, x1:Number, y1:Number, w1:Number, h1:Number, color:Number, alpha:Number, thick:Number) {
    if (color == undefined)
      return;
    if (thick == undefined)
      thick = DEFAULT_THICKNESS;
    if (alpha == undefined)
      alpha = 100;
    mc.lineStyle(thick, color, alpha, true, "normal", "none");
    mc.moveTo(x1,y1);
    mc.lineTo(x1+w1, y1);
    mc.lineTo(x1+w1, y1+h1);
    mc.lineTo(x1, y1+h1);
    mc.lineTo(x1, y1);
  }

  public static function drawRectWithRect(mc:MovieClip, rect:NSRect, color:Number, alpha:Number, thick:Number) {
    drawRect(mc, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, color, alpha, thick);
  }

  //      ------------------      DRAW CURVE      ------------------      //

  public static function drawCurve(mc:MovieClip, thick:Number, color:Number, startX:Number, startY:Number, curveControlX:Number,
                          curveControlY:Number,endX:Number,endY:Number)
  {
    mc.lineStyle(thick,color);
    mc.moveTo(startX,startY);
    mc.curveTo(curveControlX,curveControlY,endX,endY);
  }

  // draw Oval

  public static function drawOval(mc:MovieClip, thick:Number, color:Number, x:Number,y:Number, width:Number,height:Number){
    mc.lineStyle(thick, color);
    mc.moveTo(x,y+height/2);
    mc.curveTo(x,y,x+width/2, y);
    mc.curveTo(x+width,y,x+width, y+height/2);
    mc.curveTo(x+width,y+height, x+width/2, y+height);
    mc.curveTo(x,y+height, x, y+height/2);
  }

  // ---------    FILL OVAL       ------------    //

  public static function fillOval(mc:MovieClip, thick:Number, color:Number, fill:Number, x:Number,y:Number, width:Number,height:Number){
    mc.lineStyle(thick, color);
    mc.moveTo(x,y+height/2);
    mc.beginFill(fill);
    mc.curveTo(x,y,x+width/2, y);
    mc.curveTo(x+width,y,x+width, y+height/2);
    mc.curveTo(x+width,y+height, x+width/2, y+height);
    mc.curveTo(x,y+height, x, y+height/2);
    mc.endFill();
  }

  //      ---------       DRAW CIRCLE-----------  //

  public static function drawCircle(mc:MovieClip, thick:Number, color:Number, r:Number,x:Number,y:Number){
    var styleMaker:Number = 22.5;
    mc.moveTo(x+r,y);
    mc.lineStyle(thick, color);
    var style:Number = Math.tan(styleMaker*Math.PI/180);
    for (var angle:Number=45;angle<=360;angle+=45){
      var endX:Number = r * Math.cos(angle*Math.PI/180);
      var endY:Number = r * Math.sin(angle*Math.PI/180);
      var cX:Number   = endX + r* style * Math.cos((angle-90)*Math.PI/180);
      var cY:Number   = endY + r* style * Math.sin((angle-90)*Math.PI/180);
      mc.curveTo(cX+x,cY+y,endX+x,endY+y);
    }
  }

  // ---------    DRAW FILLED circle, ----------- //

  public static function fillCircle(mc:MovieClip, thick:Number, color:Number, fill:Number, r:Number,x:Number,y:Number){
    var styleMaker:Number = 22.5;
    mc.moveTo(x+r,y);
    mc.lineStyle(thick, color);
    mc.beginFill(fill);
    var style:Number = Math.tan(styleMaker*Math.PI/180);
    for (var angle:Number=45;angle<=360;angle+=45){
      var endX:Number = r * Math.cos(angle*Math.PI/180);
      var endY:Number = r * Math.sin(angle*Math.PI/180);
      var cX:Number   = endX + r* style * Math.cos((angle-90)*Math.PI/180);
      var cY:Number   = endY + r* style * Math.sin((angle-90)*Math.PI/180);
      mc.curveTo(cX+x,cY+y,endX+x,endY+y);
    }
    mc.endFill();
  }

  //      ---------       DRAW helix shape        -----------     //

  public static function drawHelix(mc:MovieClip, thick:Number, color:Number, r:Number,x:Number,y:Number,styleMaker:Number){
    mc.moveTo(x+r,y);
    mc.lineStyle(thick, color);
    var style:Number = Math.tan(styleMaker*Math.PI/180);
    for (var angle:Number=45;angle<=360;angle+=45){
      var endX:Number = r * Math.cos(angle*Math.PI/180);
      var endY:Number = r * Math.sin(angle*Math.PI/180);
      var cX:Number   = endX + r* style * Math.cos((angle-90)*Math.PI/180);
      var cY:Number   = endY + r* style * Math.sin((angle-90)*Math.PI/180);
      mc.curveTo(cX+x,cY+y,endX+x,endY+y);
    }
  }

  // ---------    DRAW FILLED helix SHAPE, -----------    //

  public static function fillHelix(mc:MovieClip, thick:Number, color:Number, fill:Number, r:Number,x:Number,y:Number,styleMaker:Number){
    mc.moveTo(x+r,y);
    mc.lineStyle(thick, color);
    mc.beginFill(fill);
    var style:Number = Math.tan(styleMaker*Math.PI/180);
    for (var angle:Number=45;angle<=360;angle+=45){
      var endX:Number = r * Math.cos(angle*Math.PI/180);
      var endY:Number = r * Math.sin(angle*Math.PI/180);
      var cX:Number   = endX + r* style * Math.cos((angle-90)*Math.PI/180);
      var cY:Number   = endY + r* style * Math.sin((angle-90)*Math.PI/180);
      mc.curveTo(cX+x,cY+y,endX+x,endY+y);
    }
    mc.endFill();
  }

  //      --------------  DRAW GRADIENT SHAPE     --------------  //

  public static function drawGradientShape(mc:MovieClip, thick:Number, color:Number, r:Number,x:Number,y:Number,styleMaker:Number,
      col1:Number,col2:Number,fa1:Number,fa2:Number,
      matrixX:Number,matrixY:Number,matrixW:Number,
      matrixH:Number){
    mc.lineStyle(thick, color);
    mc.moveTo(x+r,y);
    var colors:Array = [col1 ,col2];
    var alphas:Array = [ fa1, fa2 ];
    var ratios:Array = [ 7, 0xFF ];
    var matrix:Object = { matrixType:"box", x:matrixX,
      y:matrixY, w:matrixW, h:matrixH,
      r:(45/180)*Math.PI };
    beginLinearGradientFill(mc,colors,alphas,ratios,matrix);
    var style:Number = Math.tan(styleMaker*Math.PI/180);
    for (var angle:Number=45;angle<=360;angle+=45){
      var endX:Number = r * Math.cos(angle*Math.PI/180);
      var endY:Number = r * Math.sin(angle*Math.PI/180);
      var cX:Number   = endX + r* style * Math.cos((angle-90)*Math.PI/180);
      var cY:Number   = endY + r* style * Math.sin((angle-90)*Math.PI/180);
      mc.curveTo(cX+x,cY+y,endX+x,endY+y);
    }
    mc.endFill();
  }

  //      -----------             DRAW HEXAGON    ----------      //

  public static function drawHexagon(mc:MovieClip, thick:Number, color:Number, hexRadius:Number, startX:Number, startY:Number){
    var sideC:Number=hexRadius;
    var sideA:Number = 0.5 * sideC;
    var sideB:Number=Math.sqrt((hexRadius*hexRadius)
                                     - (0.5*hexRadius)* (0.5*hexRadius));
    mc.lineStyle(thick,color,100);
    mc.moveTo(startX,startY);
    mc.lineTo(startX,sideC+ startY);
    mc.lineTo(sideB+startX,startY+sideA+sideC);             // bottom point
    mc.lineTo(2*sideB + startX , startY + sideC);
    mc.lineTo(2*sideB + startX , startY);
    mc.lineTo(sideB + startX, startY - sideA);
    mc.lineTo(startX, startY);
  };


  public static function fillHexagon(mc:MovieClip, thick:Number, color:Number, fill:Number, hexRadius:Number, startX:Number, startY:Number){
    var sideC:Number=hexRadius;
    var sideA:Number = 0.5 * sideC;
    var sideB:Number=Math.sqrt((hexRadius*hexRadius)
                                    - (0.5*hexRadius)* (0.5*hexRadius));
    mc.lineStyle(thick,color,100);
    mc.beginFill(fill);
    mc.moveTo(startX,startY);
    mc.lineTo(startX,sideC+ startY);
    mc.lineTo(sideB+startX,startY+sideA+sideC);             // bottom point
    mc.lineTo(2*sideB + startX , startY + sideC);
    mc.lineTo(2*sideB + startX , startY);
    mc.lineTo(sideB + startX, startY - sideA);
    mc.lineTo(startX, startY);
    mc.endFill();
  };

  public static function drawRoundedRect(mc:MovieClip, x:Number, y:Number, w:Number, h:Number, cornerRadius:Number) {
  	// ==============
  	// mc.drawRect() - by Ric Ewing (ric@formequalsfunction.com) - version 1.1 - 4.7.2002
  	//
  	// x, y = top left corner of rect
  	// w = width of rect
  	// h = height of rect
  	// cornerRadius = [optional] radius of rounding for corners (defaults to 0)
  	// ==============
  	if (arguments.length<4) {
  		return;
  	}
  	// if the user has defined cornerRadius our task is a bit more complex. :)
  	if (cornerRadius>0) {
  		// init vars
  		var theta:Number, angle:Number, cx:Number, cy:Number, px:Number, py:Number;
  		// make sure that w + h are larger than 2*cornerRadius
  		if (cornerRadius>Math.min(w, h)/2) {
  			cornerRadius = Math.min(w, h)/2;
  		}
  		// theta = 45 degrees in radians
  		theta = Math.PI/4;
  		// draw top line
  		mc.moveTo(x+cornerRadius, y);
  		mc.lineTo(x+w-cornerRadius, y);
  		//angle is currently 90 degrees
  		angle = -Math.PI/2;
  		// draw tr corner in two parts
  		cx = x+w-cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		cy = y+cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		px = x+w-cornerRadius+(Math.cos(angle+theta)*cornerRadius);
  		py = y+cornerRadius+(Math.sin(angle+theta)*cornerRadius);
  		mc.curveTo(cx, cy, px, py);
  		angle += theta;
  		cx = x+w-cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		cy = y+cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		px = x+w-cornerRadius+(Math.cos(angle+theta)*cornerRadius);
  		py = y+cornerRadius+(Math.sin(angle+theta)*cornerRadius);
  		mc.curveTo(cx, cy, px, py);
  		// draw right line
  		mc.lineTo(x+w, y+h-cornerRadius);
  		// draw br corner
  		angle += theta;
  		cx = x+w-cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		cy = y+h-cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		px = x+w-cornerRadius+(Math.cos(angle+theta)*cornerRadius);
  		py = y+h-cornerRadius+(Math.sin(angle+theta)*cornerRadius);
  		mc.curveTo(cx, cy, px, py);
  		angle += theta;
  		cx = x+w-cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		cy = y+h-cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		px = x+w-cornerRadius+(Math.cos(angle+theta)*cornerRadius);
  		py = y+h-cornerRadius+(Math.sin(angle+theta)*cornerRadius);
  		mc.curveTo(cx, cy, px, py);
  		// draw bottom line
  		mc.lineTo(x+cornerRadius, y+h);
  		// draw bl corner
  		angle += theta;
  		cx = x+cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		cy = y+h-cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		px = x+cornerRadius+(Math.cos(angle+theta)*cornerRadius);
  		py = y+h-cornerRadius+(Math.sin(angle+theta)*cornerRadius);
  		mc.curveTo(cx, cy, px, py);
  		angle += theta;
  		cx = x+cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		cy = y+h-cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		px = x+cornerRadius+(Math.cos(angle+theta)*cornerRadius);
  		py = y+h-cornerRadius+(Math.sin(angle+theta)*cornerRadius);
  		mc.curveTo(cx, cy, px, py);
  		// draw left line
  		mc.lineTo(x, y+cornerRadius);
  		// draw tl corner
  		angle += theta;
  		cx = x+cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		cy = y+cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		px = x+cornerRadius+(Math.cos(angle+theta)*cornerRadius);
  		py = y+cornerRadius+(Math.sin(angle+theta)*cornerRadius);
  		mc.curveTo(cx, cy, px, py);
  		angle += theta;
  		cx = x+cornerRadius+(Math.cos(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		cy = y+cornerRadius+(Math.sin(angle+(theta/2))*cornerRadius/Math.cos(theta/2));
  		px = x+cornerRadius+(Math.cos(angle+theta)*cornerRadius);
  		py = y+cornerRadius+(Math.sin(angle+theta)*cornerRadius);
  		mc.curveTo(cx, cy, px, py);
  	} else {
  		// cornerRadius was not defined or = 0. This makes it easy.
  		mc.moveTo(x, y);
  		mc.lineTo(x+w, y);
  		mc.lineTo(x+w, y+h);
  		mc.lineTo(x, y+h);
  		mc.lineTo(x, y);
  	}
  }



 /**
  * The following methods are the new draw methods.
  * The methods above this are being phased out.
  */

  ///////////////////////////////////////////
  // BASIC DRAWING METHODS

  public static function drawLine(mc:MovieClip, startX:Number, startY:Number, endX:Number, endY:Number, color:Number, alpha:Number, thick:Number) {
    if (alpha == undefined) {
      alpha = 100;
    }
    if (thick == undefined) {
      thick = DEFAULT_THICKNESS;
    }
    mc.lineStyle(thick, color, alpha, true, "normal", "none");
    mc.moveTo( startX,  startY);
    mc.lineTo(   endX,    endY);
  }

  public static function drawLineWithPoint(mc:MovieClip, start:NSPoint, end:NSPoint, color:Number, alpha:Number, thick:Number) {
    if (alpha == undefined) {
      alpha = 100;
    }
    if (thick == undefined) {
      thick = DEFAULT_THICKNESS;
    }
    mc.lineStyle(thick, color, alpha, true, "normal", "none");
    mc.moveTo( start.x,  start.y);
    mc.lineTo(   end.x,    end.y);
  }

////    //used to fix bad diagonal line drawing. draws a line using a fill, for precise pixels and colors.
////    public static function drawFillLine(mc:MovieClip, startX:Number, startY:Number, endX:Number, endY:Number, color:Number){
////      drawLineSimple(mc, color, startX, endX, startY, endY);
////    }
////

  public static function drawDashedRectWithRect(mc:MovieClip,
      rect:NSRect, dashLength:Number, dashGap:Number):Void {
    drawDash(mc, rect.origin.x, rect.origin.y, rect.maxX(), rect.origin.y, dashLength, dashGap);
    drawDash(mc, rect.maxX(), rect.origin.y, rect.maxX(), rect.maxY(), dashLength, dashGap);
    drawDash(mc, rect.maxX(), rect.maxY(), rect.origin.x, rect.maxY(), dashLength, dashGap);
    drawDash(mc, rect.origin.x, rect.maxY(), rect.origin.x, rect.origin.y, dashLength, dashGap);
  }

  /**
   * <p>Draws dotted (or dashed) lines from the <code>start</code> point
   * to the <code>end</code> point.</p>
   *
   * <p>{@link MovieClip#lineStyle()} is never called in this method, so you
   * can choose to specify a line style yourself before calling this.</p>
   *
   * <p>To make a dotted line, specify a <code>dashLength</code> of between
   * <code>.5</code> and <code>.1</code>.</p>
   *
   * @version 1.2
   * @author Ric Ewing {@link ric@formequalsfunction.com }
   */
  public static function drawDashWithPoints(mc:MovieClip,
      start:NSPoint, end:NSPoint, dashLength:Number, dashGap:Number):Void {
    drawDash(mc, start.x, start.y, end.x, end.y, dashLength, dashGap);
  }

  /**
   * <p>Draws dotted (or dashed) lines.</p>
   *
   * <p>{@link MovieClip#lineStyle()} is never called in this method, so you
   * can choose to specify a line style yourself before calling this.</p>
   *
   * <p>To make a dotted line, specify a <code>dashLength</code> of between
   * <code>.5</code> and <code>.1</code>.</p>
   *
   * @version 1.2
   * @author Ric Ewing {@link ric@formequalsfunction.com }
   */
  public static function drawDash(mc:MovieClip,
      startX:Number, startY:Number, endX:Number, endY:Number,
      dashLength:Number, dashGap:Number):Void {

    // init vars
    var seglength:Number, deltax:Number, deltay:Number, delta:Number,
      segs:Number, cx:Number, cy:Number, radians:Number;

    // calculate the legnth of a segment
    seglength = dashLength + dashGap;
    // calculate the length of the dashed line
    deltax = endX - startX;
    deltay = endY - startY;
    delta = Math.sqrt((deltax * deltax) + (deltay * deltay));
    // calculate the number of segments needed
    segs = Math.floor(Math.abs(delta / seglength));
    // get the angle of the line in radians
    radians = Math.atan2(deltay, deltax);
    // start the line here
    cx = startX;
    cy = startY;
    // add these to cx, cy to get next seg start
    deltax = Math.cos(radians) * seglength;
    deltay = Math.sin(radians) * seglength;
    // loop through each seg
    for (var n:Number = 0; n < segs; n++) {
      mc.moveTo(cx, cy);
      mc.lineTo(cx + Math.cos(radians) * dashLength, cy + Math.sin(radians) * dashLength);
      cx += deltax;
      cy += deltay;
    }
    // handle last segment as it is likely to be partial
    mc.moveTo(cx,cy);
    delta = Math.sqrt((endX - cx) * (endX - cx) + (endY-cy) * (endY - cy));
    if(delta > dashLength){
      // segment ends in the gap, so draw a full dash
      mc.lineTo(cx + Math.cos(radians) * dashLength, cy + Math.sin(radians) * dashLength);
    } else if(delta > 0) {
      // segment is shorter than dash so only draw what is needed
      mc.lineTo(cx + Math.cos(radians) * delta, cy + Math.sin(radians) * delta);
    }
    // move the pen to the end position
    mc.moveTo(endX, endY);
  }

  //SHAPES

    public static function drawShape(mc:MovieClip, xyArrays:Array, color:Number)
    {
       //NSPoint.ZeroPoint doesn't seem to work. why'
      drawShapeWithOrigin(mc, xyArrays, color, new NSPoint(0,0));
    }

    public static function drawShapeWithOrigin(mc:MovieClip, xyArrays:Array, color:Number, origin:NSPoint)
    {
      mc.lineStyle(DEFAULT_THICKNESS, color, 100);
      drawShapeShared(mc, xyArrays,origin);
    }

    public static function fillShape(mc:MovieClip, xyArrays:Array, color:Number)
    {
      fillShapeWithOrigin(mc, xyArrays, color, new NSPoint(0,0));
    }

    public static function fillShapeWithOrigin(mc:MovieClip, xyArrays:Array, color:Number, origin:NSPoint)
    {
      mc.lineStyle(DEFAULT_THICKNESS, color, 100);
      mc.beginFill(color,100);
      drawShapeShared(mc, xyArrays, origin);
      mc.endFill();
    }

    public static function fillShapeWithOriginAlpha(mc:MovieClip, xyArrays:Array, color:Number, origin:NSPoint, alpha:Number)
    {
      mc.lineStyle(DEFAULT_THICKNESS, color, alpha);
      mc.beginFill(color,alpha);
      drawShapeShared(mc, xyArrays, origin);
      mc.endFill();
    }

    public static function fillShapeWithAlpha(mc:MovieClip, xyArrays:Array, color:Number, alpha:Number)
    {
      mc.lineStyle(DEFAULT_THICKNESS, color, alpha);
      mc.beginFill(color,alpha);
      drawShapeShared(mc, xyArrays, new NSPoint(0,0));
      mc.endFill();
    }

    public static function fillShapeWithoutBorder(mc:MovieClip, xyArrays:Array, color:Number)
    {
      fillShapeWithoutBorderWithOrigin(mc, xyArrays, color, new NSPoint(0,0));
    }

    public static function fillShapeWithoutBorderWithOrigin(mc:MovieClip, xyArrays:Array, color:Number, origin:NSPoint)
    {
      mc.lineStyle(undefined, 0, 100);
      mc.beginFill(color,100);
      drawShapeShared(mc, xyArrays, origin);
      mc.endFill();
    }

    private static function drawShapeShared(mc:MovieClip, xyArrays:Array, origin:NSPoint)
    {
      var startX:Number = Number(xyArrays[0][0]);
      var startY:Number = Number(xyArrays[0][1]);

      mc.moveTo(startX+origin.x,startY+origin.y);
      for (var i:Number = 1; i < xyArrays.length; i++)
      {
        var x:Number = Number(xyArrays[i][0]) + origin.x;
        var y:Number = Number(xyArrays[i][1]) + origin.y;
        mc.lineTo(x,y);
      }
      mc.lineTo(startX+origin.x,startY+origin.y);
    }

  // END BASIC DRAWING METHODS
  ///////////////////////////////////////////


  ///////////////////////////////////////////
  // OUTLINE RECT METHODS

    public static function outlineRectWithRectExcludingRect(mc:MovieClip, rect:NSRect, exclude:NSRect, colors:Array) {
      var x:Number = rect.origin.x;
      var y:Number = rect.origin.y;
      var width:Number = rect.size.width;
      var height:Number = rect.size.height;
      colors = getArrayOfFour(colors);
      var alphas:Array = buildArray(colors.length, 100);

      var iRect:NSRect = rect.intersectionRect(exclude);
      var excludeTop:Boolean = true;
      if (iRect.maxY() == rect.maxY()) {
        excludeTop = false;
      }

      //change width and height so that the total width/height, including line thickness is the given width/height.
      var x2:Number = x + width  -1;
      var y2:Number = y + height -1;
      var lineThickness:Number = DEFAULT_THICKNESS;

      mc.lineStyle(lineThickness, colors[0], alphas[0], true, "normal", "none");
      mc.moveTo( x,  y);
      if (excludeTop) {
        mc.lineTo(iRect.minX(), y);
        mc.moveTo(iRect.maxX(), y);
      }
      mc.lineTo(x2,  y);

      //TODO Why the eff won't the bottom right pixel draw?
      mc.lineStyle(lineThickness, colors[1], alphas[1]);
      mc.lineTo(x2, y2);


      mc.lineStyle(lineThickness, colors[2], alphas[2]);
      if (!excludeTop) {
        mc.lineTo(iRect.maxX(), y2);
        mc.moveTo(iRect.minX(), y2);
      }
      mc.lineTo( x, y2);

      mc.lineStyle(lineThickness, colors[3], alphas[3]);
      mc.lineTo( x,  y);

      // need to draw the bottom right pixel separately for some reason.
      // I can't get any line to draw there, so I'm using the 'pixel' method, which is actually a fill.
    }

    public static function outlineRectWithRect(mc:MovieClip, rect:NSRect, colors:Array){
      outlineRect(mc, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, colors);
    }

    public static function outlineRectWithAlphaRect(mc:MovieClip, rect:NSRect, colors:Array, alphas:Array){
      outlineRectWithAlpha(mc, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, colors, alphas);
    }

    public static function outlineRect(mc:MovieClip, x:Number, y:Number, width:Number, height:Number, colors:Array){
      var alphas:Array = buildArray(colors.length, 100);
      outlineRectWithAlpha(mc, x, y, width, height, colors, alphas);
    }

    /**
     * Draws an rectangle outline in <code>mc</code> colored by the numeric
     * color values contained in <code>colors</code>.
     * <code>thickness</code> is the thickness of the line in pixels.
     */
    public static function outlineRectWithThickness(mc:MovieClip,
        x:Number, y:Number, width:Number, height:Number,
        colors:Array, thickness:Number):Void {
      outlineRectWithAlphaThickness(mc, x, y, width, height, colors,
      buildArray(colors.length, 100), thickness);
    }

    public static function outlineRectWithAlpha(mc:MovieClip, x:Number, y:Number, width:Number, height:Number, colors:Array, alphas:Array){
      outlineRectWithAlphaThickness(mc, x, y, width, height, colors, alphas, 1);
    }

    /**
     * Draws an rectangle outline in <code>mc</code> colored by the numeric
     * color values contained in <code>colors</code> who's transparency is
     * determined by the numeric values in <code>alphas</code>.
     * <code>thickness</code> is the thickness of the line in pixels.
     */
    public static function outlineRectWithAlphaThickness(mc:MovieClip,
        x:Number, y:Number, width:Number, height:Number,
        colors:Array, alphas:Array, thickness:Number):Void {

      colors = getArrayOfFour(colors);
      alphas = getArrayOfFour(alphas);

      //change width and height so that the total width/height, including line thickness is the given width/height.
      var x2:Number = x + width  - thickness;
      var y2:Number = y + height - thickness;

      mc.lineStyle(thickness, colors[0], alphas[0], true, "normal", "none");
      mc.moveTo(x, y);
      mc.lineTo(x2, y);

      mc.lineStyle(thickness, colors[1], alphas[1], true, "normal", "none");
      mc.lineTo(x2, y2);

      mc.lineStyle(thickness, colors[2], alphas[2], true, "normal", "none");
      mc.lineTo(x, y2);

      mc.lineStyle(thickness, colors[3], alphas[3], true, "normal", "none");
      mc.lineTo(x, y);
    }

  // END OUTLINE RECT METHODS
  ///////////////////////////////////////////


  ///////////////////////////////////////////
  // CORNER RECT METHODS

  //SOLIDS
    public static function solidCornerRectWithRect(mc:MovieClip, rect:NSRect, corner:Number, color:Number){
      solidCornerRect(mc, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, corner, color);
    }

    public static function solidCornerRectWithAlphaRect(mc:MovieClip, rect:NSRect, corner:Number, color:Number, alpha:Number){
      solidCornerRectWithAlpha(mc, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, corner, color, alpha);
    }

    public static function solidCornerRect(mc:MovieClip, x:Number, y:Number, width:Number, height:Number, corner:Number, color:Number){
      var alpha:Number = 100;
      solidCornerRectWithAlpha(mc, x, y, width, height, corner, color, alpha);
    }

    public static function solidCornerRectWithAlpha(mc:MovieClip, x:Number, y:Number, width:Number, height:Number, corner:Number, color:Number, alpha:Number){
//      var cornerSize = 1;
      mc.lineStyle(undefined, 0, 100);
      mc.beginFill(color,alpha);
      cornerRectWithAlpha(mc, x, y, width, height, corner);
      mc.endFill();
    }

    //PATTERN

    /**
     * Draws <code>pattern</code> on <code>mc</code> in the area defined by
     * <code>rect</code> and <code>corner</code>. The pattern will repeat.
     */
    public static function patternCornerRectWithRect(mc:MovieClip, rect:NSRect,
        corner:Number, pattern:BitmapData):Void {
      patternCornerRect(mc,
        rect.origin.x, rect.origin.y, rect.size.width, rect.size.height,
        corner, pattern);
    }

    /**
     * Draws <code>pattern</code> on <code>mc</code> in the area defined by
     * <code>x</code>, <code>y</code>, <code>width</code>, <code>height</code>
     * and <code>corner</code>. The pattern will repeat.
     */
    public static function patternCornerRect(mc:MovieClip, x:Number, y:Number,
        width:Number, height:Number, corner:Number, pattern:BitmapData):Void {
      patternCornerRectWithRepeat(mc, x, y, width, height, corner, pattern, true);
    }

    /**
     * Draws <code>pattern</code> on <code>mc</code> in the area defined by
     * <code>rect</code> and <code>corner</code>. The pattern will repeat if
     * <code>flag</code> is <code>true</code>.
     */
    public static function patternCornerRectWithRectRepeat(mc:MovieClip,
        rect:NSRect, corner:Number,
        pattern:BitmapData, flag:Boolean):Void {
      patternCornerRectWithRepeat(mc,
        rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, corner,
        pattern, flag);
    }

    /**
     * Draws <code>pattern</code> on <code>mc</code> in the area defined by
     * <code>x</code>, <code>y</code>, <code>width</code>, <code>height</code>
     * and <code>corner</code>. The pattern will repeat if <code>flag</code>
     * is <code>true</code>.
     */
    public static function patternCornerRectWithRepeat(mc:MovieClip, x:Number,
        y:Number, width:Number, height:Number, corner:Number,
        pattern:BitmapData, flag:Boolean):Void {
      patternCornerRectWithRepeatMatrix(mc, x, y, width, height, corner,
        pattern, flag, null);
    }

    /**
     * Draws <code>pattern</code> on <code>mc</code> in the area defined by
     * <code>rect</code> and <code>corner</code>. The pattern will repeat if
     * <code>flag</code> is <code>true</code>. <code>matrix</code> defines
     * transformations that will be applied to the pattern.
     *
     * @see MovieClip#beginBitmapFill()
     */
    public static function patternCornerRectWithRectRepeatMatrix(mc:MovieClip,
        rect:NSRect, corner:Number, pattern:BitmapData, flag:Boolean,
        matrix:Matrix):Void {
      patternCornerRectWithRepeatMatrix(mc,
        rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, corner,
        pattern, flag, matrix);
    }

    /**
     * Draws <code>pattern</code> on <code>mc</code> in the area defined by
     * <code>x</code>, <code>y</code>, <code>width</code>, <code>height</code>
     * and <code>corner</code>. The pattern will repeat if <code>flag</code>
     * is <code>true</code>. <code>matrix</code> defines transformations that
     * will be applied to the pattern.
     *
     * @see MovieClip#beginBitmapFill()
     */
    public static function patternCornerRectWithRepeatMatrix(mc:MovieClip,
        x:Number, y:Number, width:Number, height:Number, corner:Number,
        pattern:BitmapData, flag:Boolean, matrix:Matrix):Void {
      if (flag == undefined) {
        flag = true;
      }
      mc.lineStyle(undefined, 0, 100);
      mc.beginBitmapFill(pattern, matrix, flag);
      cornerRectWithAlpha(mc, x, y, width, height, corner);
      mc.endFill();
    }

    //OUTLINES
    public static function outlineCornerRectWithRect(mc:MovieClip, rect:NSRect, corner:Number, color:Number){
      outlineCornerRect(mc, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, corner, color);
    }

    public static function outlineCornerRectWithAlphaRect(mc:MovieClip, rect:NSRect, corner:Number, color:Number, alpha:Number, thick:Number){
      outlineCornerRectWithAlpha(mc, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, corner, color, alpha, thick);
    }

    public static function outlineCornerRect(mc:MovieClip, x:Number, y:Number, width:Number, height:Number, corner:Number, color:Number){
      var alpha:Number = 100;
      outlineCornerRectWithAlpha(mc, x, y, width, height, corner, color, alpha);
    }

    public static function outlineCornerRectWithAlpha(mc:MovieClip, x:Number, y:Number, width:Number, height:Number, corner:Number, color:Number, alpha:Number, thick:Number){
	    if (thick == undefined)
	      thick = DEFAULT_THICKNESS;
      mc.lineStyle(thick, color, alpha);
      cornerRectWithAlpha(mc, x, y, width, height, corner);
    }

    private static function cornerRectWithAlpha(mc:MovieClip, x:Number, y:Number, width:Number, height:Number, cornerSize:Number){
      mc.moveTo(x+cornerSize      ,y);
      mc.lineTo(x+width-cornerSize,y);
      mc.lineTo(x+width           ,y+cornerSize);
      mc.lineTo(x+width           ,y+height-cornerSize);
      mc.lineTo(x+width-cornerSize,y+height);
      mc.lineTo(x+cornerSize      ,y+height);
      mc.lineTo(x                 ,y+height-cornerSize);
      mc.lineTo(x                 ,y+cornerSize);
      mc.lineTo(x+cornerSize      ,y);
    }

  // END SOLID CORNER RECT METHODS
  ///////////////////////////////////////////

  ///////////////////////////////////////////
  // GRADIENT RECT METHODS
  //
  //I think I should make versions of these methods with NSrects instead of x,y,w,h as well.
  //for now naming it 'WithRect' to imply that the gradient should also be a rect
  //TODO decide on a documentation format for these methods.
  //currently using WITH to specify additional params, and then listing params alphabetically.
  //Maybe that should be the order as well?
  //-gradientRectWithAlpha
  //this one uses no outline since they are rarely a single color in our skins.
  //this one will also uses no alpha just to keep things simple. for now it's in.
  //this one makes the matrix the same size as the rect, again to be simple.
  //this one takes an angel, a color array and a ratio array to keep things flexible.
  //
    public static function gradientRectWithRect(mc:MovieClip, rect:NSRect, angle:Number, colors:Array, ratios:Array){
      gradientRect(mc, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, angle, colors, ratios);
    }

    public static function gradientRectWithAlphaRect(mc:MovieClip, rect:NSRect, angle:Number, colors:Array, ratios:Array, alphas:Array){
      gradientRectWithAlpha(mc, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, angle, colors, ratios, alphas);
    }

    public static function gradientRect(mc:MovieClip, x:Number, y:Number, width:Number, height:Number,
                                        angle:Number, colors:Array, ratios:Array){
      var alphas:Array = buildArray(colors.length, 100);
      gradientRectWithAlpha(mc, x, y, width, height, angle, colors, ratios, alphas);
    }

    public static function gradientRectWithAlpha(mc:MovieClip, x:Number, y:Number, width:Number, height:Number,
                                        angle:Number, colors:Array, ratios:Array, alphas:Array){

//TODO do this calculation so that the matrixRect contains the rotated rect passed in.
//     too complex for right now.
//    var radians:Number = getRadiansFromAngle(angle);
			//the size of the gradient has to be adjusted for the angle or the corners will be padded.
			//TODO this may need to be an optional calculation
//		  var gradientHeight:Number = Math.sqrt(height*height + width*width);


      var matrix:Object = getMatrix(new NSRect(x, y, width, height), angle);
      var actualRatios:Array = getActualRatios(ratios);

      mc.lineStyle(undefined, 0, 100);
      beginLinearGradientFill(mc,colors,alphas,actualRatios,matrix);
      mc.moveTo(x,y);
      mc.lineTo(x+width, y);
      mc.lineTo(x+width, y+height);
      mc.lineTo(x, y+height);
      mc.lineTo(x, y);
      mc.endFill();
    }
  // END GRADIENT RECT METHODS
  ///////////////////////////////////////////


  ///////////////////////////////////////////
  // DRAW ELLIPSE METHODS
  //
    public static function gradientEllipseWithRect(mc:MovieClip, rect:NSRect, colors:Array, ratios:Array){
      gradientEllipse(mc, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, colors, ratios);
    }

    public static function gradientEllipseWithAlphaRect(mc:MovieClip, rect:NSRect, colors:Array, ratios:Array, alphas:Array){
      gradientEllipseWithAlpha(mc, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, colors, ratios, alphas);
    }

    public static function gradientEllipse(mc:MovieClip, x:Number, y:Number, width:Number, height:Number,
                                           colors:Array, ratios:Array){
      var alphas:Array = buildArray(colors.length, 100);
      gradientEllipseWithAlpha(mc, x, y, width, height, colors, ratios, alphas);
    }

    //top-left with diameters. not center with radii.
    public static function gradientEllipseWithAlpha(mc:MovieClip, x:Number, y:Number, width:Number, height:Number,
                                                    colors:Array, ratios:Array, alphas:Array){
      var rect:NSRect = new NSRect(x, y, width, height);
      var matrix:Object = getMatrix(rect);
      var actualRatios:Array = getActualRatios(ratios);

      mc.lineStyle(undefined, 0, 100);
      beginRadialGradientFill(mc,colors,alphas,actualRatios,matrix);
      drawEllipse(mc, x, y, width, height);
      mc.endFill();
    }

    public static function drawEllipseWithRect(mc:MovieClip, rect:NSRect):Void {
    	drawEllipse(mc, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    }

    //taken from AcionScript cookbook's DrawingMethods.as (modified the param order)
    //the original used center origin and radius. this one uses top-left origin and width/height.
    public static function drawEllipse(mc:MovieClip, xTopLeft:Number, yTopLeft:Number, width:Number, height:Number) {
      var radiusRect:NSRect = getRadiusRect(new NSRect(xTopLeft, yTopLeft, width, height));
      var x:Number = radiusRect.origin.x;
      var y:Number = radiusRect.origin.y;
      var xRadius:Number = radiusRect.size.width;
      var yRadius:Number = radiusRect.size.height;
      var angleDelta:Number = Math.PI / 4;

  //    trace("xTopLeft[" + xTopLeft + "] yTopLeft[" + yTopLeft + "] width[" +   width + "] height[" +  height + "]");
  //    trace("       x[" +        x + "]        y[" +        y + "] width[" + xRadius + "] height[" + yRadius + "]");

      // Whereas the circle has only one distance to the control point
      // for each segment, the ellipse has two distances: one that
      // corresponds to xRadius and another that corresponds to yRadius.
      var xCtrlDist:Number = xRadius/Math.cos(angleDelta/2);
      var yCtrlDist:Number = yRadius/Math.cos(angleDelta/2);
      var rx:Number, ry:Number, ax:Number, ay:Number;
      mc.moveTo(x + xRadius, y);
      var angle:Number = 0;
      for (var i:Number = 0; i < 8; i++) {
        angle += angleDelta;
        rx = x + Math.cos(angle-(angleDelta/2))*(xCtrlDist);
        ry = y + Math.sin(angle-(angleDelta/2))*(yCtrlDist);
        ax = x + Math.cos(angle)*xRadius;
        ay = y + Math.sin(angle)*yRadius;
        mc.curveTo(rx, ry, ax, ay);
    }
  }
  // END DRAW ELLIPSE METHODS
  ///////////////////////////////////////////


  ///////////////////////////////////////////
  // MISC HELPER FUNCTIONS

  // this helper function builds an array of length four from an array of 1 or 2
  // this is helpful for the various rect methods that use different params for the 4 sides.
    public static function getArrayOfFour(originalArray:Array):Array {

      var array:Array = originalArray;
      var size:Number = originalArray.length;
      if (size == 4){
        //do nothing. this is just to avoid unnecessary checks.
      }
      else if (size == 1){
        array = [originalArray[0], originalArray[0], originalArray[0], originalArray[0]];
      }
      else if (size == 2){
        array = [originalArray[0], originalArray[1], originalArray[1], originalArray[0]];
      }
      return array;
    }

  // END MISC HELPER FUNCTIONS
  ///////////////////////////////////////////


  ///////////////////////////////////////////
  // GRADIENT HELPER FUNCTIONS

    //This method translate an array of numerical values into the ratio format Flash uses for gradients.
    //Flash requires a ratio be an array of numbers starting with 0 and ending with 255.
    //If those values are already set, then the arry is returned as is, otherwise the numbers are translated to that scale.
    //TODO explain this more.
    public static function getActualRatios(ratios:Array):Array {
      return getActualNumbers(ratios, 0, 255);
    }

    //this actually doesn't make any sense, since alphas don't have to start at 0 and end at 100.
  /*
    public static function getActualAlphas(alphas:Array){
      return getActualNumbers(alphas, 0, 100);
    }
  */

    //This method translate an array of numerical values into the specified format.
    //This method is used by other methods that have specific value requirements for Muber Arrays.
    public static function getActualNumbers(values:Array, minNumber:Number, maxNumber:Number):Array {
      var size:Number = values.length;
      var minValue:Number = values[0];
      var maxValue:Number = values[size-1];
      if (minValue == minNumber && maxValue == maxNumber){
        return values;
      }
      var actualValues:Array = new Array();
  		var value:Number;
  		var actualValue:Number;
  		var offset:Number = minNumber - minValue;
      minValue += offset;
      maxValue += offset;
  		//the idea here is to change the original values to proporionally equivalent values from minValue to maxValue.
  		//all numbers are adjusted so that the first number starts at minValue and the last in maxValue.
  		for (var i:Number = 0; i < size-1; i++){
  		  value = values[i] + offset;
  		  actualValue = (value/maxValue)*(maxNumber);
  			actualValues.push(actualValue);
  		}
  		actualValues.push(maxNumber);
      return actualValues;
    }

    public static function getActualXY(values:Array, p_minX:Number, p_maxX:Number, p_minY:Number, p_maxY:Number):Array {
      var size:Number = values.length;
      var minX:Number = values[0][0];
      var maxX:Number = values[0][1];
      var minY:Number = values[0][0];
      var maxY:Number = values[0][1];
  		for (var i:Number = 1; i < values.length; i++) {
	      minX = minX < values[i][0] ? minX : values[i][0];
	      maxX = maxX > values[i][0] ? maxX : values[i][0];
	      minY = minY < values[i][1] ? minY : values[i][1];
	      maxY = maxY > values[i][1] ? maxY : values[i][1];
			}
      if (minX == p_minX && maxX == p_maxX && minY == p_minY && maxY == p_maxY){
        return values;
      }
      var actualValues:Array = new Array();
  		var xValue:Number, yValue:Number, actualX:Number, actualY:Number;
  		var xOffset:Number = p_minX - minX;
      minX += xOffset;
      maxX += xOffset;
  		var yOffset:Number = p_minY - minY;
      minY += yOffset;
      maxY += yOffset;
  		//the idea here is to change the original values to proporionally equivalent values from minValue to maxValue.
  		//all numbers are adjusted so that the first number starts at minValue and the last in maxValue.
  		for (var i:Number = 0; i < values.length; i++){
  		  xValue = values[i][0] + xOffset;
  		  actualX = (xValue/maxX)*(p_maxX);
  		  yValue = values[i][1] + yOffset;
  		  actualY = (yValue/maxY)*(p_maxY);

				var point:Array = new Array();
				point.push(actualX);
				point.push(actualY);
  			actualValues.push(point);
  		}
      return actualValues;
    }

    public static function buildArray(size:Number, initValue:Number):Array {
      var array:Array = new Array();
  		for (var i:Number = 0; i < size; i++){
  			array.push(initValue);
  		}
      return array;
    }

    public static function getMatrix(rect:NSRect, angle:Number):Object {
      var radians:Number = getRadiansFromAngle(angle);
      if (isNaN(radians)) {
        radians = 0;
      }
//      var matrix:flash.geom.Matrix = new flash.geom.Matrix();
//      matrix.createGradientBox(rect.size.width, rect.size.height, radians, rect.origin.x, rect.origin.y);
      var matrix:Object = { matrixType:"box", x:rect.origin.x, y:rect.origin.y, w:rect.size.width, h:rect.size.height, r: radians };

      return matrix;
    }

    //the rect param is a normal top/left rect, not a radiusRect
    public static function getRadialMatrix(rect:NSRect):Object {
      var width:Number  = rect.size.width;
      var height:Number = rect.size.height;
      var matrix:flash.geom.Matrix = new flash.geom.Matrix();
      matrix.createGradientBox(width, height, 0, -width/2, -height/2);
      return matrix;
    }

    public static function getRadiansFromAngle(angle:Number):Number {
      var radians:Number = angle == 0 ? 0 : (angle/180)*Math.PI;
      return radians;
    }

  // END GRADIENT HELPER FUNCTIONS
  ///////////////////////////////////////////

  ///////////////////////////////////////////
  // NSPOINT CONVENIENCE FUNCTIONS

    public static function getOffsetPoint(point:NSPoint, dx:Number, dy:Number):NSPoint {
      return new NSPoint(point.x + dx, point.y + dy);
    }

  // END NSPOINT CONVENIENCE FUNCTIONS
  ///////////////////////////////////////////


  ///////////////////////////////////////////
  // NSRECT CONVENIENCE FUNCTIONS

    public static function getRadiusRect(rect:NSRect):NSRect {
      var xRadius:Number = rect.size.width/2;
      var yRadius:Number = rect.size.height/2;
      var x:Number = rect.origin.x + xRadius;
      var y:Number = rect.origin.y + yRadius;
      return new NSRect(x, y, xRadius, yRadius);
    }

    //adds a percent of the width to x
    //adds a percent of the height to y
    //sets width to a percent of width
    //sets height to a percent of height
    public static function getScaledPercentRect(rect:NSRect, xPercent:Number, yPercent:Number, widthPercent:Number, heightPercent:Number):NSRect
    {
      var x:Number = rect.origin.x;
      var y:Number = rect.origin.y;
      var width:Number  = rect.size.width;
      var height:Number = rect.size.height;

      x = x + width*xPercent*.01;
      y = y + height*yPercent*.01;
      height = height*widthPercent*.01;
      width = width*heightPercent*.01;

      var scaledRect:NSRect = new NSRect(x, y, width, height);
      return scaledRect;
    }

    //adds given pixel to x, y, width and height
    public static function getScaledPixelRect(rect:NSRect, xPixel:Number, yPixel:Number, widthPixel:Number, heightPixel:Number):NSRect
    {
      var x:Number = rect.origin.x;
      var y:Number = rect.origin.y;
      var width:Number  = rect.size.width;
      var height:Number = rect.size.height;

      x = x + xPixel;
      y = y + yPixel;
      width  = width  + widthPixel;
      height = height + heightPixel;

      var scaledRect:NSRect = new NSRect(x, y, width, height);
      return scaledRect;
    }

  // END NSRECT CONVENIENCE FUNCTIONS
  ///////////////////////////////////////////

    public static function beginLinearGradientFill(mc:MovieClip,colors:Array,alphas:Array,ratios:Array,matrix:Object)
    {
      beginGradientFill(mc, "linear",colors,alphas,ratios,matrix);
    }

    public static function beginRadialGradientFill(mc:MovieClip,colors:Array,alphas:Array,ratios:Array,matrix:Object)
    {
      beginGradientFill(mc, "radial",colors,alphas,ratios,matrix);
    }

    //TODO consolidate actualRatios, matrix, etc to here.
    //Initially this is here for the color size check.
    public static function beginGradientFill(mc:MovieClip,gradientType:String, colors:Array,alphas:Array,ratios:Array,matrix:Object)
    {
      if (colors.length > 16)
		  {
/*
			  var e:NSException = NSException.exceptionWithNameReasonUserInfo("InvalidArgumentException",
				  "ASDraw::gradientRectWithAlpha - The color array must have 8 or fewer colors " +
				  "since Flash seems to incorrectly draw gradients with more than 8 colors. colors=" + colors,
				  null);
		  	trace(e);
	  		throw e;
*/
        trace("WARNING!!! Flash seems to incorrectly draw gradients with more than 8 colors.");
        trace(" - colors=" + colors);
  		}
      mc.beginGradientFill(gradientType,colors,alphas,ratios,matrix);
    }


  /////////////////////////////////////////////////////////////////////////////
  // RADIAN METHODS
  /////////////////////////////////////////////////////////////////////////////

  // To calculate a radian value, use this formula:
  // radian = Math.PI/180 * degree
  public static function getRadiansByDegrees(degrees:Number):Number {
    return Math.PI/180 * degrees;
  }

  // The return value represents the opposite angle of a right triangle in radians
  // where x is the adjacent side length and y is the opposite side length.
  public static function getRadians(x1:Number, x2:Number, y1:Number, y2:Number):Number {
	  var x_base:Number   = x2-x1;
	  var y_height:Number = y2-y1;
	  if (x_base == 0) {
  		if (y_height > 0) {
   	    return getRadiansByDegrees(90);
   	  }
      return getRadiansByDegrees(270);
	  }
	  if (y_height == 0) {
		  if (x_base > 0) {
        return getRadiansByDegrees(180);
      }
 	    return getRadiansByDegrees(0);
	  }
    return Math.atan2(  x_base, y_height  );
  }

  // The return value represents the opposite angle of a right triangle in radians
  // where x is the adjacent side length and y is the opposite side length.
  public static function getAngleAdjacentRadians(base:Number, height:Number):Number {
    return Math.atan2(  height, base  );
  }

  // The return value represents the opposite angle of a right triangle in radians
  // where x is the adjacent side length and y is the opposite side length.
  public static function getAngleOppositeRadians(base:Number, height:Number):Number {
    return Math.atan2(  base, height  );
  }

  /////////////////////////////////////////////////////////////////////////////
  // EASING FUNCTIONS USEFUL FOR ANIMATIONS
  // Robert Penner - Sept. 2001 - robertpenner.com
  /////////////////////////////////////////////////////////////////////////////

  public static function linearTween(t:Number, b:Number, c:Number, d:Number):Number {
    return c*t/d + b;
  }

  // quadratic easing in - accelerating from zero velocity
  public static function easeInQuad(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d;
    return c*t*t + b;
  }

  // quadratic easing out - decelerating to zero velocity
  public static function easeOutQuad(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d;
    return -c * t*(t-2) + b;
  }

  // quadratic easing in/out - acceleration until halfway, then deceleration
  public static function easeInOutQuad(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d/2;
    if (t < 1) return c/2*t*t + b;
    t--;
    return -c/2 * (t*(t-2) - 1) + b;
  }

  // cubic easing in - accelerating from zero velocity
  public static function easeInCubic(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d;
    return c*t*t*t + b;
  }

  // cubic easing out - decelerating to zero velocity
  public static function easeOutCubic(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d;
    t--;
    return c*(t*t*t + 1) + b;
  }

  // cubic easing in/out - acceleration until halfway, then deceleration
  public static function easeInOutCubic(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d/2;
    if (t < 1) return c/2*t*t*t + b;
    t -= 2;
    return c/2*(t*t*t + 2) + b;
  }

  // quartic easing in - accelerating from zero velocity
  public static function easeInQuart(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d;
    return c*t*t*t*t + b;
  }

  // quartic easing out - decelerating to zero velocity
  public static function easeOutQuart(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d;
    t--;
    return -c * (t*t*t*t - 1) + b;
  }

  // quartic easing in/out - acceleration until halfway, then deceleration
  public static function easeInOutQuart(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d/2;
    if (t < 1) return c/2*t*t*t*t + b;
    t -= 2;
    return -c/2 * (t*t*t*t - 2) + b;
  }

  // quintic easing in - accelerating from zero velocity
  public static function easeInQuint(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d;
    return c*t*t*t*t*t + b;
  }

  // quintic easing out - decelerating to zero velocity
  public static function easeOutQuint(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d;
    t--;
    return c*(t*t*t*t*t + 1) + b;
  }

  // quintic easing in/out - acceleration until halfway, then deceleration
  public static function easeInOutQuint(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d/2;
    if (t < 1) return c/2*t*t*t*t*t + b;
    t -= 2;
    return c/2*(t*t*t*t*t + 2) + b;
  }

  // sinusoidal easing in - accelerating from zero velocity
  public static function easeInSine(t:Number, b:Number, c:Number, d:Number):Number {
    return -c * Math.cos(t/d * (Math.PI/2)) + c + b;
  }

  // sinusoidal easing out - decelerating to zero velocity
  public static function easeOutSine(t:Number, b:Number, c:Number, d:Number):Number {
    return c * Math.sin(t/d * (Math.PI/2)) + b;
  }

  // sinusoidal easing in/out - accelerating until halfway, then decelerating
  public static function easeInOutSine(t:Number, b:Number, c:Number, d:Number):Number {
    return -c/2 * (Math.cos(Math.PI*t/d) - 1) + b;
  }

  // exponential easing in - accelerating from zero velocity
  public static function easeInExpo(t:Number, b:Number, c:Number, d:Number):Number {
    return c * Math.pow( 2, 10 * (t/d - 1) ) + b;
  }

  // exponential easing out - decelerating to zero velocity
  public static function easeOutExpo(t:Number, b:Number, c:Number, d:Number):Number {
    return c * ( -Math.pow( 2, -10 * t/d ) + 1 ) + b;
  }

  // exponential easing in/out - accelerating until halfway, then decelerating
  public static function easeInOutExpo(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d/2;
    if (t < 1) return c/2 * Math.pow( 2, 10 * (t - 1) ) + b;
    t--;
    return c/2 * ( -Math.pow( 2, -10 * t) + 2 ) + b;
  }

  // circular easing in - accelerating from zero velocity
  public static function easeInCirc(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d;
    return -c * (Math.sqrt(1 - t*t) - 1) + b;
  }

  // circular easing out - decelerating to zero velocity
  public static function easeOutCirc(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d;
    t--;
    return c * Math.sqrt(1 - t*t) + b;
  }

  // circular easing in/out - acceleration until halfway, then deceleration
  public static function easeInOutCirc(t:Number, b:Number, c:Number, d:Number):Number {
    t /= d/2;
    if (t < 1) return -c/2 * (Math.sqrt(1 - t*t) - 1) + b;
    t -= 2;
    return c/2 * (Math.sqrt(1 - t*t) + 1) + b;
  }
}