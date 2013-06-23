//
//  WaypointHelper.h
//  iGCS
//
//  Created by Claudio Natoli on 1/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MavLinkPacketHandler.h"

@interface WaypointHelper : NSObject {
    NSDictionary *cmdID_to_String;
}

+ (NSString*) commandIDToString:(uint8_t)cmdID;
+ (NSString*) navWaypointToDetailString:(mavlink_mission_item_t)waypoint;
+ (BOOL) isNavCommand:(mavlink_mission_item_t)waypoint;

@end
