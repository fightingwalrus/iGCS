//
//  ArDroneViewController.h
//  iGCS
//
//  Created by David Leskowicz on 10/21/14.
//
//

#import <UIKit/UIKit.h>
#import "ArDroneUtils.h"

#import <CoreMotion/CoreMotion.h>

typedef enum AngleStatusType {
    angleNotUsed,
    angleNeedsOffset,
    angleHasOffset,
}
AngleStatusType;

@interface ArDroneViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) ArDroneUtils *arDrone2;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMDeviceMotion *deviceMotion;
@property (strong, nonatomic) CMAttitude *attitude;

@end
