//
//  FightingWalrusInterface.h
//  iGCS
//
//  Created by Andrew Brown on 9/22/13.
//
//

#import "CommInterface.h"
#import <ExternalAccessory/ExternalAccessory.h>

extern NSString * const GCSRadioConfigInterfaceOpen;

@interface FightingWalrusInterface : CommInterface <EAAccessoryDelegate, NSStreamDelegate> {
    NSMutableArray *_accessoryList;
    EAAccessory *_selectedAccessory;
    EASession *_session;
    NSString *_protocolString;
    NSString *_enabledAccessoryProtocol;
    NSArray *_supportedAccessoryProtocols;
    NSMutableData *_writeDataBuffer;

}

@property (nonatomic, retain, readonly) EAAccessory *selectedAccessory;
@property (nonatomic, copy) NSString *protocolString;
@property (retain) NSMutableData *writeDataBuffer;
@property (nonatomic, strong) NSNumber *doubleTab;

+(FightingWalrusInterface*)createWithProtocolString:(NSString *) protocolString;

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

extern NSString * const GCSProtocolStringTelemetry;
extern NSString * const GCSProtocolStringConfig;

