//
//  CompassView.m
//  iGCS
//
//  Created by Claudio Natoli on 12/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CompassView.h"
#import "GaugeViewCommon.h"
#import "MiscUtilities.h"

@implementation CompassView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setHeading:(float)_heading {
    if (_heading >= 0 && _heading <= 360) heading = _heading;
}

- (void) setNavBearing:(float)_navBearing {
    if (_navBearing >= 0 && _navBearing <= 360) navBearing = _navBearing;
}

#if DO_ANIMATION
- (void) doAnimation {
    static float i = 0;
    i += COMPASS_STEP;
    [self setHeading:fmod(i,360)];
    [self requestRedraw];
}

- (void)awakeFromNib {    
    [NSTimer scheduledTimerWithTimeInterval:(ANIMATION_TIMER) target:self selector:@selector(doAnimation) userInfo:nil repeats:YES];
}
#endif


- (void) drawToContext:(CGContextRef)ctx rect:(CGRect)rect {
    DDLogVerbose(@"Compass: Drawing to {%f,%f, %f,%f}", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    const float HORZ_INSET_PERC = 0.0;
    const float VERT_INSET_PERC = 0.0;
    
    const float w = (1.00 - 2*HORZ_INSET_PERC) * rect.size.width;
    const float h = (1.00 - 2*VERT_INSET_PERC) * rect.size.height;
    const float oneDegX = 1.0/75 * w;
    
    CGPoint c = CGPointMake(CGRectGetMidX(rect) , CGRectGetMidY(rect));
    
    const float TICK_BASE         = c.y + h/2 - h/20;
    const float TICK_MAJOR_HEIGHT = h/3;
    const float TICK_MINOR_HEIGHT = h/6;
    const float TICK_WIDTH        = 0.015 * w;
    const float CHEV_SIDE         = 0.018 * w;
    const float FONT_SIZE         = 0.60  * h;
    
    // Drawing code
    CGContextClearRect(ctx, rect);
    CGContextSetFillColorWithColor(ctx,   [[UIColor blackColor] CGColor]);
    CGContextFillRect(ctx, rect);
    
    CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextSetFillColorWithColor(ctx,   [[UIColor whiteColor] CGColor]);
    CGContextSetLineWidth(ctx, TICK_WIDTH);
    CGContextSetTextMatrix(ctx, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
    CGContextSelectFont(ctx, "Arial Rounded MT Bold", FONT_SIZE, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    
    // Draw 360 degrees, centered on current position.
    // An aircraft compass has:
    //   * small tick every 5 deg
    //   * large tick every 10 deg
    //   * number every 30 deg, with N/S/W/E replacing their respective numbers
    //
    // They also run in an "anticlockwise" direction; that is, [NE --- N --- NW], 
    // but have deliberately chosen a more intuitive display here
    int startAng = ((int)heading - 180)/5 * 5;
    const float startX = c.x + (startAng-heading) * oneDegX;
    int ang = (startAng < 0) ? startAng += 360 : startAng;    
    for (int i = 0; i < 360; i += 5, ang = (ang+5) % 360) {
        // Find the x position of this tick
        const float x = startX + i*oneDegX;
        if (x < -20 || x > w + 20) continue;
        
        // Draw the tick
        CGContextBeginPath(ctx);
        const float y = (ang % 10 == 0) ? TICK_BASE-TICK_MAJOR_HEIGHT : TICK_BASE-TICK_MINOR_HEIGHT;
        CGContextMoveToPoint(ctx, x, y);
        CGContextAddLineToPoint (ctx, x, TICK_BASE);    
        CGContextStrokePath(ctx);
        CGContextBeginPath(ctx);
        CGContextAddArc(ctx, x, y, TICK_WIDTH/2, 0, 2*M_PI, 1);
        CGContextFillPath(ctx);

        // Draw the "numbers"
        if (ang % 30 == 0) {
            NSString *label;
            if (ang % 90 == 0) {
                // Compass points
                NSArray *array = @[@"N", @"E", @"S", @"W"];
                label = array[ang/90];
            } else {
                // Plain old number
                label = [NSString stringWithFormat:@"%03d", ang];
            }
            
            float labelWidth = [MiscUtilities getTextWidth:label withContext:ctx];
            CGContextSetTextDrawingMode(ctx, kCGTextFill);
            CGContextSetTextPosition(ctx, x - labelWidth/2, c.y);
            CGContextShowText(ctx, [label cStringUsingEncoding:NSASCIIStringEncoding], [label length]);
        }
    }

    // Draw centre pointer over the top
    //
    CGContextSaveGState(ctx);
    CGContextSetShadow (ctx, CGSizeMake (TICK_WIDTH, TICK_WIDTH), 2.5);
    for (int i = 0; i < 2; i++) {
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx,    c.x, c.y-h/2);
        CGContextAddLineToPoint(ctx, c.x, c.y+h/2);    
        if (i == 0) {
            CGContextSetLineWidth(ctx, TICK_WIDTH);
            CGContextSetStrokeColorWithColor(ctx, [[UIColor blackColor] CGColor]);
        } else {
            CGContextSetLineWidth(ctx, TICK_WIDTH/3);
            CGContextSetRGBStrokeColor(ctx, ORANGE_COLOUR);    
        }
        CGContextStrokePath(ctx);
    }
    CGContextRestoreGState(ctx);

    CGRect gaugeBoundary = CGRectMake(c.x - w/2, c.y-h/2, w, h);

    // Draw "shadow to simulate depth
    // http://www.raywenderlich.com/2033/core-graphics-101-lines-rectangles-and-gradients
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *colors = @[(__bridge id)[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0].CGColor, 
                        (__bridge id)[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0].CGColor];
    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    for (int i = 0; i < 2; i++) {
        CGRect subRect = CGRectMake(((i == 0) ? c.x - w/2 : c.x + w/6), c.y - h/2, w/3, h);
        CGPoint startPoint = CGPointMake(CGRectGetMinX(subRect), CGRectGetMinY(subRect));
        CGPoint endPoint = CGPointMake(CGRectGetMaxX(subRect), CGRectGetMinY(subRect));
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
    
    // Draw bearing chevron
    float bearingError = (navBearing - heading);
    if (bearingError >  180) bearingError -= 360;
    if (bearingError < -180) bearingError += 360;
    
    float chevX = c.x + bearingError * oneDegX;
    if (chevX > c.x + w/2) chevX = c.x + w/2;
    if (chevX < c.x - w/2) chevX = c.x - w/2;
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx,    chevX,             c.y+h/2-CHEV_SIDE);
    CGContextAddLineToPoint(ctx, chevX+CHEV_SIDE,   c.y+h/2);
    CGContextAddLineToPoint(ctx, chevX-CHEV_SIDE,   c.y+h/2);
    CGContextAddLineToPoint(ctx, chevX,             c.y+h/2-CHEV_SIDE);
    CGContextSetLineWidth(ctx, TICK_WIDTH/9);
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
    CGContextSetStrokeColorWithColor(ctx, [[UIColor grayColor] CGColor]);
    CGContextSetLineWidth(ctx, TICK_WIDTH/3);
    CGContextStrokePath(ctx);
}

@end
