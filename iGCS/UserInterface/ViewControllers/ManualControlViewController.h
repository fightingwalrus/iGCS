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

NS_ENUM(NSUInteger, AngleStatusType) {
    angleNotUsed,
    angleNeedsOffset,
    angleHasOffset,
};

@interface ManualControlViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) ArDroneUtils *arDroneUtils;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMDeviceMotion *deviceMotion;
@property (strong, nonatomic) CMAttitude *attitude;

@end
