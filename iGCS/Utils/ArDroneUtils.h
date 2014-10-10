//
//  ArDroneUtils.h
//  iGCS
//
//  Created by David Leskowicz on 9/29/14.
//
//

#import <Foundation/Foundation.h>
#import "BRRequest.h"

#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"






//@interface arDroneUtils : NSObject
@interface ArDroneUtils : NSObject <BRRequestDelegate>
{
    GCDAsyncSocket *gcdsocket;
    GCDAsyncUdpSocket *gcdUdpSocket;
}



- (void) telArdrone;
- (void) mavArdrone;
- (void) MavlinkLand;
- (void) MavlinkReturnToLaunch;
- (void) specArdrone;
- (void) uploadSer2udp;
- (void) ConnectArDroneUDP;
- (void) AtCommandedTakeOff;
- (void) ToggleEmergency;
- (void) CalibrateHorizontalPlane;
- (void) CalibrateMagnetometer;
- (void) ATLand;
- (void) DoublePhiTheataMixed;
- (void) FlipAhead;
- (void) FlipBehind;
- (void) FlipLeft;
- (void) FlipRight;
- (void) ResetWatchDogTimer;

@end
