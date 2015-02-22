//
//  GCSHeartbeatManager.h
//  iGCS
//
//  Created by Andrew Brown on 2/21/15.
//
//

#import <Foundation/Foundation.h>

@interface GCSHeartbeatManager : NSObject
- (void) rescheduleLossCheck;
@end

extern NSString * const GCSHeartbeatManagerHeartbeatWasLost;
extern NSString * const GCSHeartbeatManagerHeartbeatDidArrive;