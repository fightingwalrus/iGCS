//
//  ArtificialHorizonView.m
//  iGCS
//
//  Created by Claudio Natoli on 11/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArtificialHorizonView.h"
#import "GaugeViewCommon.h"

@implementation ArtificialHorizonView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setRoll:(float)roll pitch:(float)pitch {
    if (roll  <= M_PI &&   roll  >= -M_PI)   _roll  = roll;
    if (pitch <= M_PI/2 && pitch >= -M_PI/2) _pitch = pitch;
}

#if DO_ANIMATION
- (void) doAnimation {
    static int i = 0;
    i++;
    [self setRoll:(fmodf(AH_ROT_ANGLE + AH_ROT_PER_STEP*i +180, 360)-180) * DEG2RAD pitch: AH_PITCH_ANGLE * DEG2RAD];
    [self requestRedraw];
}

- (void)awakeFromNib {
    [NSTimer scheduledTimerWithTimeInterval:(ANIMATION_TIMER) target:self selector:@selector(doAnimation) userInfo:nil repeats:YES];
}
#endif

- (void) drawToContext:(CGContextRef)ctx rect:(CGRect)rect {
    DDLogVerbose(@"AH: Drawing to {%f,%f, %f,%f}", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    float r = 0.95 * fmin(rect.size.width,rect.size.height)/2.0;
    CGPoint c = CGPointMake(CGRectGetMidX(rect) , CGRectGetMidY(rect));

    CGContextClearRect(ctx, rect);
    [self drawAHGaugeInnerCircle: ctx centre:c radius:r];
    [self drawAHGaugeOuterFixed:  ctx centre:c radius:r];
    
    static CGLayerRef frontFaceLayer = NULL;
    if (frontFaceLayer == NULL) {
        frontFaceLayer = CGLayerCreateWithContext(ctx, self.frame.size, NULL);
        CGContextRef ctx = CGLayerGetContext(frontFaceLayer);
        [self drawAHGaugeFrontFace:   ctx centre:c radius:r];
    }
    CGContextDrawLayerAtPoint(ctx, CGPointMake(0,0), frontFaceLayer);
}

- (void) drawAHGaugeInnerCircle:(CGContextRef) ctx centre:(CGPoint)c radius:(float) r {

    // Clip context to the inside of the guage
    CGContextSaveGState(ctx);
    UIGraphicsBeginImageContextWithOptions((self.frame.size), NO, 0.0);
    CGContextRef newContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(newContext, 0.0, self.frame.size.height);
    CGContextScaleCTM(newContext, 1.0, -1.0);
    [[UIColor blackColor] set];
    CGRect gaugeCircle = CGRectMake(c.x - r, c.y - r, 2*r, 2*r);
    CGContextFillEllipseInRect(newContext, gaugeCircle);
    CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    CGContextClipToMask(ctx, self.bounds, mask);
    
    float xMinorDelta = 0.1 * r;
    float yMinorDelta = 1.0/12.0 * r; // => 5 deg of pitch
    
    // Rotate about the centre point, and translate to desired "pitch"
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, c.x, c.y);
    transform = CGAffineTransformRotate(transform, _roll);
    transform = CGAffineTransformTranslate(transform, -c.x, -c.y);
    transform = CGAffineTransformTranslate(transform, 0, _pitch*RAD2DEG/5.0 * yMinorDelta);
    CGContextConcatCTM(ctx, transform);
    
    // Ground
    CGContextSetRGBFillColor(ctx, GROUND_COLOUR);
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, c.x, c.y, 2*r, 0, M_PI, 0);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    // Sky
    CGContextSetRGBFillColor(ctx, SKY_COLOUR);
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, c.x, c.y, 2*r, 0, M_PI, 1);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
 
    // Horizon line
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, 0.02 * r);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, c.x - r, c.y);
    CGContextAddLineToPoint(ctx, c.x + r, c.y);    
    CGContextStrokePath(ctx);

    // Prepare for drawing pitch labels
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetTextMatrix(ctx, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
    CGContextSelectFont(ctx, "Helvetica", 0.1 * r, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    //CGContextSetCharacterSpacing(ctx, 5); 

    // Add pitch lines
    for (int i = 1; i <= 4; i++) {
        NSString *label = [NSString stringWithFormat:@"%d", i*10];
        
        // Increasing size of horizontal stroke moving out from centre
        float xMajorDelta  = (i+1)     * xMinorDelta;
        float yOffset      = (i  ) * 2 * yMinorDelta;

        // For both above and below the horizon
        for (int j = 0; j < 2; j++) {
            
            // Main stroke
            float y = c.y + (j == 0 ? yOffset : -yOffset);
            CGContextBeginPath(ctx);
            CGContextMoveToPoint   (ctx, c.x - xMajorDelta, y);  
            CGContextAddLineToPoint(ctx, c.x + xMajorDelta, y);
            CGContextStrokePath(ctx);

            // Main stroke label either side of the line
            CGContextSetTextPosition(ctx, c.x - xMajorDelta - r*0.15, y + r*0.03);  
            CGContextShowText(ctx, [label cStringUsingEncoding:NSASCIIStringEncoding], [label length]);
            CGContextSetTextPosition(ctx, c.x + xMajorDelta + r*0.05, y + r*0.03);  
            CGContextShowText(ctx, [label cStringUsingEncoding:NSASCIIStringEncoding], [label length]);

            // Minor stroke
            y += (j == 0 ? -yMinorDelta : yMinorDelta);
            CGContextBeginPath(ctx);
            CGContextMoveToPoint   (ctx, c.x - xMinorDelta, y);  
            CGContextAddLineToPoint(ctx, c.x + xMinorDelta, y);
            CGContextStrokePath(ctx);            
        }
    }
    
    // Pop transform and clean up
    CGContextConcatCTM(ctx, CGAffineTransformInvert(transform));
    
    CGImageRelease(mask);
    CGContextRestoreGState(ctx);
}

// Ugh
#define FRONT_FACE_WIDTH (0.10*r) 
#define FRONT_FACE_INNER_RADIUS (r - FRONT_FACE_WIDTH)

- (void) drawAHGaugeOuterFixed:(CGContextRef) ctx centre:(CGPoint)c radius:(float) r {

    float FRONT_FACE_MID_RADIUS   = (r + FRONT_FACE_INNER_RADIUS) / 2.0;        
    float FRONT_FACE_MAJOR_TICK_RADIUS = r - FRONT_FACE_WIDTH/3.0;
    float FRONT_FACE_MINOR_TICK_RADIUS = r - FRONT_FACE_WIDTH/2.0;
    
    // Rotate about the centre
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, c.x, c.y);
    transform = CGAffineTransformRotate(transform, _roll);
    transform = CGAffineTransformTranslate(transform, -c.x, -c.y);
    CGContextConcatCTM(ctx, transform);
    
    // Ground
    CGContextSetLineWidth(ctx, FRONT_FACE_WIDTH);
    CGContextSetRGBStrokeColor(ctx, GROUND_COLOUR);
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, c.x, c.y, FRONT_FACE_MID_RADIUS, 0, M_PI, 0);
    CGContextStrokePath(ctx);
    
    // Sky
    CGContextSetRGBStrokeColor(ctx, SKY_COLOUR);
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, c.x, c.y, FRONT_FACE_MID_RADIUS, 0, M_PI, 1);
    CGContextStrokePath(ctx);

    // Darken the outer ring of the gauge
    CGContextSetRGBStrokeColor(ctx, SHADOW_COLOUR);
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, c.x, c.y, FRONT_FACE_MID_RADIUS, 0, 2*M_PI, 1);
    CGContextStrokePath(ctx);

    // Add horizon ticks
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, 0.04*r);
    for (int i = 0; i < 2; i++) {
        CGContextBeginPath(ctx);
        CGContextMoveToPoint   (ctx, c.x + (i==0 ? r : -r), c.y);
        CGContextAddLineToPoint(ctx, c.x + (i==0 ? FRONT_FACE_INNER_RADIUS : -FRONT_FACE_INNER_RADIUS), c.y);
        CGContextStrokePath(ctx);
    }

    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    // +/-45 + 0 deg arrow marks
    for (int i = 0; i < 3; i++) {
        float outerRad = FRONT_FACE_MAJOR_TICK_RADIUS;
        if (i == 1) // 0 def
            outerRad = r;
        float ang = (-135 + i*45) * DEG2RAD;
        float angOffset = (outerRad - FRONT_FACE_INNER_RADIUS)/1.414/outerRad;
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint   (ctx, c.x + FRONT_FACE_INNER_RADIUS      * cos(ang), c.y + FRONT_FACE_INNER_RADIUS      * sin(ang));
        CGContextAddLineToPoint(ctx, c.x + outerRad * cos(ang + angOffset), c.y + outerRad * sin(ang + angOffset));
        CGContextAddLineToPoint(ctx, c.x + outerRad * cos(ang - angOffset), c.y + outerRad * sin(ang - angOffset));
        CGContextClosePath(ctx);
        CGContextFillPath(ctx);
    }
    
    // +/- 30 + 60 deg major ticks
    CGContextSetLineWidth(ctx, 0.02*r);
    for (int i = 1; i < 6; i++) {
        if (i == 3) continue;
        float ang = -30 * i * DEG2RAD;
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint   (ctx, c.x + FRONT_FACE_INNER_RADIUS      * cos(ang), c.y + FRONT_FACE_INNER_RADIUS      * sin(ang));
        CGContextAddLineToPoint(ctx, c.x + FRONT_FACE_MAJOR_TICK_RADIUS * cos(ang), c.y + FRONT_FACE_MAJOR_TICK_RADIUS * sin(ang));
        CGContextStrokePath(ctx);
    }

    // +/- 10 + 20 deg minor ticks
    CGContextSetLineWidth(ctx, 0.01*r);
    for (int i = 1; i < 6; i++) {
        if (i == 3) continue;
        float ang = (-120 + i*10) * DEG2RAD;
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint   (ctx, c.x + FRONT_FACE_INNER_RADIUS      * cos(ang), c.y + FRONT_FACE_INNER_RADIUS      * sin(ang));
        CGContextAddLineToPoint(ctx, c.x + FRONT_FACE_MINOR_TICK_RADIUS * cos(ang), c.y + FRONT_FACE_MINOR_TICK_RADIUS * sin(ang));
        CGContextStrokePath(ctx);
    }    
    
    // Pop transform
    CGContextConcatCTM(ctx, CGAffineTransformInvert(transform));    
}



- (void) drawAHGaugeFrontFace:(CGContextRef) ctx centre:(CGPoint)c radius:(float) r {

    float AIRPLANE_POINTER_WIDTH = r * 0.04;
    float TRIANGLE_POINTER_WIDTH = r * 0.02;
    float TRIANGLE_POINTER_APEX  = r - FRONT_FACE_WIDTH;
    float TRIANGLE_POINTER_SIDE  = r * 0.13;
    float FRONT_FACE_BOTTOM_BASE_HALF_ANGLE   = 60 * DEG2RAD;
    float GAUGE_BORDER_WIDTH     = r * 0.005;
    
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    
     // Darken the edge of the inner circle to give appearance of curvature into screen
     // http://www.raywenderlich.com/2033/core-graphics-101-lines-rectangles-and-gradients
     CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
     NSArray *colors = @[(__bridge id)[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0].CGColor,
                         (__bridge id)[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0].CGColor];
     CGFloat locations[] = {0.0, 1.0};
     CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
     CGContextSaveGState(ctx);
     CGContextAddArc(ctx, c.x, c.y, FRONT_FACE_INNER_RADIUS, 0, 2*M_PI, 1);
     CGContextClip(ctx);
     CGContextDrawRadialGradient(ctx, gradient, c, FRONT_FACE_INNER_RADIUS-r*0.075, c, FRONT_FACE_INNER_RADIUS, 0);
     CGContextRestoreGState(ctx);
     CGGradientRelease(gradient);
     CGColorSpaceRelease(colorSpace);
    
    // Put some subtle shading around the front face objects
    CGContextSaveGState(ctx);
    CGContextSetShadow (ctx, CGSizeMake (TRIANGLE_POINTER_WIDTH, TRIANGLE_POINTER_WIDTH), 2.5);
    
    // Draw bottom of front face
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, c.x, c.y, r, M_PI/2 + FRONT_FACE_BOTTOM_BASE_HALF_ANGLE, M_PI/2 - FRONT_FACE_BOTTOM_BASE_HALF_ANGLE, 1);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    // Draw the holder for the pointer
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, TRIANGLE_POINTER_WIDTH);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx,    c.x, c.y);
    CGContextAddLineToPoint(ctx, c.x, c.y + r);
    CGContextStrokePath(ctx);
    
    CGContextSetLineWidth(ctx, 2*AIRPLANE_POINTER_WIDTH);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx,    c.x, c.y + r/3);
    CGContextAddLineToPoint(ctx, c.x, c.y + r);
    CGContextStrokePath(ctx);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx,    c.x,                          c.y + r/3 - 2*AIRPLANE_POINTER_WIDTH);
    CGContextAddLineToPoint(ctx, c.x - AIRPLANE_POINTER_WIDTH, c.y + r/3 + 1);
    CGContextAddLineToPoint(ctx, c.x + AIRPLANE_POINTER_WIDTH, c.y + r/3 + 1);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    // Draw the "airplane" pointer
    for (int i = 0; i < 2; i++) {
        if (i == 0) {
            // Draw background of pointer
            CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
            CGContextSetLineWidth(ctx, AIRPLANE_POINTER_WIDTH);
        } else {
            // Draw foreground of pointer
            CGContextSetRGBStrokeColor(ctx, ORANGE_COLOUR);
            CGContextSetLineWidth(ctx, AIRPLANE_POINTER_WIDTH * 2/3);
        }

        float y = c.y;
        CGContextBeginPath(ctx);
        CGContextMoveToPoint   (ctx, c.x - 0.65 * r + 0.01*i*r, y);
        CGContextAddLineToPoint(ctx, c.x - 0.20 * r,            y);
        CGContextAddLineToPoint(ctx, c.x - 0.10 * r,            y + 0.10 * r);
        CGContextAddLineToPoint(ctx, c.x,                       y + AIRPLANE_POINTER_WIDTH/2 * 0.414);
        CGContextAddLineToPoint(ctx, c.x + 0.10 * r,            y + 0.10 * r);
        CGContextAddLineToPoint(ctx, c.x + 0.20 * r,            y);
        CGContextAddLineToPoint(ctx, c.x + 0.65 * r - 0.01*i*r, y);
        CGContextStrokePath(ctx);
    }
        
    // Draw the front face arrow
    float y = c.y - TRIANGLE_POINTER_APEX;
    for (int i = 0; i < 2; i++) {        
        if (i == 0) {
            // Draw background of pointer
            CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
            CGContextSetLineWidth(ctx, TRIANGLE_POINTER_WIDTH);
        } else {
            // Draw foreground of pointer
            CGContextSetRGBStrokeColor(ctx, ORANGE_COLOUR);
            CGContextSetLineWidth(ctx, TRIANGLE_POINTER_WIDTH * 2/3);
        }
    
        CGContextBeginPath(ctx);
        CGContextMoveToPoint   (ctx, c.x                          , y);
        CGContextAddLineToPoint(ctx, c.x - TRIANGLE_POINTER_SIDE/2, y + TRIANGLE_POINTER_SIDE * sin(M_PI/3));
        CGContextAddLineToPoint(ctx, c.x + TRIANGLE_POINTER_SIDE/2, y + TRIANGLE_POINTER_SIDE * sin(M_PI/3));
        CGContextClosePath(ctx);
        CGContextStrokePath(ctx);
    }
    CGContextRestoreGState(ctx);

    // Clip the circle shape, and fill the rest with black
    // http://cocoawithlove.com/2010/05/5-ways-to-draw-2d-shape-with-hole-in.html
    CGContextSaveGState(ctx);
    CGContextAddRect(ctx, CGContextGetClipBoundingBox(ctx));
    CGContextAddArc(ctx, c.x, c.y, r, 0, 2*M_PI, 1);
    CGContextClosePath(ctx);
    CGContextEOClip(ctx);
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddRect(ctx, CGContextGetClipBoundingBox(ctx));
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);
    
    // Put a line around the gauge to define it
    CGContextSetLineWidth(ctx, GAUGE_BORDER_WIDTH);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, c.x, c.y, 1.02 * r - GAUGE_BORDER_WIDTH, 0, 2 * M_PI, 1);
    CGContextStrokePath(ctx);    
}

@end
