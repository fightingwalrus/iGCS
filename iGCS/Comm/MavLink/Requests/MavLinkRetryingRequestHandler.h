//
//  MavLinkRetryingRequestHandler.h
//  iGCS
//
//  Created by Claudio Natoli on 13/10/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkUtility.h"

#define MAVLINK_RX_MISSION_RETRANSMISSION_TIMEOUT      0.25 // seconds

// FIXME: from reading the APM Mission Planner sources, it appears some fine tuning might be
// required on both the timeouts and the number of retries
#define MAVLINK_TX_MISSION_ITEM_RETRANSMISSION_TIMEOUT       0.3 // seconds
#define MAVLINK_TX_MISSION_ITEM_COUNT_RETRANSMISSION_TIMEOUT 0.6 // seconds

#define MAVLINK_SET_WP_RETRANSMISSION_TIMEOUT          0.25 // seconds

@class MavLinkRetryingRequestHandler;

@protocol MavLinkRetryableRequest <NSObject>
@required
- (NSString*) title;
- (NSString*) subtitle;
- (double)    timeout; // in seconds

- (void) performRequest;
// check incoming packets in case we get an ACK
- (void) checkForACK:(mavlink_message_t)packet withHandler:(MavLinkRetryingRequestHandler*)handler;
@end


@interface MavLinkRetryingRequestHandler : NSObject

@property (nonatomic, readonly) NSUInteger numAttempts;
@property (nonatomic, readonly) id<MavLinkRetryableRequest> currentRequest;
@property (nonatomic, retain) UIAlertView* requestStatusDialog;

- (void) startRetryingRequest:(id<MavLinkRetryableRequest>)request;
- (void) continueWithRequest:(id<MavLinkRetryableRequest>)request;

- (void) checkForAckOnCurrentRequest:(mavlink_message_t)packet;
- (void) completedWithSuccess:(BOOL)success;

@end
