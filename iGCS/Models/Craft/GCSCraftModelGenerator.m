//
//  GCSCraftModelGenerator.m
//  iGCS
//
//  Created by Claudio Natoli on 24/01/2015.
//
//

#import "GCSCraftModelGenerator.h"
#import "GCSCraftArduCopter.h"
#import "GCSCraftArduPlane.h"

@implementation GCSCraftModelGenerator

+ (GCSCraftType) craftTypeFromHeartbeat:(GCSHeartbeat*)heartbeat {
    switch (heartbeat.mavType) {
        case MAV_TYPE_TRICOPTER:
        case MAV_TYPE_QUADROTOR:
        case MAV_TYPE_HEXAROTOR:
        case MAV_TYPE_OCTOROTOR:
        case MAV_TYPE_HELICOPTER:
            return ArduCopter;

        case MAV_TYPE_FIXED_WING:
            return ArduPlane;

        // IGCS-236 review: hard-fail, or log unknown and return a (possibly wrong) default?
        // Additionally, what do we need for the current ar.drone code?
        default: assert(false);
    }
}

#pragma mark External API

+ (id<GCSCraftModel>) createInitialModel {
    return [[GCSCraftArduCopter alloc] init:nil];
}

+ (id<GCSCraftModel>) updateOrReplaceModel:(id<GCSCraftModel>)model
                               withCurrent:(GCSHeartbeat *)heartbeat {
    GCSCraftType craftType = [GCSCraftModelGenerator craftTypeFromHeartbeat:heartbeat];
    
    // Mutate the existing model
    if (craftType == model.craftType) {
        [model updateWithHeartbeat:heartbeat];
        return model;
    }
    
    // Return a new model
    switch (craftType) {
        case ArduCopter: return [[GCSCraftArduCopter alloc] init:heartbeat];
        case ArduPlane:  return [[GCSCraftArduPlane alloc] init:heartbeat];
        default: assert(false);
    }
}

@end
