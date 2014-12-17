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

+ (void)drawTriangle:(CGContextRef)context
             centreX:(CGFloat)x width:(CGFloat)w
               baseY:(CGFloat)y height:(CGFloat)h {
    CGContextBeginPath(context);
    CGContextMoveToPoint(context,    x,     y);
    CGContextAddLineToPoint(context, x-w/2, y+h);
    CGContextAddLineToPoint(context, x+w/2, y+h);
    CGContextClosePath(context);
    
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)drawRect:(CGRect)rect {
    CGRect centre = CGRectMake(CGRectGetMidX(rect), CGRectGetMidY(rect), 0, 0);
    CGRect outerR = CGRectInset(centre, -WAYPOINT_INNER_RADIUS, -WAYPOINT_INNER_RADIUS);

    WaypointAnnotation* annotation = (WaypointAnnotation*)[self annotation];
    mavlink_mission_item_t item = annotation.waypoint;

    GCSThemeManager *theme = [GCSThemeManager sharedInstance];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, WAYPOINT_OUTER_WIDTH);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetFillColorWithColor(context, [annotation color].CGColor);
    CGContextSetStrokeColorWithColor(context, [theme waypointLineStrokeColor].CGColor);
    
    switch (item.command) {
        case MAV_CMD_NAV_LAND:
        case MAV_CMD_NAV_TAKEOFF: {
            // Draw an equilateral triangle icon at the centre of the rect
            // (pointing up for takeoff, down for landing)
            BOOL isTakeOff = (item.command == MAV_CMD_NAV_TAKEOFF);
            CGFloat w = outerR.size.height;
            CGFloat h = w * 0.866;
            CGFloat y = isTakeOff ? CGRectGetMinY(outerR) : CGRectGetMaxY(outerR);
            [WaypointAnnotationView drawTriangle:context
                                         centreX:CGRectGetMidX(outerR)
                                           width:w
                                           baseY:y
                                          height:(isTakeOff ? h : - h)];
        }
            break;
            
        default:
            if (item.seq == 0) {
                // Draw a primitive home icon for HOME/0 waypoint
                CGContextSetStrokeColorWithColor(context, [annotation color].CGColor); // stroke with the fill color
                
                CGFloat y = CGRectGetMidY(outerR);
                CGFloat wh = outerR.size.height/2;
                [WaypointAnnotationView drawTriangle:context
                                             centreX:CGRectGetMidX(outerR)
                                               width:outerR.size.width
                                               baseY:y-wh
                                              height:wh];
                
                CGRect sqr = CGRectMake(CGRectGetMidX(outerR)-wh/2, y, wh, wh);
                CGContextFillRect(context, sqr);
                CGContextStrokeRect(context, sqr);
            } else {
                // Draw a circle icon
                CGContextFillEllipseInRect(context, outerR);
                CGContextStrokeEllipseInRect(context, outerR);
            }
    }
}

@end
