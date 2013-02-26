//
//  FightingWalrusMFI.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/23/13.
//
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>


#define MFI_UNKNOWN_HW 0
#define	MFI_8_BIT_HW 2
#define MFI_16_BIT_HW 3




@interface FightingWalrusMFI : NSObject <EAAccessoryDelegate, NSStreamDelegate>
{
    uint8_t appMajorVersion;
    uint8_t appMinorVersion;
    uint8_t appRev;
    
	NSString *theProtocol;
	
    EASession *eas;
    BOOL streamReady;
    BOOL receivedAccPkt;
    NSMutableData *rxData;
    NSMutableData *txData;
    NSData *FSresponse_data;
}
- (id) initWithProtocol:(NSString *)protocol;
- (void) queueTxBytes:(NSData *)buf;
- (void) txBytes;
- (void) rxBytes:(const void *)buf length:(int)len;
- (EASession *)openSessionForProtocol:(NSString *)protocolString;
- (void)accessoryDidDisconnect:(NSNotification *)notification;
- (void)accessoryDidConnect:(NSNotification *)notification;
- (bool) isConnected;
- (NSString *) name;
- (NSString *) manufacturer;
- (NSString *) modelNumber;
- (NSString *) serialNumber;
- (NSString *) firmwareRevision;
- (NSString *) hardwareRevision;
// You implement this function

- (int) readData:(NSData *) data;

@end
