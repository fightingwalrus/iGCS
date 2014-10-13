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
- (void) phiM30;
- (void) phi30;
- (void) thetaM30;
- (void) theta30;
- (void) theta20degYaw200;
- (void) theta20degYawM200;
- (void) turnAround;
- (void) turnAroundGoDown;
- (void) yawShake;
- (void) yawDance;
- (void) phiDance;
- (void) thetaDance;
- (void) VzDance;
- (void) wave;
- (void) PhiTheataMixed;
- (void) DoublePhiTheataMixed;
- (void) FlipAhead;
- (void) FlipBehind;
- (void) FlipLeft;
- (void) FlipRight;
- (void) ResetWatchDogTimer;

@end
