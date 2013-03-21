//
//  GKSessionController.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/25/13.
//
//

#import "GKLocalController.h"

#import <GameKit/GameKit.h>

#import "BluetoothStream.h"

#import "Logger.h"


#define kMaxPacketSize 1024
#define kGCSSessionID @"groundStation"



@interface GKLocalController () <GKSessionDelegate,GKPeerPickerControllerDelegate> {
    int				gamePacketNumber;
    int				gameUniqueID;
}


@property (strong) BluetoothStream *parentStream;

@property(nonatomic) NSInteger		gameState;
@property(nonatomic) NSInteger		peerStatus;

@property(nonatomic, retain) GKSession	 *gameSession;
@property(nonatomic, copy)	 NSString	 *gamePeerId;

@property(nonatomic, retain) NSDate		 *lastHeartbeatDate;
@property(nonatomic, retain) UIAlertView *connectionAlert;

@end

@implementation GKLocalController




-(id)init:(BluetoothStream*)bts
{
    self = [super init];
    if (self)
    {
        self.parentStream = bts;
        
        
        GKPeerPickerController*		picker;
        
        picker = [[GKPeerPickerController alloc] init]; // note: picker is released in various picker delegate methods when picker use is done.
        picker.delegate = self;
        [picker show]; // show the Peer Picker
    }
    return self;
}




-(void)sendMavlinkData:(uint8_t*)bytes length:(int)length
{
    NSLog(@"GKSessionController: Sending MavLink bytes: %i",length);
    [self sendNetworkPacket:self.gameSession packetID:NETWORK_MAVLINK withData:bytes ofLength:length reliable:YES];
    
}










#pragma mark -
#pragma mark Peer Picker Related Methods

-(void)startPicker {
	GKPeerPickerController*		picker;
	
	self.gameState = kStatePicker;			// we're going to do Multiplayer!
	
	picker = [[GKPeerPickerController alloc] init]; // note: picker is released in various picker delegate methods when picker use is done.
	picker.delegate = self;
	[picker show]; // show the Peer Picker
}

#pragma mark GKPeerPickerControllerDelegate Methods

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
	// Peer Picker automatically dismisses on user cancel. No need to programmatically dismiss.
    
	// autorelease the picker.
	picker.delegate = nil;
	
	// invalidate and release game session if one is around.
	if(self.gameSession != nil)	{
		[self invalidateSession:self.gameSession];
		self.gameSession = nil;
	}
	
	// go back to start mode
	self.gameState = kStateStartGame;
}

/*
 *	Note: No need to implement -peerPickerController:didSelectConnectionType: delegate method since this app does not support multiple connection types.
 *		- see reference documentation for this delegate method and the GKPeerPickerController's connectionTypesMask property.
 */

//
// Provide a custom session that has a custom session ID. This is also an opportunity to provide a session with a custom display name.
//
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
	GKSession *session = [[GKSession alloc] initWithSessionID:kGCSSessionID displayName:nil sessionMode:GKSessionModePeer];
	return session; // peer picker retains a reference, so autorelease ours so we don't leak.
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
	// Remember the current peer.
	self.gamePeerId = peerID;  // copy
	
	// Make sure we have a reference to the game session and it is set up
	self.gameSession = session; // retain
	self.gameSession.delegate = self;
	[self.gameSession setDataReceiveHandler:self withContext:NULL];
	
	// Done with the Peer Picker so dismiss it.
	[picker dismiss];
	picker.delegate = nil;
	
	// Start Multiplayer game by entering a cointoss state to determine who is server/client.
	self.gameState = kStateMultiplayerCointoss;
}

#pragma mark -
#pragma mark Session Related Methods

//
// invalidate session
//
- (void)invalidateSession:(GKSession *)session {
	if(session != nil) {
		[session disconnectFromAllPeers];
		session.available = NO;
		[session setDataReceiveHandler: nil withContext: NULL];
		session.delegate = nil;
	}
}

#pragma mark Data Send/Receive Methods

/*
 * Getting a data packet. This is the data receive handler method expected by the GKSession.
 * We set ourselves as the receive data handler in the -peerPickerController:didConnectPeer:toSession: method.
 */
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {
	static int lastPacketTime = -1;
	unsigned char *incomingPacket = (unsigned char *)[data bytes];
	int *pIntData = (int *)&incomingPacket[0];
	//
	// developer  check the network time and make sure packers are in order
	//
	int packetTime = pIntData[0];
	int packetID = pIntData[1];
	if(packetTime < lastPacketTime && packetID != NETWORK_COINTOSS) {
		return;
	}
    
    //NSLog(@"GKSession receiveData: %i bytes",[data length]);
	
	lastPacketTime = packetTime;
	switch( packetID ) {
		case NETWORK_COINTOSS:
        {
            // coin toss to determine roles of the two players
            int coinToss = pIntData[2];
            // if other player's coin is higher than ours then that player is the server
            if(coinToss > gameUniqueID) {
                self.peerStatus = kClient;
            }
        }
			break;
		case NETWORK_HEARTBEAT:
        {
            // Received heartbeat data with other player's position, destination, and firing status.
            
            /*
             // update the other player's info from the heartbeat
             tankInfo *ts = (tankInfo *)&incomingPacket[8];		// tank data as seen on other client
             int peer = (self.peerStatus == kServer) ? kClient : kServer;
             tankInfo *ds = &tankStats[peer];					// same tank, as we see it on this client
             memcpy( ds, ts, sizeof(tankInfo) );
             */
            
            // update heartbeat timestamp
            self.lastHeartbeatDate = [NSDate date];
            
            // if we were trying to reconnect, set the state back to multiplayer as the peer is back
            if(self.gameState == kStateMultiplayerReconnect) {
                if(self.connectionAlert && self.connectionAlert.visible) {
                    [self.connectionAlert dismissWithClickedButtonIndex:-1 animated:YES];
                }
                self.gameState = kStateMultiplayer;
            }
        }
            
        case NETWORK_MAVLINK:
        {
            //NSLog(@"GKSession: Received MavLink: %i bytes",[data length]);
            
            int headerSize = 2 * sizeof(int);
            uint8_t *mavlinkData = (uint8_t*)&incomingPacket[headerSize];
            int mavlinkSize = [data length] - headerSize;
            
            // TODO: Refactor to delegate interface to parentStream can be eliminated
            [self.parentStream produceData:mavlinkData length:mavlinkSize];
            
        }
			break;
		default:
			// error
			break;
	}
}

- (void)sendNetworkPacket:(GKSession *)session packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend
{
    //[Logger console:[NSString stringWithFormat:@"GKSession: sending %i bytes.",length]];
	// the packet we'll send is resued
	static unsigned char networkPacket[kMaxPacketSize];
	const unsigned int packetHeaderSize = 2 * sizeof(int); // we have two "ints" for our header
	
	if(length < (kMaxPacketSize - packetHeaderSize)) { // our networkPacket buffer size minus the size of the header info
		int *pIntData = (int *)&networkPacket[0];
		// header info
		pIntData[0] = gamePacketNumber++;
		pIntData[1] = packetID;
		// copy data in after the header
		memcpy( &networkPacket[packetHeaderSize], data, length );
		
		NSData *packet = [NSData dataWithBytes: networkPacket length: (length+8)];
		if(howtosend == YES) {
			[session sendData:packet toPeers:[NSArray arrayWithObject:self.gamePeerId] withDataMode:GKSendDataReliable error:nil];
		} else {
			[session sendData:packet toPeers:[NSArray arrayWithObject:self.gamePeerId] withDataMode:GKSendDataUnreliable error:nil];
		}
	}
}

#pragma mark GKSessionDelegate Methods

// we've gotten a state change in the session
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	if(self.gameState == kStatePicker) {
		return;				// only do stuff if we're in multiplayer, otherwise it is probably for Picker
	}
	
	if(state == GKPeerStateDisconnected) {
		// We've been disconnected from the other peer.
		
		// Update user alert or throw alert if it isn't already up
		NSString *message = [NSString stringWithFormat:@"Could not reconnect with %@.", [session displayNameForPeer:peerID]];
		if((self.gameState == kStateMultiplayerReconnect) && self.connectionAlert && self.connectionAlert.visible) {
			self.connectionAlert.message = message;
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:message delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:nil];
			self.connectionAlert = alert;
			[alert show];
		}
		
		// go back to start mode
		self.gameState = kStateStartGame;
	}
}





@end
