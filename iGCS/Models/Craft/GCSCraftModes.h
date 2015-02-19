//
//  GCSCraftModes.h
//  iGCS
//
//  Created by Andrew Brown on 1/22/15.
//
//

#ifndef iGCS_GCSCraftModes_h
#define iGCS_GCSCraftModes_h

#pragma mark - Craft types

// At some point, we may need to partition these by version too
typedef NS_ENUM(NSUInteger, GCSCraftType) {
    ArduPlane,
    ArduCopter
};


#pragma mark - APM Mode enums
// ref: ArduPlane defines.h
// APM:Plane Auto Pilot Modes
typedef NS_ENUM(uint32_t, APMPlaneMode) {
    APMPlaneManual = 0,

    // When flying sans GPS, and we loose the radio, just circle
    APMPlaneCircle = 1,
    APMPlaneStabilize = 2,

    // Fly By Wire A has left stick horizontal => desired roll angle,
    // left stick vertical => desired pitch angle,
    // right stick vertical = manual throttle
    APMPlaneFlyByWireA = 5,

    // Fly By Wire B has left stick horizontal => desired roll angle,
    // left stick vertical => desired pitch angle,
    // right stick vertical => desired airspeed

    APMPlaneFlyByWireB = 6,

    // Fly By Wire C has left stick horizontal => desired roll angle,
    // left stick vertical => desired climb rate,
    // right stick vertical => desired airspeed
    // Fly By Wire B and Fly By Wire C require airspeed sensor
    APMPlaneFlyByWireC = 7,

    APMPlaneAuto = 10,
    APMPlaneRtl = 11,
    APMPlaneLoiter = 12,

    // This is not used by APM.  It appears here for consistency with ACM
    APMPlaneTakeoff = 13,
    // This is not used by APM.  It appears here for consistency with ACM
    APMPlaneLand = 14,

    APMPlaneGuided = 15,
    APMPlaneInitialising = 16,
    NumModes = 17
};

// APM:Copter Auto Pilot Modes
typedef NS_ENUM(uint32_t, APMCopterMode) {
    APMCopterStabilize = 0,  // hold level position
    APMCopterAcro = 1,       // rate control
    APMCopterAltHold = 2,    // AUTO control
    APMCopterAuto = 3,       // AUTO control
    APMCopterGuided = 4,     // AUTO control
    APMCopterLoiter = 5,     // Hold a single location
    APMCopterRtl = 6,        // AUTO control
    APMCopterCircle = 7,     // AUTO control
    APMCopterPosition = 8,   // AUTO control
    APMCopterLand = 9,       // AUTO control
    APMCopterOfLoiter = 10,  // Hold a single location using optical flow sensor
    APMCopterDrift = 11,     // DRIFT mode (Note: 12 is no longer used)
    APMCopterSport = 13,     // earth frame rate control
    APMCopterModeCount = 14
};

#endif
