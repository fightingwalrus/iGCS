//
//  MavLinkUtility.h
//  iGCS
//
//  Created by Claudio Natoli on 21/07/13.
//
//

#import <Foundation/Foundation.h>
#include "MavLinkTools.h"

@interface MavLinkUtility : NSObject

+ (NSString*) mavModeEnumToString:(enum MAV_MODE)mode;
+ (NSString*) mavStateEnumToString:(enum MAV_STATE)state;
+ (NSString*) mavCustomModeToString:(int)customMode;

@end
