//
//  CoreMotionUtils.h
//  iGCS
//
//  Created by David Leskowicz on 11/25/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

struct GCSMAVRotationAngles{
    int16_t roll;
    int16_t pitch;
    int16_t yaw;
};
typedef struct GCSMAVRotationAngles GCSMAVRotationAngles;

@interface CoreMotionUtils : NSObject

+ (GCSMAVRotationAngles) normalizedRotationAnglesFromQuaternion:(CMQuaternion)quat;

@end
