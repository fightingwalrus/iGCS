//
//  FightingWalrusInterface.h
//  iGCS
//
//  Created by Andrew Brown on 9/22/13.
//
//

#import "CommInterface.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface FightingWalrusInterface : CommInterface <EAAccessoryDelegate, NSStreamDelegate>

@property (nonatomic, strong, readwrite) EAAccessory *selectedAccessory;
@property (nonatomic, copy) NSString *protocolString;
@property (strong) NSMutableData *writeDataBuffer;
@property (nonatomic, strong) NSNumber *doubleTab;

+(FightingWalrusInterface*)createWithProtocolString:(NSString *) protocolString;

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString;
- (BOOL)openSession;
- (void)closeSession;
- (void)writeData:(NSData *)data;
- (BOOL)isAccessoryConnected;

// from EAAccessoryDelegate and  notifications
- (void)accessoryDidDisconnect:(EAAccessory *)accessory;
- (void)accessoryConnected:(NSNotification *)notification;
- (void)accessoryDisconnected:(NSNotification *)notification;

@end

extern NSString * const GCSProtocolStringTelemetry;
extern NSString * const GCSProtocolStringConfig;
extern NSString * const GCSProtocolStringUpdate;

