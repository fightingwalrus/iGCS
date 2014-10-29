//
//  FillStrokePolyLineView.m
//  iGCS
//
//  Created by Claudio Natoli on 14/03/2014.
//
//

#import "FillStrokePolyLineView.h"

@interface FillStrokePolyLineView ()
@property (nonatomic, retain) MKPolyline *polyline;
@end

@implementation FillStrokePolyLineView

- (instancetype) initWithPolyline:(MKPolyline*)polyline {
	self = [super initWithOverlay:polyline];
	if (self) {
		self.polyline = polyline;
        self.fillWidth = 1;
        self.lineWidth = 1;
	}
	return self;
}

- (void) drawPath:(CGPathRef)path
            color:(CGColorRef)color
            width:(CGFloat)width
       andContext:(CGContextRef)context {
	CGContextAddPath(context, path);
    CGContextSetStrokeColorWithColor(context, color);
	CGContextSetLineWidth(context, width);
    CGContextSetLineCap(context, self.lineCap);
    CGContextSetLineJoin(context, self.lineJoin);
	CGContextStrokePath(context);
}

- (void) drawMapRect:(MKMapRect)mapRect
           zoomScale:(MKZoomScale)zoomScale
           inContext:(CGContextRef)context {
    // Create the path
    CGMutablePathRef path = CGPathCreateMutable();
	for (NSUInteger i = 0; i < self.polyline.pointCount; i++) {
		CGPoint p = [self pointForMapPoint:_polyline.points[i]];
		if (i == 0) {
			CGPathMoveToPoint(path, nil, p.x, p.y);
		} else {
			CGPathAddLineToPoint(path, nil, p.x, p.y);
		}
	}
    
    // Draw two paths
    //  - first the "stroke" as a wider path
    //  - then followed by the thinner "fill" on top
    [self drawPath:path
             color:self.strokeColor.CGColor
             width:(2*self.lineWidth + self.fillWidth)/zoomScale
        andContext:context];
    [self drawPath:path
             color:self.fillColor.CGColor
             width:self.fillWidth/zoomScale
        andContext:context];
    
    CGPathRelease(path);
}

@end
