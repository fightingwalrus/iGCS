//
//  RedparkSerialCable.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "RedparkSerialCable.h"
#import "MavLinkTools.h"
//#import "CommsViewController.h"

@implementation RedparkSerialCable


+(RedparkSerialCable*)createWithViews:(MainViewController*)mvc {
    RedparkSerialCable *rsc = [[RedparkSerialCable alloc] init];
    
    rsc.mainVC = mvc;
    
    // Start the Redpark Serial Cable Manager
    DDLogInfo(@"Redpark: Creating RscMgr.");
    rsc.rscMgr = [[RscMgr alloc] init];
    [rsc.rscMgr setDelegate:rsc];
    
    
    DDLogInfo(@"Redpark: RscMgr ready.");
    
    return rsc;
}

-(void)close {
    DDLogInfo(@"Redpark close method...");
}

-(void)consumeData:(uint8_t *)bytes length:(NSUInteger)length {
    NSInteger n = [self.rscMgr write:bytes Length:length];
    if (n == length) {
        DDLogDebug(@"send_uart_bytes: output %d chars", n);
    } else {
        DDLogError(@"send_uart_bytes: FAILED (only %d sent)", n);
    }
}


// RscMgrDelegate methods

// Redpark Serial Cable has been connected and/or application moved to foreground.
// protocol is the string which matched from the protocol list passed to initWithProtocol:
- (void) cableConnected:(NSString *)protocol {
    @try {
        DDLogInfo(@"Redpark: cableConnected");
        
        // Configure the serial connection
        [self.rscMgr setBaud:57600];
        [self.rscMgr setDataSize:SERIAL_DATABITS_8];
        [self.rscMgr setParity:SERIAL_PARITY_NONE];
        [self.rscMgr setStopBits:1];
        
        // Now open the serial communication session using the
        // serial port configuration options we've already set.
        // However, the baud rate, data size, parity, etc....
        // can be changed after calling open if needed.
        [self.rscMgr open];
        
        self.cableConnected = YES;
        [self.mainVC.commsVC setCableConnectionStatus: self.cableConnected];
    }
    @catch (NSException *exception) {
        [Logger dumpException:exception];
    }
}


// Redpark Serial Cable has been disconnected and/or application moved to background.
- (void) cableDisconnected {
    @try {
        DDLogInfo(@"Redpark: cableDisconnected");
        self.cableConnected = NO;
        [self.mainVC.commsVC setCableConnectionStatus:self.cableConnected];
    }
    @catch (NSException *exception) {
        [Logger dumpException:exception];
    }
}

// serial port status has changed
// user can call getModemStatus or getPortStatus to get current state
- (void) portStatusChanged {
    DDLogDebug(@"Redpark: portStatusChanged");
}

// bytes are available to be read (user calls read:)
- (void) readBytesAvailable:(UInt32)length {
    @try {
        // Read the available bytes out of the serial cable manager
        uint8_t buf[length];
        NSInteger n = [self.rscMgr read:(uint8_t*)&buf Length:length];
        [self produceData:buf length:n];
    }
    @catch (NSException *e) {
        [Logger dumpException:e];
    }
}

@end
