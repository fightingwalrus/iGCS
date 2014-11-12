//
//  GKSessionController.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/25/13.
//
//

#import <Foundation/Foundation.h>

@class BluetoothStream;

typedef NS_ENUM(NSInteger, gameStates) {
	kStateStartGame,
	kStatePicker,
	kStateMultiplayer,
	kStateMultiplayerCointoss,
	kStateMultiplayerReconnect
} ;

typedef NS_ENUM(NSInteger, packetCodes) {
	NETWORK_ACK,					// no packet
	NETWORK_COINTOSS,				// decide who is going to be the server
	NETWORK_MOVE_EVENT,				// send position
	NETWORK_FIRE_EVENT,				// send fire
	NETWORK_HEARTBEAT,				// send of entire state at regular intervals
    NETWORK_MAVLINK
} ;

typedef NS_ENUM(NSInteger, gameNetwork) {
	kServer,
	kClient
} ;

@interface GKLocalController : NSObject

-(instancetype)init:(BluetoothStream*)bts NS_DESIGNATED_INITIALIZER;
-(void)sendMavlinkData:(const uint8_t*)bytes length:(NSInteger)length;

@end
