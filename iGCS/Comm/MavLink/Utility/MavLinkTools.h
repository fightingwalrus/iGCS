//
//  MavLinkTools.h
//  MavLinkTest
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef MavLinkTest_MavLinkTools_h
#define MavLinkTest_MavLinkTools_h

#define MAVLINK_USE_CONVENIENCE_FUNCTIONS 1
#import "mavlink_types.h"
//#import "../mavlink-include/mavlink_types.h"
mavlink_system_t mavlink_system;

//#ifndef MAVLINK_SEPARATE_HELPERS
#define MAVLINK_SEND_UART_BYTES(chan, buffer, len) send_uart_bytes(chan, buffer, len)
static void send_uart_bytes(mavlink_channel_t chan, const uint8_t *buffer, uint16_t len);
//#endif
//#import "../mavlink-include/ardupilotmega/mavlink.h"
#import "mavlink.h"

/*
 ref: https://code.google.com/p/gentlenav/source/browse/branches/MatrixPilot_refactored/Tools/MAVLink/pymavlink/generator/C/test/posix/testmav.c?r=1420
 */
static const mavlink_message_info_t message_info[256] = MAVLINK_MESSAGE_INFO;

static NSString* primitiveFieldToNSString(mavlink_message_t *msg, const mavlink_field_info_t *f, int idx)
{
	switch (f->type) {
        case MAVLINK_TYPE_CHAR:
            return [NSString stringWithFormat:@"%c", _MAV_RETURN_char(msg, f->wire_offset+idx*1)];
            break;
        case MAVLINK_TYPE_UINT8_T:
            return [NSString stringWithFormat:@"%u", _MAV_RETURN_uint8_t(msg, f->wire_offset+idx*1)];
            break;
        case MAVLINK_TYPE_INT8_T:
            return [NSString stringWithFormat:@"%d", _MAV_RETURN_int8_t(msg, f->wire_offset+idx*1)];
            break;
        case MAVLINK_TYPE_UINT16_T:
            return [NSString stringWithFormat:@"%u", _MAV_RETURN_uint16_t(msg, f->wire_offset+idx*2)];
            break;
        case MAVLINK_TYPE_INT16_T:
            return [NSString stringWithFormat:@"%d", _MAV_RETURN_int16_t(msg, f->wire_offset+idx*2)];
            break;
        case MAVLINK_TYPE_UINT32_T:
            return [NSString stringWithFormat:@"%lu", (unsigned long)_MAV_RETURN_uint32_t(msg, f->wire_offset+idx*4)];
            break;
        case MAVLINK_TYPE_INT32_T:
            return [NSString stringWithFormat:@"%ld", (long)_MAV_RETURN_int32_t(msg, f->wire_offset+idx*4)];
            break;
        case MAVLINK_TYPE_UINT64_T:
            return [NSString stringWithFormat:@"%llu", (unsigned long long)_MAV_RETURN_uint64_t(msg, f->wire_offset+idx*8)];
            break;
        case MAVLINK_TYPE_INT64_T:
            return [NSString stringWithFormat:@"%lld", (long long)_MAV_RETURN_int64_t(msg, f->wire_offset+idx*8)];
            break;
        case MAVLINK_TYPE_FLOAT:
            return [NSString stringWithFormat:@"%f", (double)_MAV_RETURN_float(msg, f->wire_offset+idx*4)];
            break;
        case MAVLINK_TYPE_DOUBLE:
            return [NSString stringWithFormat:@"%f", _MAV_RETURN_double(msg, f->wire_offset+idx*8)];
            break;
	}
    return @"";
}

static NSString* fieldToNSString(mavlink_message_t *msg, const mavlink_field_info_t *f, bool prettyPrint)
{
	NSString *s = [NSString stringWithFormat:(prettyPrint ? @"%14s: " : @"%s: "), f->name];    
	if (f->array_length == 0) {
        s = [s stringByAppendingFormat:@"%@ ", primitiveFieldToNSString(msg, f, 0)];        
	} else {
		unsigned i;
		/* print an array */
		if (f->type == MAVLINK_TYPE_CHAR) {
			s = [s stringByAppendingFormat:@"'%.*s'", f->array_length, f->wire_offset+(const char *)_MAV_PAYLOAD(msg)];
		} else {
			s = [s stringByAppendingString:@"[ "];
			for (i=0; i<f->array_length; i++) {
				s = [s stringByAppendingString: primitiveFieldToNSString(msg, f, i)];
				if (i < f->array_length) {
					s = [s stringByAppendingString:@", "];
				}
			}
			s = [s stringByAppendingString:@"]"];
		}
	}
    return s;
}

static NSString* msgToNSString(mavlink_message_t *msg, bool prettyPrint)
{
	const mavlink_message_info_t *m = &message_info[msg->msgid];
	const mavlink_field_info_t *f = m->fields;
    NSString *s = [NSString stringWithFormat:@"%s { ", m->name];
    if (prettyPrint) s = [s stringByAppendingString:@"\n"];
	for (unsigned int i=0; i<m->num_fields; i++) {
		s = [s stringByAppendingFormat:@"%@ ", fieldToNSString(msg, &f[i], prettyPrint)];
        if (prettyPrint) s = [s stringByAppendingString:@"\n"];
	}
	s = [s stringByAppendingString:@"}"];
    return s;
}

/*
ref: ArduPlane defines.h 
 */

// ArduPlane Auto Pilot modes
// ----------------
#define MANUAL 0
#define CIRCLE 1                         // When flying sans GPS, and we loose the radio, just circle
#define STABILIZE 2

#define FLY_BY_WIRE_A 5         // Fly By Wire A has left stick horizontal => desired roll angle, left stick vertical => desired pitch angle, right stick vertical = manual throttle
#define FLY_BY_WIRE_B 6         // Fly By Wire B has left stick horizontal => desired roll angle, left stick vertical => desired pitch angle, right stick vertical => desired airspeed
#define FLY_BY_WIRE_C 7         // Fly By Wire C has left stick horizontal => desired roll angle, left stick vertical => desired climb rate, right stick vertical => desired airspeed
// Fly By Wire B and Fly By Wire C require airspeed sensor
#define AUTO 10
#define RTL 11
#define LOITER 12
#define TAKEOFF 13                    // This is not used by APM.  It appears here for consistency with ACM
#define LAND 14                       // This is not used by APM.  It appears here for consistency with ACM
#define GUIDED 15
#define INITIALISING 16     // in startup routines

#endif


// ArduCopter Auto Pilot Modes
typedef NS_ENUM(uint32_t, GCSArduCopterModes) {
    Stabilize = 0,  // hold level position
    Acro = 1,       // rate control
    AltHold = 2,    // AUTO control
    Auto = 3,       // AUTO control
    Guided = 4,     // AUTO control
    Loiter = 5,     // Hold a single location
    Rtl = 6,        // AUTO control
    Circle = 7,     // AUTO control
    Position = 8,   // AUTO control
    Land = 9,       // AUTO control
    OfLoiter = 10,  // Hold a single location using optical flow sensor
    Drift = 11,     // DRIFT mode (Note: 12 is no longer used)
    Sport = 13,     // earth frame rate control
    NumModes = 14
};
