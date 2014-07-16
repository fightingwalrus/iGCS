//
//  RscMgr.h
//
//  Copyright © 2011 Redpark  All Rights Reserved
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessoryDefines.h>
#import <ExternalAccessory/EAAccessoryManager.h>
#import <ExternalAccessory/EAAccessory.h>
#import <ExternalAccessory/EASession.h>

#include "redparkSerial.h"



enum
{	
 	kMsrCts = 0x01,
	kMsrRi =  0x02,
 	kMsrDsr = 0x04,
 	kMsrDcd = 0x08,
 
};

enum {
	kRSC_StreamBufferSize = 1024,
	kRSC_MaxMessageDataLength = 230,
	kRSC_SerialReadBufferSize = 1024,
	kRSC_NoPasscode = 0
};


typedef enum DataSizeType
{
	kDataSize7 = SERIAL_DATABITS_7,
	kDataSize8 = SERIAL_DATABITS_8
} DataSizeType;

typedef enum ParityType
{
	kParityNone = SERIAL_PARITY_NONE,
	kParityOdd = SERIAL_PARITY_ODD,
	kParityEven = SERIAL_PARITY_EVEN
} ParityType;

typedef enum StopBitsType
{
	kStopBits1 = STOPBITS_1,
	kStopBits2 = STOPBITS_2
} StopBitsType;

typedef struct rscMsgHdr
{
	unsigned char hdr1;
	unsigned char hdr2;
	unsigned char len;			// of data following 'cmd'
	unsigned char cmd;
	
} rscMsgHdr;



@protocol RscMgrDelegate;

@interface RscMgr : NSObject <NSStreamDelegate> {

	id <RscMgrDelegate> theDelegate;
	
	// EA api variables
	EASession *theSession;
	EAAccessory *theAccessory;
	NSArray *supportedProtocols;
	NSString *connectedProtocol;
	
	// rsc port control/info structures
	serialPortConfig portConfig;
	serialPortStatus portStatus;
	serialPortControl portControl;
	
	// EASession stream handling
	// for collecting RSC Messages
	unsigned char *rxStreamBuffer;
	int rxCount;
	int rxCountTotal;
	int txCountTotal;
	int rxRemain;
	int readLen;
	
	unsigned char *txStreamBuffer;
	int txIn;
	int txOut;
	int txStreamEmpty;
	
	// internal dtr and rts state bits
	int dtrState;
	int rtsState;	
	
	// serial data buffer
	// for collecting serial bytes received from the serial port
	UInt8 *serialReadBuffer;
	int serialReadIn;
	int serialReadOut;
	int serialReadBytesAvailable;
	
	BOOL encodingEnabled;	
	UInt32 thePasscode;
	
}
	
- (void) setDelegate:(id <RscMgrDelegate>) delegate;


// Initializes the RscMgr and reigsters for accessory connect/disconnect notifications. 
- (id) init;

// establish communication with the Redpark Serial Cable.  This call will also
// configure the serial port based on defaults or prior calls to set the port config
// (see setBaud, setDataSize, ...)
- (void) open;

// simple serial port config interface
// can be called anytime (even after open: call)
- (void) setBaud:(int)baud;
- (void) setDataSize:(DataSizeType)dataSize;
- (void) setParity:(ParityType)parity;
- (void) setStopBits:(StopBitsType)stopBits;

// read write serial bytes
- (int) write:(UInt8 *)data Length:(UInt32)length;
- (int) read:(UInt8 *)data Length:(UInt32)length;
- (int) getReadBytesAvailable;

/* 
 returns a bit field (see redparkSerial.h)
 0-3 current modem status bits for CTS, RI, DSR, DCD, 4-7 previous modem status bits

 MODEM_STAT_CTS  0x01
 MODEM_STAT_RI   0x02
 MODEM_STAT_DSR  0x04
 MODEM_STAT_DCD  0x08
 */
- (int) getModemStatus;

// returns true if DTR is asserted
- (BOOL) getDtr;

// returns true if RTS is asserted
- (BOOL) getRts;

// set DTR state 
- (void) setDtr:(BOOL)enable;

// set RTS state
- (void) setRts:(BOOL)enable;

// advanced (full) serial port config interface (see redparkSerial.h)
- (void) setPortConfig:(serialPortConfig *)config RequestStatus:(BOOL)reqStatus;
- (void) setPortControl:(serialPortControl *)control RequestStatus:(BOOL)reqStatus;
- (void) getPortConfig:(serialPortConfig *) portConfig;
- (void) getPortStatus:(serialPortStatus *) portStatus;

// advanced advanced
// write a raw message
- (int) writeRscMessage:(int)cmd Length:(int)len MsgData:(UInt8 *)msgData;
	
@end

@protocol RscMgrDelegate  <NSObject>

// Redpark Serial Cable has been connected and/or application moved to foreground.
// protocol is the string which matched from the protocol list passed to initWithProtocol:
- (void) cableConnected:(NSString *)protocol;

// Redpark Serial Cable was disconnected and/or application moved to background
- (void) cableDisconnected;

// serial port status has changed
// user can call getModemStatus or getPortStatus to get current state
- (void) portStatusChanged;

// bytes are available to be read (user calls read:)
- (void) readBytesAvailable:(UInt32)length;



@end