//
//  MavLinkRetryingRequestHandler.m
//  iGCS
//
//  Created by Claudio Natoli on 13/10/13.
//
//

#import "MavLinkRetryingRequestHandler.h"

@implementation MavLinkRetryingRequestHandler

#define MAX_RETRIES 7


#pragma mark - General purpose "modal request dialog" helpers

- (void) presentRequestStatusDialog:(NSString*)title {

     //FIXME: This causes an infinite loop when the messages don't get through
    _requestStatusDialog = [[UIAlertView alloc] initWithTitle:title
                                                      message:@"Starting Request..."
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel" // FIXME: not really. This view should be modal. Alternatively, we should reset/cancel the request on cancel
                                            otherButtonTitles:nil];
    [_requestStatusDialog show];
}

- (void) updateRequestStatusDialog:(NSString*)message withAttemptNum:(NSUInteger)attemptNum {
    [_requestStatusDialog setMessage:(attemptNum == 1) ? message : [NSString stringWithFormat:@"%@ - attempt %lu", message, (unsigned long)attemptNum]];
}

- (void) completedRequestStatusWithSuccess:(BOOL)success {
    if (success) {
        [_requestStatusDialog dismissWithClickedButtonIndex:0 animated:YES];
    } else {
        [_requestStatusDialog setMessage:@"Failed"];
    }
}


#pragma mark - Internal Methods

// c.f. http://qgroundcontrol.org/mavlink/waypoint_protocol#communication_state_machine
- (void) retryRequest:(id<MavLinkRetryableRequest>)request {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (_numAttempts++ < MAX_RETRIES) {
        [self updateRequestStatusDialog:[request subtitle] withAttemptNum:_numAttempts];
        [request performRequest];
        [self performSelector:@selector(retryRequest:) withObject:request afterDelay:[request timeout]];
    } else {
        [self completedRequestStatusWithSuccess: NO];
    }
}

- (void) resetRequest:(id<MavLinkRetryableRequest>)request {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _numAttempts    = 0;
    _currentRequest = request;
}


#pragma mark - Public Methods

- (void) startRetryingRequest:(id<MavLinkRetryableRequest>)request {
    [self resetRequest:request];
    [self presentRequestStatusDialog:[request title]];
    [self retryRequest:request];
}

- (void) continueWithRequest:(id<MavLinkRetryableRequest>)request {
    [self resetRequest:request];
    [self retryRequest:request];
}

- (void) checkForAckOnCurrentRequest:(mavlink_message_t)packet {
    [_currentRequest checkForACK:packet withHandler:self];
}

- (void) completedWithSuccess:(BOOL)success {
    [self resetRequest:nil];
    [self completedRequestStatusWithSuccess:success];
}


@end
