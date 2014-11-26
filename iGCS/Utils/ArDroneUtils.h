//
//  ArDroneUtils.h
//  iGCS
//
//  Created by David Leskowicz on 9/29/14.
//
//

#import <Foundation/Foundation.h>
#import "BRRequest.h"

@interface ArDroneUtils : NSObject <BRRequestDelegate>

- (void) makeTelnetConnectionToDrone;
- (void) mavlinkCommandedTakeoff;
- (void) mavlinkLand;
- (void) mavlinkReturnToLaunch;
- (void) StartSpektrumPairing;
- (void) uploadProgramToDrone;
- (void) ConnectArDroneUDP;
- (void) atCommandedTakeOff;
- (void) toggleEmergency;
- (void) calibrateHorizontalPlane;
- (void) calibrateMagnetometer;
- (void) atCommandedLand;
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
- (void) vzDance;
- (void) wave;
- (void) phiThetaMixed;
- (void) doublePhiThetaMixed;
- (void) flipAhead;
- (void) flipBehind;
- (void) flipLeft;
- (void) flipRight;
- (void) resetWatchDogTimer;
- (void) droneMove:(NSString*) moveCommand;

@end


extern NSString * const ArDroneAtUtilsAtCommandedTakeOff;
extern NSString * const ArDroneAtUtilsToggleEmergency;
extern NSString * const ArDroneAtUtilsCalibrateHorizontalPlane;
extern NSString * const ArDroneAtUtilsCalibrateMagnetometer;
extern NSString * const ArDroneAtUtilsAtCommandedLand;
extern NSString * const ArDroneAtUtilsPhiM30;
extern NSString * const ArDroneAtUtilsPhi30;
extern NSString * const ArDroneAtUtilsThetaM30;
extern NSString * const ArDroneAtUtilsTheta30;
extern NSString * const ArDroneAtUtilsTheta20degYaw200;
extern NSString * const ArDroneAtUtilsTheta20degYawM200;
extern NSString * const ArDroneAtUtilsTurnAround;
extern NSString * const ArDroneAtUtilsTurnAroundGoDown;
extern NSString * const ArDroneAtUtilsYawShake;
extern NSString * const ArDroneAtUtilsYawDance;
extern NSString * const ArDroneAtUtilsPhiDance;
extern NSString * const ArDroneAtUtilsThetaDance;
extern NSString * const ArDroneAtUtilsVzDance;
extern NSString * const ArDroneAtUtilsWave;
extern NSString * const ArDroneAtUtilsPhiThetaMixed;
extern NSString * const ArDroneAtUtilsDoublePhiThetaMixed;
extern NSString * const ArDroneAtUtilsFlipAhead;
extern NSString * const ArDroneAtUtilsFlipBehind;
extern NSString * const ArDroneAtUtilsFlipLeft;
extern NSString * const ArDroneAtUtilsFlipRight;
extern NSString * const ArDroneAtUtilsResetWatchDogTimer;
