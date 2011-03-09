/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASStrokeScaling;
import org.actionstep.constants.NSLineCapsStyle;
import org.actionstep.constants.NSLineJointStyle;
import org.actionstep.graphics.ASBrush;
import org.actionstep.graphics.ASGraphicUtils;
import org.actionstep.graphics.ASPen;
import org.actionstep.NSColor;
import org.actionstep.NSException;
import org.actionstep.NSObject;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;

import flash.display.BitmapData;
import flash.geom.Matrix;

/**
 * <p>
 * This is an abstraction for drawing on MovieClip instances. It provides 
 * helpful methods for drawing primitives. Every view has a graphics object, 
 * accessible through the {@link org.actionstep.NSView#graphics()} 
 * method.
 * </p>
 * 
 * <p>
 * ASGraphics uses {@link ASPen} implementations to draw lines, and 
 * {@link ASBrush} implementations to draw fills. If you just want to work
 * with basic colors, {@link NSColor} implements both of these interfaces.
 * </p>
 * <p>
 * By default, lines are drawn using pixel hinting, normal stroke scaling,
 * no caps style and round joints. To modify these values, use the 
 * {@link #setUsesPixelHinting()}, {@link #setStrokeScaling()}, 
 * {@link #setCapsStyle()} and {@link #setJointStyle()}. In the case of
 * mitered joints, use the {@link #setMiterLimit()} method to change the
 * limit.
 * </p>
 * 
 * @see org.actionstep.graphics.ASLinearGradient
 * @see org.actionstep.graphics.ASRadialGradient
 * @see org.actionstep.graphics.ASTextureBrush
 * 
 * @author Scott Hyndman
 */
class org.actionstep.graphics.ASGraphics extends NSObject {
	
	//******************************************************
	//*                      Members
	//******************************************************
	
	private var m_mc:MovieClip;
	private var m_usesPixelHinting:Boolean;
	private var m_strokeScaling:ASStrokeScaling;
	private var m_capsStyle:NSLineCapsStyle;
	private var m_jointStyle:NSLineJointStyle;
	private var m_miterLimit:Number;
	private var m_brush:ASBrush;
	
	//******************************************************
	//*                    Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASGraphics</code> class.
	 */
	public function ASGraphics() {
		m_usesPixelHinting = true;
		m_strokeScaling = ASStrokeScaling.ASNormalStrokeScaling;
		m_capsStyle = NSLineCapsStyle.NSRoundLineCapsStyle;
		m_jointStyle = NSLineJointStyle.NSRoundLineJointStyle;
		m_miterLimit = 3;
	}
	
	/**
	 * Initializes the object.
	 */
	public function init():ASGraphics {
		return this;
	}
	
	//******************************************************
	//*                Setting the movieclip
	//******************************************************
	
	/**
	 * Returns the MovieClip this draws upon.
	 */
	public function clip():MovieClip {
		return m_mc;
	}
	
	/**
	 * Sets the MovieClip this draws upon to <code>aClip</code>.
	 */
	public function setClip(aClip:MovieClip):Void {
		m_mc = aClip;
	}
	
	//******************************************************
	//*               Clearing the context
	//******************************************************
	
	/**
	 * Clears the movieclip.
	 */
	public function clear():Void {
		m_mc.clear();
	}
	
	//******************************************************
	//*            Setting the style of lines
	//******************************************************
	
	/**
	 * <p>Returns <code>true</code> if lines are drawn using pixel hintings.</p>
	 * 
	 * <p>The default is <code>true</code></p>
	 * 
	 * @see #setUsesPixelHinting()
	 */
	public function usesPixelHinting():Boolean {
		return m_usesPixelHinting;
	}
	
	/**
	 * <p>Sets whether lines are drawn using pixel hintings.</p>
	 * 
	 * <p>The default is <code>true</code></p>
	 * 
	 * @see #usesPixelHinting()
	 */
	public function setUsesPixelHinting(flag:Boolean):Void {
		m_usesPixelHinting = flag;
	}
	
	/**
	 * <p>Returns the type of scaling that is applied when strokes are scaled.
	 * </p>
	 * 
	 * <p>The default is {@link ASStrokeScaling#ASNormalStrokeScaling}</p>
	 * 
	 * @see #setStrokeScaling()
	 */
	public function strokeScaling():ASStrokeScaling {
		return m_strokeScaling;
	}
	
	/**
	 * <p>Sets the type of scaling that is applied when strokes are scaled to
	 * <code>scaling</code>.</p>
	 * 
	 * <p>The default is {@link ASStrokeScaling#ASNormalStrokeScaling}</p>
	 * 
	 * @see #strokeScaling()
	 */
	public function setStrokeScaling(scaling:ASStrokeScaling):Void {
		m_strokeScaling = scaling;
	}
	
	/**
	 * <p>Returns the type of caps that are drawn at the ends of lines.</p>
	 * 
	 * <p>The default is {@link NSLineCapsStyle#NSRoundLineCapsStyle}</p>
	 * 
	 * @see #setCapsStyle()
	 */
	public function capsStyle():NSLineCapsStyle {
		return m_capsStyle;
	}
	
	/**
	 * <p>Sets the type of caps that are drawn at the ends of lines to
	 * <code>caps</code>.</p>
	 * 
	 * <p>The default is {@link NSLineCapsStyle#NSRoundLineCapsStyle}</p>
	 * 
	 * @see #capsStyle()
	 */
	public function setCapsStyle(caps:NSLineCapsStyle):Void {
		m_capsStyle = caps;
	}
	
	/**
	 * <p>Returns the type of line joints that are drawn between connected 
	 * lines.</p>
	 * 
	 * <p>The default is {@link NSLineJointStyle#NSRoundLineJointStyle}</p>
	 * 
	 * @see #setJointStyle()
	 */
	public function jointStyle():NSLineJointStyle {
		return m_jointStyle;
	}
	
	/**
	 * <p>Sets the type of line joints that are drawn between connected 
	 * lines to <code>joint</code>.</p>
	 * 
	 * <p>The default is {@link NSLineJointStyle#NSRoundLineJointStyle}</p>
	 * 
	 * <p>If mitered joints are being used, the miter limit can be set using the
	 * {@link #setMiterLimit()} method.</p>
	 * 
	 * @see #jointStyle()
	 * @see #setMiterLimit()
	 */
	public function setJointStyle(joint:NSLineJointStyle):Void {
		m_jointStyle = joint;
	}
	
	/**
	 * <p>Returns the length of the meter when lines are being drawn with the
	 * {@link ASJointStyle#ASMiterJointStyle}.</p>
	 * 
	 * <p>The default is <code>3</code></p>
	 * 
	 * @see #jointStyle()
	 * @see #setMiterLimit()
	 */
	public function miterLimit():Number {
		return m_miterLimit;
	}
	
	/**
	 * <p>Sets the length of the meter when lines are being drawn with the
	 * {@link ASJointStyle#ASMiterJointStyle} to <code>limit</code>.</p>
	 * 
	 * <p>A valid values are from 1 to 255. If the value is not valid, an 
	 * exception is thrown.</p>
	 * 
	 * <p>The default is <code>3</code></p>
	 * 
	 * @see #setJointStyle()
	 * @see #miterLimit()
	 */
	public function setMiterLimit(limit:Number):Void {
		if (limit < 1 || limit > 255) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"Valid values for limit are from 1 to 255.",
				null);
			trace(e);
			throw e;
		}
		
		m_miterLimit = limit;
	}
	
	//******************************************************
	//*                     Fills
	//******************************************************
	
	/**
	 * Returns the brush used to draw fills, or <code>null</code> if no brush
	 * is being used.
	 */
	public function brush():ASBrush {
		return m_brush;
	}
	
	/**
	 * <p>Sets the brush used to draw fills to <code>brush</code>.</p>
	 * 
	 * <p>If <code>brush</code> is <code>null</code>, no fill will be drawn.</p>
	 */
	public function setBrush(brush:ASBrush):Void {
		m_brush = brush;
	}
	
	/**
	 * <p>Begins a fill using {@link #brush()}.</p>
	 * 
	 * <p>The fill can be ended using the {@link #brushUp()} method.</p>
	 * 
	 * @see #brushDownWithBrush()
	 * @see #brushUp()
	 */
	public function brushDown():Void {
		brushDownWithBrush(m_brush);
	}
	
	/**
	 * Begins a fill using the brush <code>brush</code>.
	 * 
	 * @see #brushDown()
	 * @see #brushUp()
	 */
	public function brushDownWithBrush(brush:ASBrush):Void {
		brush.beginFillWithGraphics(this);
	}
	
	/**
	 * Stops the currently set brush from drawing its fill.
	 * 
	 * @see #brushDown()
	 * @see #brushDownWithBrush()
	 */
	public function brushUp():Void {
		m_mc.endFill();
	}
	
	/**
	 * <p>Begins a fill using the brush <code>brush</code>. {@link NSColor},
	 * {@link org.actionstep.graphics.ASRadialGradient},
	 * {@link org.actionstep.graphics.ASLinearGradient} and
	 * {@link org.actionstep.graphics.ASTextureBrush} are all brush 
	 * implementations.</p>
	 * 
	 * <p>Remember to call {@link #endFill()} when you are finished drawing.</p>
	 * 
	 * @param brush The brush used to draw the fill.
	 * 
	 * @see #endFill()
	 */
	public function beginFill(brush:ASBrush):Void { 
		brush.beginFillWithGraphics(this);
	}
			
	/**
	 * <p>Begins a gradient fill without using ActionStep objects. The
	 * arguments are passed as is to the {@link MovieClip#beginGradientFill()}
	 * method.</p>
	 */
	public function beginGradientFill(fillType:String, colors:Array,
			alphas:Array, ratios:Array, matrix:Matrix, spreadMethod:String,
			interpolationMethod:String, focalPointRatio:Number):Void {
		m_mc.beginGradientFill(fillType, colors, alphas, ratios, 
			matrix, spreadMethod, interpolationMethod, focalPointRatio);
	}
	
	/**
	 * <p>Begins a bitmap fill.</p>
	 * 
	 * <p>Remember to call {@link #endFill()} when you are finished drawing.</p>
	 * 
	 * @param bitmap The bitmap to use
	 * @param matrix (optional) A matrix object defining transformations to
	 * 			apply to the bitmap. The default is <code>null</code>.
	 * @param repeat (optional) If <code>true</code>, the bitmap image will be 
	 * 			repeated in a tiled pattern. The default is <code>true</code>.
	 * @param smoothing (optional) If <code>true</code>, scaled bitmaps are
	 * 			rendered using a bilinear algorithm. The default is 
	 * 			<code>false</code>.
	 * 
	 * @see #beginFill()
	 * @see #beginGradientFill()
	 * @see #endFill()
	 */
	public function beginBitmapFill(bitmap:BitmapData, matrix:Matrix, 
			repeat:Boolean, smoothing:Boolean):Void {
		m_mc.beginBitmapFill(bitmap, matrix, repeat, smoothing);
	}
	
	/**
	 * Ends the current fill.
	 * 
	 * @see #beginFill()
	 * @see #beginGradientFill()
	 * @see #beginBitmapFill()
	 */
	public function endFill():Void {
		m_mc.endFill();
	}
		
	//******************************************************
	//*                  Drawing lines
	//******************************************************
	
	/**
	 * Draws a line from <code>(startX, startY)</code> to 
	 * <code>(endX, endY)</code> using the color and alpha values from
	 * <code>color</code> and a thickness of <code>thickness</code>.
	 * 
	 * @param startX The starting pen x-coordinate
	 * @param startY The starting pen y-coordinate
	 * @param endX The ending pen x-coordinate
	 * @param endY The ending pen y-coordinate
	 * @param color The color and alpha values used to draw the line
	 * @param thickness The thickness of the line
	 * 
	 * @see #drawLineWithPoints()
	 */
	public function drawLine(startX:Number, startY:Number, endX:Number, 
			endY:Number, color:ASPen, thickness:Number):Void {
				
		if (thickness == undefined) {
			thickness = 1;
		}
		
		setPenWithThickness(color, thickness);
			
		m_mc.moveTo(startX, startY);
		m_mc.lineTo(endX, endY);
	}
	
	/**
	 * Draws a line from <code>start</code> to <code>end</code> using the color 
	 * and alpha values from <code>color</code> and a thickness of 
	 * <code>thickness</code>.
	 * 
	 * @param start The starting pen position
	 * @param end The ending pen position
	 * @param color The color and alpha values used to draw the line
	 * @param thickness The thickness of the line
	 * 
	 * @see #drawLine()
	 */
	public function drawLineWithPoints(start:NSPoint, end:NSPoint, color:ASPen, 
			thickness:Number):Void {
		drawLine(start.x, start.y, end.x, end.y, color, thickness);
	}
	
	/**
	 * <p>Draws dotted (or dashed) lines using the color 
	 * and alpha values from <code>color</code> and a thickness of 
	 * <code>thickness</code>.</p>
	 * 
	 * <p>To make a dotted line, specify a <code>dashLength</code> of between
	 * <code>.5</code> and <code>.1</code>.</p>
	 * 
	 * <p>Dashed lines cannot be used to draw filled shapes. To achieve a similar
	 * effect, first draw your shape with solid, hidden lines and a fill, then
	 * invoke this method to add the dashes.</p>
	 * 
	 * @param startX The starting pen x-coordinate
	 * @param startY The starting pen y-coordinate
	 * @param endX The ending pen x-coordinate
	 * @param endY The ending pen y-coordinate
	 * @param dashLength The length of each dash
	 * @param dashGap The distance between each dash
	 * @param color The color and alpha values used to draw the line
	 * @param thickness The thickness of the line
	 * 
	 * @see #drawDashedLineWithPoints()
	 * @author Ric Ewing {@link ric@formequalsfunction.com }
	 */
	public function drawDashedLine(startX:Number, startY:Number, 
			endX:Number, endY:Number, dashLength:Number, dashGap:Number,
			color:ASPen, thickness:Number):Void {
		var seglength:Number, deltax:Number, deltay:Number, delta:Number, 
			segs:Number, cx:Number, cy:Number, radians:Number;
				
		if (thickness == undefined) {
			thickness = 1;
		}
			
		//	
		// Calculate the legnth of a segment
		//
		seglength = dashLength + dashGap;
		
		//
		// Calculate the length of the dashed line
		//
		deltax = endX - startX;
		deltay = endY - startY;
		delta = Math.sqrt((deltax * deltax) + (deltay * deltay));
		
		//
		// Calculate the number of segments needed
		//
		segs = Math.floor(Math.abs(delta / seglength));
		
		//
		// Get the angle of the line in radians
		//
		radians = Math.atan2(deltay, deltax);
		
		//
		// Start the line here
		//
		cx = startX;
		cy = startY;
		
		//
		// Add these to cx, cy to get next seg start
		//
		deltax = Math.cos(radians) * seglength;
		deltay = Math.sin(radians) * seglength;
		
		//
		// Set the line style
		//
		setPenWithThickness(color, thickness);
			
		//
		// Draw each segment
		//
		for (var n:Number = 0; n < segs; n++) {
			m_mc.moveTo(cx, cy);
			m_mc.lineTo(cx + Math.cos(radians) * dashLength, 
				cy + Math.sin(radians) * dashLength);
			cx += deltax;
			cy += deltay;
		}
		
		//
		// Handle last segment as it is likely to be partial
		//
		m_mc.moveTo(cx,cy);
		delta = Math.sqrt((endX - cx) * (endX - cx) + (endY-cy) * (endY - cy));
		if (delta > dashLength) {
			//
			// Segment ends in the gap, so draw a full dash
			//
			m_mc.lineTo(cx + Math.cos(radians) * dashLength, 
				cy + Math.sin(radians) * dashLength);
		} 
		else if (delta > 0) {
			//
			// Segment is shorter than dash so only draw what is needed
			//
			m_mc.lineTo(cx + Math.cos(radians) * delta, 
				cy + Math.sin(radians) * delta);
		}
		
		//
		// Move the pen to the end position
		//
		m_mc.moveTo(endX, endY);
	}
	
	/**
	 * <p>Draws dotted (or dashed) lines from the <code>start</code> point 
	 * to the <code>end</code> point using the color 
	 * and alpha values from <code>color</code> and a thickness of 
	 * <code>thickness</code>.</p>
	 * 
	 * <p>To make a dotted line, specify a <code>dashLength</code> of between
	 * <code>.5</code> and <code>.1</code>.</p>
	 * 
	 * <p>Dashed lines cannot be used to draw filled shapes. To achieve a similar
	 * effect, first draw your shape with solid, hidden lines and a fill, then
	 * invoke this method to add the dashes.</p>
	 * 
	 * @param start The starting pen position
	 * @param end The ending pen position
	 * @param dashLength The length of each dash
	 * @param dashGap The distance between each dash
	 * @param color The color and alpha values used to draw the line
	 * @param thickness The thickness of the line
	 * 
	 * @see #drawDashedLine()
	 * @author Ric Ewing {@link ric@formequalsfunction.com }
	 */
	public function drawDashedLineWithPoints(start:NSPoint, end:NSPoint, 
			dashLength:Number, dashGap:Number, color:ASPen, 
			thickness:Number):Void {
		drawDashedLine(start.x, start.y, end.x, end.y, dashLength, dashGap,
			color, thickness);
	}
	
	//******************************************************
	//*            Polyline and polygon drawing
	//******************************************************
	
	/**
	 * <p>Draws a sequence of connected lines.</p>
	 * 
	 * <p>Throws an exception if <code>points</code> contains anything other
	 * than {@link NSPoint} objects.</p>
	 * 
	 * @param points An array of {@link NSPoint} objects.
	 * @param color The color and alpha values used to draw the line.
	 * @param thickness The thickness of the line.
	 */
	public function drawPolylineWithPoints(points:Array, color:ASPen,
			thickness:Number):Void {
		//
		// Test an element of points to make sure it's a point
		//
		if (!(points[0] instanceof NSPoint)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"points must contain NSPoint objects",
				null);
			trace(e);
			throw e;
		}
		
		//
		// Set the line style
		//
		setPenWithThickness(color, thickness);
				
		//
		// Position drawing origin
		//
		m_mc.moveTo(points[0].x, points[0].y);
		
		//
		// Draw line
		//
		var len:Number = points.length;
		for (var i:Number = 1; i < len; i++) {
			m_mc.lineTo(points[i].x, points[i].y);
		}
	}
	
	/**
	 * <p>Draws a polygon outline using the an array of {@link NSPoint}
	 * objects. The last point need not be the same as the first point.</p>
	 * 
	 * <p>Throws an exception if <code>points</code> contains anything other
	 * than {@link NSPoint} objects.</p>
	 * 
	 * <p>This method can be used in conjunction with a fill operation.</p>
	 * 
	 * @param points An array of {@link NSPoint} objects.
	 * @param color The color and alpha values used to draw the line.
	 * @param thickness The thickness of the line.
	 */
	public function drawPolygonWithPoints(points:Array, color:ASPen,
			thickness:Number):Void {
		if (!NSPoint(points[0]).isEqual(NSPoint(points[points.length - 1]))) {
			points.addObject(NSPoint(points.lastObject()).clone());
		}
		
		drawPolylineWithPoints(points, color, thickness);
	}
	
	//******************************************************
	//*         Arc, circle and ellipse drawing
	//******************************************************
	
	/**
	 * <p>Draws an elliptical arc segments and returns the ending point.</p>
	 * 
	 * <p>This method can be used in conjunction with a fill operation.</p>
	 * 
	 * @param startX The starting pen x-coordinate
	 * @param startY The starting pen y-coordinate
	 * @param xRadius The x radius of the ellipse
	 * @param yRadiux The y radius of the ellipse
	 * @param arc The sweep of the arc (in degrees)
	 * @param startAngle The starting angle in degrees
	 * @param drawLinesToCenter <code>true</code> if lines should be drawn
	 * 		to the center of the arc.
	 * @param color The color and alpha values used to draw the line.
	 * @param thickness The thickness of the line.
	 * @return The ending point of the arc
	 * 
	 * @see #drawEllipticalArcWithPoint()
	 * @author Ric Ewing (ric@formequalsfunction.com)
	 */
	public function drawEllipticalArc(startX:Number, startY:Number, 
			xRadius:Number, yRadius:Number, arc:Number,
			startAngle:Number, drawLinesToCenter:Boolean,
			color:ASPen, thickness:Number):NSPoint {
		var segAngle:Number, theta:Number, angle:Number, angleMid:Number, 
			segs:Number, ax:Number, ay:Number, bx:Number, by:Number, 
			cx:Number, cy:Number;
		
		//
		// No sense in drawing more than is needed :)
		//
		if (Math.abs(arc) > 360) {
			arc = 360;
		}
		
		//
		// Flash uses 8 segments per circle, to match that, we draw in a maximum
		// of 45 degree segments. First we calculate how many segments are needed
		// for our arc.
		//
		segs = Math.ceil(Math.abs(arc) / 45);
		
		//
		// Now calculate the sweep of each segment
		//
		segAngle = arc/segs;
		
		//
		// Convert angle startAngle to radians
		//
		theta = ASGraphicUtils.convertDegreesToRadians(segAngle);
		angle = -ASGraphicUtils.convertDegreesToRadians(startAngle);
		
		//
		// Find our starting points (ax,ay) relative to the specified 
		// (startX, startY)
		//
		ax = startX - Math.cos(angle) * xRadius;
		ay = startY - Math.sin(angle) * yRadius;
		
		//
		// Move to centerpoint, then draw an invisible line to the starting
		// point.
		//
		if (drawLinesToCenter) {
			setPenWithThickness(color, thickness);
		} else {
			setPenWithThickness(undefined, 0);
		}
		m_mc.moveTo(ax, ay);
		m_mc.lineTo(startX, startY);
		
		//
		// Set the line style
		//
		setPenWithThickness(color, thickness);
				
		//
		// If our arc is larger than 45 degrees, draw as 45 degree segments
		// so that we match Flash's native circle routines.
		//
		if (segs > 0) {
			for (var i:Number = 0; i < segs; i++) {
				angle += theta; // Increment our angle
				
				//
				// Find the angle halfway between the last angle and the new
				//
				angleMid = angle - (theta / 2);
				
				//
				// Calculate our end point
				//
				bx = ax+Math.cos(angle)*xRadius;
				by = ay+Math.sin(angle)*yRadius;
				
				//
				// Calculate our control point
				//
				cx = ax + Math.cos(angleMid) * (xRadius / Math.cos(theta / 2));
				cy = ay + Math.sin(angleMid) * (yRadius / Math.cos(theta / 2));
				
				//
				// Draw the arc segment
				//
				m_mc.curveTo(cx, cy, bx, by);
			}
		}
				
		//
		// Draw a line back to the centerpoint.
		//
		if (!drawLinesToCenter) {
			setPenWithThickness(undefined, 0);
		}
		m_mc.lineTo(ax, ay);
		
		return new NSPoint(bx, by);
	}
	
	/**
	 * <p>Draws an elliptical arc segments and returns the ending point.</p>
	 * 
	 * <p>This method can be used in conjunction with a fill operation.</p>
	 * 
	 * @param start The starting pen-coordinate
	 * @param xRadius The x radius of the ellipse
	 * @param yRadiux The y radius of the ellipse
	 * @param arc The sweep of the arc (in degrees)
	 * @param startAngle The starting angle in degrees
	 * @param drawLinesToCenter <code>true</code> if lines should be drawn
	 * 		to the center of the arc.
	 * @param color The color and alpha values used to draw the line.
	 * @param thickness The thickness of the line.
	 * @return The ending point of the arc
	 * 
	 * @see #drawEllipticalArc()
	 * @author Ric Ewing (ric@formequalsfunction.com)
	 */
	public function drawEllipticalArcWithPoint(start:NSPoint, 
			xRadius:Number, yRadius:Number, arc:Number, startAngle:Number,
			drawLinesToCenter:Boolean, color:ASPen, thickness:Number):NSPoint {
		return drawEllipticalArc(start.x, start.y, xRadius, yRadius, arc, 
			startAngle, drawLinesToCenter, color, thickness);
	}
	
	/**
	 * <p>Draws an circular arc segments and returns the ending point.</p>
	 * 
	 * <p>This method can be used in conjunction with a fill operation.</p>
	 * 
	 * @param startX The starting pen x-coordinate
	 * @param startY The starting pen y-coordinate
	 * @param radius The radius of the circle
	 * @param arc The sweep of the arc (in degrees)
	 * @param startAngle The starting angle in degrees
	 * @param drawLinesToCenter <code>true</code> if lines should be drawn
	 * 		to the center of the arc.
	 * @param color The color and alpha values used to draw the line.
	 * @param thickness The thickness of the line.
	 * @return The ending point of the arc
	 * 
	 * @see #drawArc()
	 * @author Ric Ewing (ric@formequalsfunction.com)
	 */
	public function drawArc(startX:Number, startY:Number, 
			radius:Number, arc:Number, startAngle:Number,
			drawLinesToCenter:Boolean, color:ASPen, thickness:Number):NSPoint {
		return drawEllipticalArc(startX, startY, radius, radius, arc, 
			startAngle, drawLinesToCenter, color, thickness);		
	}
	
	/**
	 * <p>Draws an circular arc segments and returns the ending point.</p>
	 * 
	 * <p>This method can be used in conjunction with a fill operation.</p>
	 * 
	 * @param start The starting pen-coordinate
	 * @param radius The radius of the circle
	 * @param arc The sweep of the arc (in degrees)
	 * @param startAngle The starting angle in degrees
	 * @param drawLinesToCenter <code>true</code> if lines should be drawn
	 * 		to the center of the arc.
	 * @param color The color and alpha values used to draw the line.
	 * @param thickness The thickness of the line.
	 * @return The ending point of the arc
	 * 
	 * @see #drawArc()
	 * @author Ric Ewing (ric@formequalsfunction.com)
	 */
	public function drawArcWithPoint(start:NSPoint, 
			radius:Number, arc:Number, startAngle:Number, drawLinesToCenter:Boolean,
			color:ASPen, thickness:Number):NSPoint {
		return drawEllipticalArc(start.x, start.y, radius, radius, arc, 
			startAngle, drawLinesToCenter, color, thickness);		
	}
	
    /**
     * <p>Draws an ellipse with inside the area defined by <code>rect</code>.</p>
     * 
     * <p>This method can be used in conjunction with a fill operation.</p>
     * 
     * @param rect The rectangle the ellipse will be drawn in
	 * @param color The color and alpha values used to draw the line
	 * @param thickness The thickness of the line
     * 
     * @see #drawEllipse()
     */
	public function drawEllipseInRect(rect:NSRect, color:ASPen, 
			thickness:Number):Void {
		var radiusRect:NSRect = getRadiusRect(rect);
		drawEllipse(rect.origin.x + rect.size.width / 2, 
			rect.origin.y + rect.size.height / 2, 
			rect.size.width / 2, 
			rect.size.height / 2, 
			color, thickness);
	}
    
    /**
     * <p>Draws an ellipse with a centerpoint of <code>(x, y)</code>.</p>
     * 
     * <p>This method can be used in conjunction with a fill operation.</p>
     * 
     * @param x The x-coordinate of the ellipsis' centerpoint
     * @param y The y-coordinate of the ellipsis' centerpoint
     * @param xRadius The horizontal radius of the ellipse
     * @param yRadius The vertical radius of the ellipse
	 * @param color The color and alpha values used to draw the line
	 * @param thickness The thickness of the line
     * 
     * @see #drawEllipseInRect()
     */
    public function drawEllipse(x:Number, y:Number, xRadius:Number, 
    		yRadius:Number, color:ASPen, thickness:Number):Void {
    	var angleDelta:Number = Math.PI / 4;
    	var halfAngleDelta:Number = angleDelta / 2;   
    	var cosVal:Number = Math.cos(halfAngleDelta);
		var xCtrlDist:Number = xRadius / cosVal;
		var yCtrlDist:Number = yRadius / cosVal;
		var rx:Number, ry:Number, ax:Number, ay:Number;
		var angle:Number = 0;
		
		setPenWithThickness(color, thickness);
		m_mc.moveTo(x + xRadius, y);
				
		for (var i:Number = 0; i < 8; i++) {
			angle += angleDelta;
			rx = x + Math.cos(angle - halfAngleDelta) * (xCtrlDist);
			ry = y + Math.sin(angle - halfAngleDelta) * (yCtrlDist);
			ax = x + Math.cos(angle) * xRadius;
			ay = y + Math.sin(angle) * yRadius;
			m_mc.curveTo(rx, ry, ax, ay);
		}	
    }
    
    /**
     * <p>Draws the largest possible circle inside <code>rect</code>.</p>
     * 
     * <p>This method can be used in conjunction with a fill operation.</p>
     * 
     * @param rect The area the circle will be drawn within.
	 * @param color The color and alpha values used to draw the line
	 * @param thickness The thickness of the line
	 * 
	 * @see #drawCircleInRect()
     */
    public function drawCircleInRect(rect:NSRect, color:ASPen, 
    		thickness:Number):Void {
    	//
    	// Make the rectangle square.
    	//
    	rect = rect.clone();
    	var minDim:Number = Math.min(rect.size.width, rect.size.height);
    	rect.size.width = minDim;
    	rect.size.height = minDim;
    	
    	drawEllipseInRect(rect, color, thickness);
    }
    
    /**
     * <p>Draws a circle with a centerpoint of <code>(x,y)</code>.</p>
     * 
     * <p>This method can be used in conjunction with a fill operation.</p>
     * 
     * @param x The x-coordinate of the circle's centerpoint
     * @param y The y-coordinate of the circle's centerpoint
     * @param radius The radius of the circle
	 * @param color The color and alpha values used to draw the line
	 * @param thickness The thickness of the line
	 * 
	 * @see #drawCircleInRect()
     */
    public function drawCircle(x:Number, y:Number, radius:Number, 
    		color:ASPen, thickness:Number):Void {
    	drawEllipse(x, y, radius, radius, color, thickness);		
    }
	
	//******************************************************
	//*                  Drawing rectangle
	//******************************************************
	
	/**
	 * <p>Draws a rectangle outline.</p>
	 * 
	 * <p>This method can be used in conjunction with a fill operation.</p>
	 * 
	 * @param x The rectangle's x position
	 * @param y The rectangle's y position
	 * @param width The rectangle's width
	 * @param height The rectangle's height
	 * @param color The color and alpha values used to draw the line.
	 * @param thickness The thickness of the line.
	 * 
	 * @see #drawRectWithRect()
	 */
	public function drawRect(x:Number, y:Number, width:Number, height:Number, 
			color:ASPen, thickness:Number):Void {

		if (thickness == undefined)
			thickness = 1;
		
		//
		// Set the line style
		//
		setPenWithThickness(color, thickness);
			
		m_mc.moveTo(x, y);
		m_mc.lineTo(x + width, y);
		m_mc.lineTo(x + width, y + height);
		m_mc.lineTo(x, y + height);
		m_mc.lineTo(x, y);
	}
	
	/**
	 * <p>Draws a rectangle outline.</p>
	 * 
	 * <p>This method can be used in conjunction with a fill operation.</p>
	 * 
	 * @param rect The rectangle to draw
	 * @param color The color and alpha values used to draw the line.
	 * @param thickness The thickness of the line.
	 * 
	 * @see #drawRectWithRect()
	 */
	public function drawRectWithRect(rect:NSRect, color:ASPen, thickness:Number):Void {
		drawRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height,
			color, thickness);
	}
	
	/**
	 * <p>Draws a rectangle using four different border colors.</p>
	 * 
	 * <p>This method can be used in conjunction with fill operations.</p>
	 * 
	 * @param rect The rectangle to draw
	 * @param colors An array of ASPens used to draw the top, right, bottom
	 * 		and left edges (in that order). If the array contains 2 colors, the 
	 * 		first is used for the top and left edges, and the second is used for
	 * 		the bottom and right edges. If the array only contains one color,
	 * 		it is used for every line.  
	 * @param thickness The thickness of the line.
	 */
	public function drawRectWithRectColors(rect:NSRect, colors:Array, 
			thickness:Number):Void {
		var cs:Array = getArrayOfFour(colors);
		
		var x:Number = rect.origin.x;
		var y:Number = rect.origin.y;
		var x2:Number = x + rect.size.width - 1;
		var y2:Number = y + rect.size.height - 1;
		
		//
		// Top
		//
		setPenWithThickness(cs[0], thickness);
		m_mc.moveTo(x, y);
		m_mc.lineTo(x2, y);
		
		//
		// Right
		//
		setPenWithThickness(cs[1], thickness);
		m_mc.lineTo(x2, y2);
		
		//
		// Bottom
		//
		setPenWithThickness(cs[2], thickness);
		m_mc.lineTo(x, y2);
		
		//
		// Left
		//
		setPenWithThickness(cs[3], thickness);
		m_mc.lineTo(x, y);
	}
	
	/**
	 * <p>Draws a rectangle outline excluding the rectangle 
	 * <code>exclude</code>.</p>
	 * 
	 * <p>This method cannot be used in conjunction with fill operations.</p>
	 * 
	 * @param rect The rectangle to draw
	 * @param exclude The rectangle to exclude from <code>rect</code>
	 * @param colors An array of ASPens used to draw the top, right, bottom
	 * 		and left edges (in that order). If the array contains 2 colors, the 
	 * 		first is used for the top and left edges, and the second is used for
	 * 		the bottom and right edges. If the array only contains one color,
	 * 		it is used for every line.  
	 * @param thickness The thickness of the line.
	 */
	public function drawRectWithRectExcludingRect(rect:NSRect, exclude:NSRect, 
			colors:Array, thickness:Number):Void {
		var x:Number = rect.origin.x;
		var y:Number = rect.origin.y;
		var width:Number = rect.size.width;
		var height:Number = rect.size.height;
		var cs:Array = getArrayOfFour(colors);		
		var iRect:NSRect = rect.intersectionRect(exclude);
		var excludeTop:Boolean = true;
		
		if (iRect.maxY() == rect.maxY()) {
			excludeTop = false;
		}
		
		//
		// Change width and height so that the total width/height, including 
		// line thickness is the given width/height.
		//
		var x2:Number = x + width  -1;
		var y2:Number = y + height -1;
		var lineThickness:Number = 1;
				
		//
		// Top
		//
		setPenWithThickness(cs[0], thickness);
		m_mc.moveTo( x,  y);
		if (excludeTop) {
			m_mc.lineTo(iRect.minX(), y);
			m_mc.moveTo(iRect.maxX(), y);
		}
		m_mc.lineTo(x2,  y);

		//
		// Right
		//
		setPenWithThickness(cs[1], thickness);
		m_mc.lineTo(x2, y2);
		
		//
		// Bottom
		//
		setPenWithThickness(cs[2], thickness);
		if (!excludeTop) {
			m_mc.lineTo(iRect.maxX(), y2);
			m_mc.moveTo(iRect.minX(), y2);
		}
		m_mc.lineTo(x, y2);
		
		//
		// Left
		//
		setPenWithThickness(cs[3], thickness);
		m_mc.lineTo(x, y);
	}
    
	/**
	 * <p>Draws the outline of a rectangle with its corners cut off. The amount 
	 * of the cut (that is, the distance from the rectangle edges) is given by
	 * the <code>cornerSize</code> argument.</p>
	 * 
	 * <p>This method can be used in conjunction with a fill operation.</p>
	 * 
	 * @param x The rectangle's x position
	 * @param y The rectangle's y position
	 * @param width The rectangle's width
	 * @param height The rectangle's height
	 * @param cornerSize The amount to cut off the rectangle's corners.
	 * @param color The color and alpha values used to draw the line.
	 * @param thickness The thickness of the line.
	 * 
	 * @see #drawCutCornerRectWithRect()
	 */
	public function drawCutCornerRect(x:Number, y:Number, width:Number, height:Number,
			cornerSize:Number, color:ASPen, thickness:Number):Void {
		//
		// Set the line style
		//
		setPenWithThickness(color, thickness);
			
		//
		// Draw the rectangle
		//
		m_mc.moveTo(x+cornerSize      ,y);
		m_mc.lineTo(x+width-cornerSize,y);
		m_mc.lineTo(x+width           ,y+cornerSize);
		m_mc.lineTo(x+width           ,y+height-cornerSize);
		m_mc.lineTo(x+width-cornerSize,y+height);
		m_mc.lineTo(x+cornerSize      ,y+height);
		m_mc.lineTo(x                 ,y+height-cornerSize);
		m_mc.lineTo(x                 ,y+cornerSize);
		m_mc.lineTo(x+cornerSize      ,y);
	}
	
	/**
	 * <p>Draws the outline of a rectangle with its corners cut off. The amount 
	 * of the cut (that is, the distance from the rectangle edges) is given by
	 * the <code>cornerSize</code> argument.</p>
	 * 
	 * <p>This method can be used in conjunction with a fill operation.</p>
	 * 
	 * @param rect The rectangle to draw
	 * @param cornerSize The amount to cut off the rectangle's corners.
	 * @param color The color and alpha values used to draw the line.
	 * @param thickness The thickness of the line.
	 * 
	 * @see #drawCutCornerRectWithRect()
	 */
	public function drawCutCornerRectWithRect(rect:NSRect,
			cornerSize:Number, color:ASPen, thickness:Number):Void {
		drawCutCornerRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height,
			cornerSize, color, thickness);
	}
	
	/**
	 * <p>Draws a rectangle with rounded corners. The <code>cornerRadius</code>
	 * argument is used as the radius of the corners.</p>
	 * 
	 * <p>This method can be used in conjunction with a fill operation.</p>
	 * 
	 * @param x The rectangle's x position
	 * @param y The rectangle's y position
	 * @param width The rectangle's width
	 * @param height The rectangle's height
	 * @param cornerRadius The radius of the rectangle's corners
	 * @param color The color and alpha values used to draw the line.
	 * @param thickness The thickness of the line.
	 * 
	 * @see #drawRoundedRectWithRect
	 * @author Ric Ewing (ric@formequalsfunction.com)
	 */
	public function drawRoundedRect(x:Number, y:Number, width:Number, height:Number, 
			cornerRadius:Number, color:ASPen, thickness:Number) {
		//
		// Set the line style
		//
		setPenWithThickness(color, thickness);
		
		width--;
		height--;
		
		//
		// If the user has defined cornerRadius our task is a bit more complex.
		//
		if (cornerRadius>0) {
			var theta:Number, angle:Number, cx:Number, cy:Number, px:Number, py:Number;
			
			//
			// Make sure that width + height are larger than 2*cornerRadius
			//
			if (cornerRadius > Math.min(width, height) / 2) {
				cornerRadius = Math.min(width, height) / 2;
			}
			
			// theta = 45 degrees in radians
			theta = Math.PI / 4;
			// draw top line
			m_mc.moveTo(x + cornerRadius, y);
			m_mc.lineTo(x + width-cornerRadius, y);
			//angle is currently 90 degrees
			angle = -Math.PI / 2;
			// draw tr corner in two parts
			cx = x +  width-cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			cy = y + cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			px = x + width-cornerRadius + (Math.cos(angle + theta) * cornerRadius);
			py = y + cornerRadius + (Math.sin(angle + theta) * cornerRadius);
			m_mc.curveTo(cx, cy, px, py);
			angle += theta;
			cx = x + width-cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			cy = y + cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			px = x + width-cornerRadius + (Math.cos(angle + theta) * cornerRadius);
			py = y + cornerRadius + (Math.sin(angle + theta) * cornerRadius);
			m_mc.curveTo(cx, cy, px, py);
			// draw right line
			m_mc.lineTo(x + width, y + height-cornerRadius);
			// draw br corner
			angle += theta;
			cx = x + width-cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			cy = y + height-cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			px = x + width-cornerRadius + (Math.cos(angle + theta) * cornerRadius);
			py = y + height-cornerRadius + (Math.sin(angle + theta) * cornerRadius);
			m_mc.curveTo(cx, cy, px, py);
			angle += theta;
			cx = x + width-cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			cy = y + height-cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			px = x + width-cornerRadius + (Math.cos(angle + theta) * cornerRadius);
			py = y + height-cornerRadius + (Math.sin(angle + theta) * cornerRadius);
			m_mc.curveTo(cx, cy, px, py);
			// draw bottom line
			m_mc.lineTo(x + cornerRadius, y + height);
			// draw bl corner
			angle += theta;
			cx = x + cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			cy = y + height-cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			px = x + cornerRadius + (Math.cos(angle + theta) * cornerRadius);
			py = y + height-cornerRadius + (Math.sin(angle + theta) * cornerRadius);
			m_mc.curveTo(cx, cy, px, py);
			angle += theta;
			cx = x + cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			cy = y + height-cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			px = x + cornerRadius + (Math.cos(angle + theta) * cornerRadius);
			py = y + height-cornerRadius + (Math.sin(angle + theta) * cornerRadius);
			m_mc.curveTo(cx, cy, px, py);
			// draw left line
			m_mc.lineTo(x, y + cornerRadius);
			// draw tl corner
			angle += theta;
			cx = x + cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			cy = y + cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			px = x + cornerRadius + (Math.cos(angle + theta) * cornerRadius);
			py = y + cornerRadius + (Math.sin(angle + theta) * cornerRadius);
			m_mc.curveTo(cx, cy, px, py);
			angle += theta;
			cx = x + cornerRadius + (Math.cos(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			cy = y + cornerRadius + (Math.sin(angle + (theta / 2)) * cornerRadius / Math.cos(theta / 2));
			px = x + cornerRadius + (Math.cos(angle + theta) * cornerRadius);
			py = y + cornerRadius + (Math.sin(angle + theta) * cornerRadius);
			m_mc.curveTo(cx, cy, px, py);
		} else {
			// cornerRadius was not defined or = 0. This makes it easy.
			m_mc.moveTo(x, y);
			m_mc.lineTo(x + width, y);
			m_mc.lineTo(x + width, y + height);
			m_mc.lineTo(x, y + height);
			m_mc.lineTo(x, y);
		}
	}
	
	/**
	 * <p>Draws a rectangle with rounded corners. The <code>cornerRadius</code>
	 * argument is used as the radius of the corners.</p>
	 * 
	 * <p>This method can be used in conjunction with a fill operation.</p>
	 * 
	 * @param rect The rectangle to draw
	 * @param cornerRadius The radius of the rectangle's corners
	 * @param color The color and alpha values used to draw the line.
	 * @param thickness The thickness of the line.
	 * 
	 * @see #drawRoundedRect()
	 * @author Ric Ewing (ric@formequalsfunction.com)
	 */
	public function drawRoundedRectWithRect(rect:NSRect, 
			cornerRadius:Number, color:ASPen, thickness:Number) {
		drawRoundedRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height,
			cornerRadius, color, thickness);		
	}
	
	/**
	 * <p>Draws a dotted (or dashed) rectangle in the area defined by 
	 * <code>rect</code> using the color and alpha values from 
	 * <code>color</code> and a thickness of <code>thickness</code>.</p>
	 * 
	 * <p>To make a dotted line, specify a <code>dashLength</code> of between
	 * <code>.5</code> and <code>.1</code>.</p>
	 * 
	 * <p>Dashed rectangles cannot be used with fills. To achieve a similar
	 * effect, first draw your shape with solid, hidden lines and a fill, then
	 * invoke this method to add the dashes.</p>
	 * 
	 * @param rect The rectangle to draw
	 * @param dashLength The length of each dash
	 * @param dashGap The distance between each dash
	 * @param color The color and alpha values used to draw the line
	 * @param thickness The thickness of the line
	 */
	public function drawDashedRectWithRect(rect:NSRect, dashLength:Number, 
			dashGap:Number, color:ASPen, thickness:Number):Void {
		drawDashedLine(rect.origin.x, rect.origin.y, rect.maxX(), rect.origin.y, 
			dashLength, dashGap, color, thickness);
		drawDashedLine(rect.maxX(), rect.origin.y, rect.maxX(), rect.maxY(), 
			dashLength, dashGap, color, thickness);
		drawDashedLine(rect.maxX(), rect.maxY(), rect.origin.x, rect.maxY(), 
			dashLength, dashGap, color, thickness);
		drawDashedLine(rect.origin.x, rect.maxY(), rect.origin.x, rect.origin.y, 
			dashLength, dashGap, color, thickness);
	}
	
	//******************************************************
	//*                  Drawing tiles
	//******************************************************
	
	/**
	 * <p>
	 * Draws a tiled pattern of filled rectangles. The entire pattern fills
	 * the space of <code>rect</code> and returns the remaining rectangle. Each 
	 * rectangle tile is inset from the original rectangle on an edge defined in
	 * <code>sides</code> by 1 pixel. The tile is filled with the color found at
	 * the same index as the edge in <code>colors</code>. <code>rect</code> is 
	 * divided in the order specified by the edges in <code>sides</code>.
	 * </p>
	 * <p>
	 * This method retains the current brush, but raises it if it is down.
	 * </p>
	 * 
	 * @param rect 
	 * 		The area to fill
	 * @param sides 
	 * 		An array of NSRectEdges that specify the positions of the tiles, as
	 * 		well as the order in which <code>rect</code> should be sliced
	 * @param colors
	 * 		An array of colors, one per tile. This array should have the same
	 * 		length as <code>sides</code>.
	 */
	public function drawTiledRectsWithRectEdgesColors(rect:NSRect, sides:Array,
			colors:Array):NSRect {
		var count:Number = sides.length;
		var slice:NSRect = NSRect.ZeroRect;
		var remainder:NSRect = rect.clone();
		var rects:Array = new Array(count);
		
		//
		// Slice up the rectangle
		//
		for (var i:Number = 0; i < count; i++) {
			NSRect.divideRect(remainder.clone(), slice, remainder, 1, sides[i]);
			rects[i] = slice.clone();
		}
		
		//
		// Draw the slices
		//
		brushUp();
		for (var i:Number = 0; i < count; i++) {
			brushDownWithBrush(colors[i]);
			drawRectWithRect(rects[i]);
			brushUp();
		}
		
		return remainder;
	}
  
	//******************************************************
	//*                   Other shapes
	//******************************************************
	
	/**
	 * <p>Draws a hexagon starting at <code>(x,y)</code>.</p>
	 * 
	 * <p>This method can be used in conjunction with a fill operation.</p>
	 * 
	 * @param x The initial pen x-coordinate.
	 * @param y The initial pen y-coordinate.
	 * @param hexRadius The radius of the hexagon.
	 * @param color The color and alpha values used to draw the line
	 * @param thickness The thickness of the line
	 */
	public function drawHexagon(x:Number, y:Number, hexRadius:Number,
			color:ASPen, thickness:Number):Void {
		var sideC:Number = hexRadius;
		var sideA:Number = 0.5 * sideC;
		var sideB:Number = Math.sqrt((hexRadius * hexRadius)
			- (0.5 * hexRadius) * (0.5 * hexRadius));
		
		setPenWithThickness(color, thickness);
		
		m_mc.moveTo(x, y);
		m_mc.lineTo(x, sideC + y);
		m_mc.lineTo(sideB + x, y + sideA + sideC); // bottom point
		m_mc.lineTo(2 * sideB + x, y + sideC);
		m_mc.lineTo(2 * sideB + x, y);
		m_mc.lineTo(sideB + x, y - sideA);
		m_mc.lineTo(x, y);
	}
	
	
	/**
	 * <p>Draws a helix starting at <code>(x,y)</code>.</p>
	 * 
	 * <p>This method can be used in conjunction with a fill operation.</p>
	 * 
	 * @param x The initial pen x-coordinate.
	 * @param y The initial pen y-coordinate.
	 * @param radiux The radius of the helix.
	 * @param styleMaker Used to warp the helix
	 * @param color The color and alpha values used to draw the line
	 * @param thickness The thickness of the line
	 */
	public function drawHelix(x:Number, y:Number, radius:Number, 
			styleMaker:Number, color:ASPen, thickness:Number):Void {
		var r:Number = radius;
		setPenWithThickness(color, thickness);
		m_mc.moveTo(x+r,y);
		
		var style:Number = Math.tan(styleMaker*Math.PI/180);
		for (var angle:Number=45;angle<=360;angle+=45){
			var endX:Number = r * Math.cos(angle*Math.PI/180);
			var endY:Number = r * Math.sin(angle*Math.PI/180);
			var cX:Number   = endX + r* style * Math.cos((angle-90)*Math.PI/180);
			var cY:Number   = endY + r* style * Math.sin((angle-90)*Math.PI/180);
			m_mc.curveTo(cX+x,cY+y,endX+x,endY+y);
		}
	}
  
	//******************************************************
	//*                 Internal methods
	//******************************************************
	
	/**
	 * Called by {@link ASPen} instances to set the line style using values
	 * contained in the instance.
	 */
	public function __applyLineStyleWithColorThickness(color:NSColor, 
			thickness:Number):Void {
		m_mc.lineStyle(thickness, color.value, color.alphaValue, true,
			m_strokeScaling.argValue, m_capsStyle.argValue, 
			m_jointStyle.argValue, m_miterLimit);
	}
	
	/**
	 * Clears the line style.
	 */
	public function __applyNullLineStyle():Void {
		m_mc.lineStyle(undefined, 0, 0);
	}
	
	//******************************************************
	//*                  Helper methods
	//******************************************************
	
	/**
	 * Sets the color and thickness used to draw lines.
	 */
	private function setPenWithThickness(pen:ASPen, thickness:Number):Void {
		if (pen != null) {
			pen.applyLineStyleWithGraphicsThickness(this, thickness);
		} else {
			__applyNullLineStyle();
		}
	}
	
	/**
	 * <p>Extracts the color values and alpha values from an array of 
	 * {@link NSColor} objects.</p>
	 * 
	 * <p>Returns an object structured as follows:<br/>
	 * <code>{colors:Array, alphas:Array}</code></p>
	 */
	private static function extractValuesAndAlphasFromColors(colors:Array):Object {
		//
		// Build separate color and alpha arrays
		//
		var cs:Array = [];
		var alphas:Array = [];
		var len:Number = colors.length;
		for (var i:Number = 0; i < len; i++) {
			var c:NSColor = NSColor(colors[i]);
			cs.push(c.value);
			alphas.push(c.alphaValue);
		}
		
		return {colors: cs, alphas: alphas};
	}
	
	/**
	 * Returns a rectangle where the origin represents the center point of
	 * an ellipse, and the size represents the ellipsis' radii.
	 */
	public static function getRadiusRect(rect:NSRect):NSRect {
		var xRadius:Number = rect.size.width / 2;
		var yRadius:Number = rect.size.height / 2;		
		return new NSRect(rect.origin.x + xRadius, rect.origin.y + yRadius, 
			xRadius, yRadius);
	}
	
	/**
	 * Takes an array containing 1 or 2 elements and expands it to contain
	 * 4. If <code>arr</code> contains anything other than 1 or 2 elements,
	 * a copy of the array is returned.
	 */
	private static function getArrayOfFour(arr:Array):Array {
		var array:Array;
		var size:Number = arr.length;
		
		if (size == 1) {
			array = [arr[0], arr[0], arr[0], arr[0]];
		}
		else if (size == 2) {
			array = [arr[0], arr[1], arr[1], arr[0]];
		} else {
			array = arr.slice();
		}
		
		return array;
	}
}