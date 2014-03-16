//
//  WaypointAnnotationView.m
//  iGCS
//
//  Created by Claudio Natoli on 16/03/2014.
//
//

#import "WaypointAnnotationView.h"
#import "WaypointAnnotation.h"

#define WAYPOINT_INNER_RADIUS 8
#define WAYPOINT_OUTER_WIDTH  1

@implementation WaypointAnnotationView

- (void)drawRect:(CGRect)rect
{
    CGRect centre = CGRectMake(CGRectGetMidX(rect), CGRectGetMidY(rect), 0, 0);
    CGRect outerR = CGRectInset(centre, -WAYPOINT_INNER_RADIUS, -WAYPOINT_INNER_RADIUS);
    CGRect innerR = CGRectInset(outerR, WAYPOINT_OUTER_WIDTH, WAYPOINT_OUTER_WIDTH);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor gcsWaypointLineStrokeColor].CGColor);
    CGContextFillEllipseInRect(context, outerR);
    
    CGContextSetFillColorWithColor(context, [(WaypointAnnotation*)[self annotation] getColor].CGColor);
    CGContextFillEllipseInRect(context, innerR);
}

@end
