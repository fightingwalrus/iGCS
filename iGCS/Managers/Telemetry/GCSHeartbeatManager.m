//
//  GCSHeartbeatManager.m
//  iGCS
//
//  Created by Andrew Brown on 2/21/15.
//
//

#import "GCSHeartbeatManager.h"

NSString * const GCSHeartbeatManagerHeartbeatWasLost = @"GCSHeartbeatManagerHeartbeatWasLost";
NSString * const GCSHeartbeatManagerHeartbeatDidArrive = @"GCSHeartbeatManagerHeartbeatDidArrive";

@implementation GCSHeartbeatManager

static const double HEARTBEAT_LOSS_WAIT_TIME = 3.0;

- (void)postHeartbeatWasLostNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:GCSHeartbeatManagerHeartbeatWasLost
                                                           object:nil];
    });
}

- (void)postHeartbeatDidArriveNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:GCSHeartbeatManagerHeartbeatDidArrive
                                                           object:nil];
    });
}

#pragma mark - Public API
- (void) rescheduleLossCheck {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(postHeartbeatWasLostNotification) object:nil];
    [self postHeartbeatDidArriveNotification];
    [self performSelector:@selector(postHeartbeatWasLostNotification) withObject:nil afterDelay:HEARTBEAT_LOSS_WAIT_TIME];
}

@end

