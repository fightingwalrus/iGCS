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
        case MAV_CMD_NAV_LOITER_TIME:
        case MAV_CMD_NAV_LOITER_TURNS:
        case MAV_CMD_NAV_LOITER_UNLIM: {
            // Draw a circle icon
            CGRect innerR = CGRectInset(outerR, 1, 1);
            CGContextFillEllipseInRect(context, innerR);
            CGContextStrokeEllipseInRect(context, innerR);
            
            CGContextSetStrokeColorWithColor(context, [annotation color].CGColor);

            // Draw a circular arrow
            // c.f. http://stackoverflow.com/questions/20952548/animated-pie-chart-in-ios
            CGFloat startAngle = - M_PI / 4;
            CGFloat endAngle = 0.85 * 2 * M_PI + startAngle;

            CGFloat x = CGRectGetMidX(outerR);
            CGFloat y = CGRectGetMidY(outerR);
            
            // Draw the circular line
            CGFloat lineRadius = x * 0.65;
            CGFloat arrowWidth = 0.35;
            
            CGMutablePathRef path = CGPathCreateMutable();
            CGContextSetLineWidth(context, 2);
            CGFloat lineEndAngle = ((endAngle - startAngle) >= arrowWidth) ? endAngle - arrowWidth : endAngle;
            CGPathAddArc(path, NULL, x, y, lineRadius, startAngle, lineEndAngle, 0);
            CGContextAddPath(context, path);
            CGContextStrokePath(context);
            CGPathRelease(path);

            // Draw the arrow head
            CGFloat arrowStartAngle = lineEndAngle - 0.01;
            CGFloat arrowOuterRadius = x * 0.90;
            CGFloat arrowInnerRadius = x * 0.54;
            
            CGFloat arrowX = x + (arrowOuterRadius * cosf(arrowStartAngle));
            CGFloat arrowY = y + (arrowOuterRadius * sinf(arrowStartAngle));
            CGContextMoveToPoint(context, arrowX, arrowY);  // top corner
            
            arrowX = x + (arrowInnerRadius * cosf(arrowStartAngle));
            arrowY = y + (arrowInnerRadius * sinf(arrowStartAngle));
            CGContextAddLineToPoint(context, arrowX, arrowY);  // bottom corner
            
            arrowX = x + (lineRadius * cosf(endAngle));
            arrowY = y + (lineRadius * sinf(endAngle));
            CGContextAddLineToPoint(context, arrowX, arrowY);  // point
            
            CGContextClosePath(context);
            CGContextFillPath(context);
        }
            break;
            
            
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
