//
//  MavLinkRetryingRequestHandler.h
//  iGCS
//
//  Created by Claudio Natoli on 13/10/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkUtility.h"

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
- (void) continueRetryingRequest:(id<MavLinkRetryableRequest>)request;

- (void) checkForAckOnCurrentRequest:(mavlink_message_t)packet;
- (void) requestCompleted:(bool)success;

@end
