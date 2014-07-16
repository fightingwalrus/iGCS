//
//  GKSessionController.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/25/13.
//
//

#import <Foundation/Foundation.h>

@class BluetoothStream;


typedef enum {
	kStateStartGame,
	kStatePicker,
	kStateMultiplayer,
	kStateMultiplayerCointoss,
	kStateMultiplayerReconnect
} gameStates;

typedef enum {
	NETWORK_ACK,					// no packet
	NETWORK_COINTOSS,				// decide who is going to be the server
	NETWORK_MOVE_EVENT,				// send position
	NETWORK_FIRE_EVENT,				// send fire
	NETWORK_HEARTBEAT,				// send of entire state at regular intervals
    NETWORK_MAVLINK
} packetCodes;

typedef enum {
	kServer,
	kClient
} gameNetwork;




@interface GKLocalController : NSObject


-(id)init:(BluetoothStream*)bts;
-(void)sendMavlinkData:(const uint8_t*)bytes length:(int)length;


@end
