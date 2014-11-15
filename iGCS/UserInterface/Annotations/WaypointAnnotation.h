//
//  WaypointAnnotation.h
//  iGCS
//
//  Created by Claudio Natoli on 1/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MavLinkPacketHandler.h"
#import "GCSThemeManager.h"

@interface WaypointAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign)   CLLocationCoordinate2D  coordinate;
@property (nonatomic, readonly) mavlink_mission_item_t  waypoint;
@property (nonatomic, readonly, copy) UIColor *color;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate andWayPoint:(mavlink_mission_item_t)waypoint atIndex:(NSInteger)index NS_DESIGNATED_INITIALIZER;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

- (BOOL) hasMatchingSeq:(NSInteger)seq;

@end


