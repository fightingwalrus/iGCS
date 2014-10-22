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

- (void)drawRect:(CGRect)rect {
    CGRect centre = CGRectMake(CGRectGetMidX(rect), CGRectGetMidY(rect), 0, 0);
    CGRect outerR = CGRectInset(centre, -WAYPOINT_INNER_RADIUS, -WAYPOINT_INNER_RADIUS);
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    WaypointAnnotation* annotation = (WaypointAnnotation*)[self annotation];
    
    GCSThemeManager *theme = [GCSThemeManager sharedInstance];
    
    switch (annotation.waypoint.command) {
        case MAV_CMD_NAV_LAND:
        case MAV_CMD_NAV_TAKEOFF: {
            // Draw an equilateral triangle icon at the centre of the rect
            // (pointing up for takeoff, down for landing)
            BOOL isTakeOff = (annotation.waypoint.command == MAV_CMD_NAV_TAKEOFF);
            CGFloat w = outerR.size.height;
            
            CGFloat h = w * 0.866;
            CGFloat y1 = isTakeOff ? CGRectGetMinY(outerR) : CGRectGetMaxY(outerR);
            CGFloat y2 = isTakeOff ? y1 + h: y1 - h;
            
            CGContextBeginPath(context);
            CGContextMoveToPoint(context,    CGRectGetMidX(outerR),     y1);
            CGContextAddLineToPoint(context, CGRectGetMidX(outerR)-w/2, y2);
            CGContextAddLineToPoint(context, CGRectGetMidX(outerR)+w/2, y2);
            CGContextClosePath(context);
            
            CGContextSetLineJoin(context, kCGLineJoinRound);
            CGContextSetLineWidth(context, WAYPOINT_OUTER_WIDTH);
            CGContextSetFillColorWithColor(context, [annotation color].CGColor);
            CGContextSetStrokeColorWithColor(context, [theme waypointLineStrokeColor].CGColor);
            CGContextDrawPath(context, kCGPathFillStroke);
        }
            break;
            
        default:
            // Draw a circle icon
            CGContextSetLineWidth(context, WAYPOINT_OUTER_WIDTH);
            CGContextSetFillColorWithColor(context, [annotation color].CGColor);
            CGContextSetStrokeColorWithColor(context, [theme waypointLineStrokeColor].CGColor);
            CGContextFillEllipseInRect(context, outerR);
            CGContextStrokeEllipseInRect(context, outerR);
    }
}

@end
