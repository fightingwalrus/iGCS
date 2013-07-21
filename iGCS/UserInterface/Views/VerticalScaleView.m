//
//  VerticalScaleView.m
//  iGCS
//
//  Created by Claudio Natoli on 12/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VerticalScaleView.h"
#import "GaugeViewCommon.h"
#import "MiscUtilities.h"

@implementation VerticalScaleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setScale:(int)_scale {
    scale = _scale;
}

- (void)setValue:(float)_val {
    val = _val;
}

- (void)setTargetDelta:(float)_targetDelta {
    targetDelta = _targetDelta;
}

#if DO_ANIMATION
- (void) doAnimation {
    static float i = 0;
    i += VSS_STEP;
    [self setValue: i];
    [self setTargetDelta: i];
    [self requestRedraw];
}

- (void)awakeFromNib {    
    [NSTimer scheduledTimerWithTimeInterval:(ANIMATION_TIMER) target:self selector:@selector(doAnimation) userInfo:nil repeats:YES];
}
#endif


// FIXME: Refactor out common code with CompassView 
- (void) drawToContext:(CGContextRef)ctx rect:(CGRect)rect;
{
#if DO_NSLOG
    NSLog(@"VerticalScale: Drawing to {%f,%f, %f,%f}", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
#endif
    
    const float w = 0.90 * rect.size.width;
    const float h = 0.98 * rect.size.height;
    const float oneScaleY = h/scale;
    
    const CGPoint c = CGPointMake(CGRectGetMidX(rect) , CGRectGetMidY(rect));
    
    const float TICK_BASE        = c.x - w/2 + w/20;
    const float TICK_MAJOR_WIDTH = w/3;
    const float TICK_MINOR_WIDTH = w/6;
    const float TICK_HEIGHT      = 0.005 * h;
    const float CHEV_SIDE        = 0.018 * h;
    const float FONT_SIZE_SMALL  = 0.20  * w;
    const float FONT_SIZE_LARGE  = 2*FONT_SIZE_SMALL;
    
    // Drawing code
    CGContextClearRect(ctx, rect);
    CGContextSetFillColorWithColor(ctx,   [[UIColor blackColor] CGColor]);
    CGContextFillRect(ctx, rect);
    
    CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextSetFillColorWithColor(ctx,   [[UIColor whiteColor] CGColor]);
    CGContextSetLineWidth(ctx, TICK_HEIGHT);
    CGContextSetTextMatrix(ctx, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
    CGContextSelectFont(ctx, "Arial Rounded MT Bold", FONT_SIZE_SMALL, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(ctx, kCGTextFill);

    // Draw scale centred on current point
    const float step = scale/10;
    const float startVal = floor((val-scale)/step)*step; // i.e. start at a point well below the scale boundary
    float tickVal = startVal;
    for (int i = 0; i < 40; i++, tickVal = startVal + i*step/2) {
        // Find the y position of this tick
        const float y = c.y - (tickVal - val) * oneScaleY;
        if (y < -20 || y > h + 20) continue;

        // Draw the tick
        CGContextBeginPath(ctx);
        const float x = (i % 2 == 0) ? TICK_BASE+TICK_MAJOR_WIDTH : TICK_BASE+TICK_MINOR_WIDTH;
        CGContextMoveToPoint(ctx, x, y);
        CGContextAddLineToPoint (ctx, TICK_BASE, y);    
        CGContextStrokePath(ctx);
        CGContextBeginPath(ctx);
        CGContextAddArc(ctx, x, y, TICK_HEIGHT/2, 0, 2*M_PI, 1);
        CGContextFillPath(ctx);
        
        // Draw the "numbers"
        if (i % 2 == 0) {
            NSString *label = [NSString stringWithFormat:@"%d", (int)round(tickVal)];
            CGContextSetTextPosition(ctx, c.x, y + FONT_SIZE_SMALL/3.0);
            CGContextShowText(ctx, [label cStringUsingEncoding:NSASCIIStringEncoding], [label length]);
        }
    }
    
    // Draw centre pointer over the top
    //
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor] CGColor]);
    CGContextSetRGBStrokeColor(ctx, ORANGE_COLOUR);

    CGContextBeginPath(ctx);
    CGContextAddRect(ctx, CGRectMake(c.x-w/2, c.y-FONT_SIZE_LARGE/2, w, FONT_SIZE_LARGE));
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextSelectFont(ctx, "Arial Rounded MT Bold", FONT_SIZE_LARGE, kCGEncodingMacRoman);
    NSString *label = [NSString stringWithFormat:@"%d", (int)round(val)];

    float labelWidth = [MiscUtilities getTextWidth:label withContext:ctx];
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    CGContextSetTextPosition(ctx, c.x - labelWidth/2, c.y + FONT_SIZE_LARGE/3.0);
    CGContextShowText(ctx, [label cStringUsingEncoding:NSASCIIStringEncoding], [label length]);
    

    CGRect gaugeBoundary = CGRectMake(c.x - w/2, c.y-h/2, w, h);
    
    // Draw "shadow to simulate depth
    // http://www.raywenderlich.com/2033/core-graphics-101-lines-rectangles-and-gradients
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *colors = [NSArray arrayWithObjects:
                       (__bridge id)[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0].CGColor, 
                       (__bridge id)[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0].CGColor, 
                       nil];
    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    for (int i = 0; i < 2; i++) {
        CGRect subRect = CGRectMake(c.x-w/2, ((i == 0) ? c.y - h/2 : c.y + h/2 - h/5), w, h/5);
        CGPoint startPoint = CGPointMake(CGRectGetMinX(subRect), CGRectGetMinY(subRect));
        CGPoint endPoint = CGPointMake(CGRectGetMinX(subRect), CGRectGetMaxY(subRect));
        if (i == 0) {
            CGPoint tmp = startPoint;
            startPoint = endPoint;
            endPoint = tmp;
        }
        CGContextSaveGState(ctx);
        CGContextAddRect(ctx, subRect);
        CGContextClip(ctx);
        CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
        CGContextRestoreGState(ctx);
    }
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);

    // Draw target chevron
    float chevY = c.y - targetDelta * oneScaleY;
    if (chevY > c.y + h/2) chevY = c.y + h/2;
    if (chevY < c.y - h/2) chevY = c.y - h/2;
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx,    c.x+w/2-CHEV_SIDE,     chevY);
    CGContextAddLineToPoint(ctx, c.x+w/2,               chevY+CHEV_SIDE);
    CGContextAddLineToPoint(ctx, c.x+w/2,               chevY-CHEV_SIDE);
    CGContextAddLineToPoint(ctx, c.x+w/2-CHEV_SIDE,     chevY);
    CGContextSetLineWidth(ctx, TICK_HEIGHT/3);
    CGContextSetRGBFillColor(ctx, ORANGE_COLOUR);
    CGContextSetRGBStrokeColor(ctx, CHEVRON_BORDER_COLOUR);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    // Draw black over entire rect, clipping inside of the gauge boundary
    // http://cocoawithlove.com/2010/05/5-ways-to-draw-2d-shape-with-hole-in.html
    CGContextSaveGState(ctx);
    CGContextAddRect(ctx, CGContextGetClipBoundingBox(ctx));
    CGContextAddRect(ctx, gaugeBoundary);
    CGContextClosePath(ctx);
    CGContextEOClip(ctx);
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddRect(ctx, CGContextGetClipBoundingBox(ctx));
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor] CGColor]);
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
    
    // Draw gauge boundary
    CGContextBeginPath(ctx);
    CGContextAddRect(ctx, gaugeBoundary);
    CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextSetLineWidth(ctx, TICK_HEIGHT);
    CGContextStrokePath(ctx);
}

@end
