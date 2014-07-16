//
//  RedparkSerialCable.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "RedparkSerialCable.h"
#import "MavLinkTools.h"

#import "Logger.h"

#import "CommsViewController.h"

#import "DebugViewController.h"

@implementation RedparkSerialCable


+(RedparkSerialCable*)createWithViews:(MainViewController*)mvc
{
    RedparkSerialCable *rsc = [[RedparkSerialCable alloc] init];
    
    rsc.mainVC = mvc;
    
    // Start the Redpark Serial Cable Manager
    [Logger console:@"Redpark: Creating RscMgr."];
    rsc.rscMgr = [[RscMgr alloc] init];
    [rsc.rscMgr setDelegate:rsc];
    
    
    [Logger console:@"Redpark: RscMgr ready."];
    
    
    return rsc;
}

-(void)close {
    NSLog(@"Redpark close method...");
}

-(void)consumeData:(uint8_t *)bytes length:(int)length
{
    //[Logger console:@"consumeData"];
    
    
    
    //[Logger console:[NSString stringWithFormat:@"send_uart_bytes: sending %i chars", length]];
    
    //[Logger console: @"rscMgr:"];
    //[Logger console: [self.rscMgr description]];
    
    int n = [self.rscMgr write:bytes Length:length];
    
    
    if (n == length)
    {
        //NSLog(@"send_uart_bytes: output %d chars", n);
    }
    else
    {
        //NSLog(@"send_uart_bytes: FAILED (only %d sent)", n);
    }
    
    
}


//RscMgr *rscMgr;
//static void send_uart_bytes(mavlink_channel_t chan, uint8_t *buffer, uint16_t len)
//-(void) send_uart_bytes:(uint8_t*)bytes channel:(mavlink_channel_t)channel length:(uint16_t)len
//{

    
     
//}










// RscMgrDelegate methods

// Redpark Serial Cable has been connected and/or application moved to foreground.
// protocol is the string which matched from the protocol list passed to initWithProtocol:
- (void) cableConnected:(NSString *)protocol
{
    @try {
        [Logger console:@"Redpark: cableConnected"];
        /*
         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"cableConnected"
         message:@"connecting..." delegate:nil
         cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show];
         */
        
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
- (void) cableDisconnected
{
    @try {
        [Logger console:@"Redpark: cableDisconnected"];
        self.cableConnected = NO;
        [self.mainVC.commsVC setCableConnectionStatus:self.cableConnected];
    }
    @catch (NSException *exception) {
        [Logger dumpException:exception];
    }
}

// serial port status has changed
// user can call getModemStatus or getPortStatus to get current state
- (void) portStatusChanged
{
    
    [Logger console:@"Redpark: portStatusChanged"];
}

// bytes are available to be read (user calls read:)
- (void) readBytesAvailable:(UInt32)length
{
    
    @try {
        // Read the available bytes out of the serial cable manager
        uint8_t buf[length];
        int n = [self.rscMgr read:(uint8_t*)&buf Length:length];
        
        
        
        //[Logger console:@"Redpark: readBytesAvailable"];
        [self produceData:buf length:n];
    }
    @catch (NSException *e)
    {
        [Logger dumpException:e];
    }
}




@end
