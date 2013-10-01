//
//  FightingWalrusInterface.h
//  iGCS
//
//  Created by Andrew Brown on 9/22/13.
//
//

#import "CommInterface.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface FightingWalrusInterface : CommInterface <EAAccessoryDelegate, NSStreamDelegate> {
    
    NSMutableArray *_accessoryList;
    EAAccessory *_selectedAccessory;
    EASession *_session;
    NSString *_protocolString;
    
    NSMutableData *_writeDataBuffer;
}

@property (nonatomic, retain, readonly) EAAccessory *selectedAccessory;
@property (nonatomic, copy) NSString *protocolString;
@property (retain) NSMutableData *writeDataBuffer;

+(FightingWalrusInterface*)create;


- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString;

- (BOOL)openSession;
- (void)closeSession;

- (void)writeData:(NSData *)data;

- (BOOL)isAccessoryConnected;

// from EAAccessoryDelegate
- (void)accessoryDidDisconnect:(EAAccessory *)accessory;

// from EAAccessory notifications
- (void)accessoryConnected:(NSNotification *)notification;
- (void)accessoryDisconnected:(NSNotification *)notification;


@end
