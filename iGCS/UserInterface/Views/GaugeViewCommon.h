//
//  GaugeViewCommon.h
//  iGCS
//
//  Created by Claudio Natoli on 12/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef iGCS_GaugeViewCommon_h
#define iGCS_GaugeViewCommon_h

// Default data rates
#define RATE_CHAN2        5  // SYS_STATUS, GPS_STATUS, WAYPOINT_CURRENT, GPS_RAW
#define RATE_GPS_POS_INT  5
#define RATE_ATTITUDE    10
#define RATE_VFR_HUD      5
#define RATE_EXTRA3       1

// High data rates
/*
#define RATE_CHAN2        1  // SYS_STATUS, GPS_STATUS, WAYPOINT_CURRENT, GPS_RAW
#define RATE_GPS_POS_INT  10
#define RATE_ATTITUDE     30
#define RATE_VFR_HUD      5
#define RATE_EXTRA3       1
 */


#define RATE_RAW_SENSORS  5
#define RATE_RC_CHANNELS  1
#define RATE_RAW_CONTROLLER 1


// Conversion factors
#define DEG2RAD (M_PI/180.0)
#define RAD2DEG (180.0/M_PI)

// Common colours
#define GROUND_COLOUR 0.6, 0.4, 0.1, 1.0
#define SKY_COLOUR    0.1, 0.6, 1.0, 1.0
#define ORANGE_COLOUR 1.0, 0.65,0.0, 1.0
#define CHEVRON_BORDER_COLOUR 0.75, 0.3, 0.3, 1.0
#define SHADOW_COLOUR 0.3, 0.3, 0.3, 0.3

// Enable debug animation
#define DO_NSLOG        0
#define DO_ANIMATION    0
#define ANIMATION_TIMER 0.1

#define AH_ROT_ANGLE    0.0
#define AH_ROT_PER_STEP (5.0/1.0)
#define AH_PITCH_ANGLE  10

#define COMPASS_STEP 1

#define VSS_STEP 0.05

#endif
