//
//  CoreMotionUtils.m
//  iGCS
//
//  Created by David Leskowicz on 11/25/14.
//
//

#import "CoreMotionUtils.h"
#define MAXDEGREES 60

@implementation CoreMotionUtils


+ (GCSMAVRotationAngles) normalizedRotationAnglesFromQuaternion:(CMQuaternion)quat {
    
    GCSMAVRotationAngles anglesOfRotation;
    
    float rollQuat = (atan2(2*(quat.y*quat.w - quat.x*quat.z), 1-2*quat.y*quat.y - 2*quat.z*quat.z)) * (180/M_PI) ;
    float pitchQuat  = (atan2(2*(quat.x*quat.w + quat.y*quat.z), 1-2*quat.x*quat.x - 2*quat.z*quat.z)) * (180/M_PI);
    float yawQuat =  (asin(2*quat.x*quat.y + 2*quat.w*quat.z)) * (180/M_PI);
    
    // Default orientation = UIDeviceOrientationPortrait
    anglesOfRotation.pitch = (1000/MAXDEGREES) * pitchQuat;
    anglesOfRotation.roll =  (1000/MAXDEGREES) * rollQuat;
    anglesOfRotation.yaw =   (-1000/MAXDEGREES) * yawQuat;
    
    // Change to Landscape Right (button on the left. radio on left)
    anglesOfRotation.pitch = (1000/MAXDEGREES) * rollQuat;
    anglesOfRotation.roll = (-1000/MAXDEGREES) * pitchQuat;
    
    
    if (anglesOfRotation.roll > 1000) {
        anglesOfRotation.roll = 1000;
    } else if (anglesOfRotation.roll < -1000) {
        anglesOfRotation.roll = -1000;
    }
    
    if (anglesOfRotation.pitch > 1000) {
        anglesOfRotation.pitch = 1000;
    } else if (anglesOfRotation.pitch < -1000) {
        anglesOfRotation.pitch = -1000;
    }
    
    
    if (anglesOfRotation.yaw > 1000) {
        anglesOfRotation.yaw = 1000;
    } else if (anglesOfRotation.yaw < -1000) {
        anglesOfRotation.yaw = -1000;
    }
    
    
    if ((anglesOfRotation.roll > -100) && (anglesOfRotation.roll < 100)) {
        anglesOfRotation.roll = 0;
    }
    
    if ((anglesOfRotation.pitch > -100) && (anglesOfRotation.pitch < 100)) {
        anglesOfRotation.pitch = 0;
    }
    
    if ((anglesOfRotation.yaw > -100) && (anglesOfRotation.yaw < 100)) {
        anglesOfRotation.yaw = 0;
    }
    
    return anglesOfRotation;
}


@end
