//
//  RedparkSerialCable.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "WiFlyInterface.h"
#import "MavLinkTools.h"
#import "Logger.h"
#import "CommsViewController.h"
#import "DebugViewController.h"

#import "GCDAsyncSocket.h"

#define HOST @"10.0.0.1" // 198.18.0.1 // 192.168.0.254 // 10.0.0.1
#define HOST_PORT 2000

@implementation WiFlyInterface


+(WiFlyInterface*)createWithViews:(MainViewController*)mvc
{
    WiFlyInterface *wifly = [[WiFlyInterface alloc] init];
    
    wifly.mainVC = mvc;
    
    // Start the Redpark Serial Cable Manager
    [Logger console:@"WiFly: Opening Socket."];
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
	wifly.socket = [[GCDAsyncSocket alloc] initWithDelegate:wifly delegateQueue:mainQueue];
    [wifly connectTo3DRRadio];
    
    return wifly;
}

- (void)connectTo3DRRadio
{
    NSString *host = HOST;
    uint16_t hostPort = HOST_PORT;
    
    NSLog(@"Connecting to \"%@\" on port %hu...", host, hostPort);
    NSError *error = nil;
    if (![self.socket connectToHost:host onPort:hostPort error:&error])
    {
        NSLog(@"Error connecting: %@", error);
        self.connected = NO;
    }
    else
    {
        NSLog(@"didConnectToHost:%@ port:%hu", host, hostPort);
        [self.socket readDataWithTimeout:-1 tag:0];
        self.connected = YES;
        [self.mainVC.commsVC setCableConnectionStatus:self.connected];
    }
}

-(void)consumeData:(uint8_t *)bytes length:(int)length
{
    [Logger console:@"consumeData"];
    NSLog(@"writing Data");
    //[Logger console:[NSString stringWithFormat:@"send_uart_bytes: sending %i chars", length]];
    
    [self.socket writeData:[NSData dataWithBytes:bytes length:length] withTimeout:1.0 tag:1];
}

#pragma mark - Socket Delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"delegate didConnectToHost:%@ port:%hu", host, port);
    self.connected = YES;
    [self.mainVC.commsVC setCableConnectionStatus:self.connected];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"didAcceptNewSocket:%@", newSocket);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	NSLog(@"didWriteDataWithTag:%ld", tag);
}

- (NSString *)hexStringFromData:(NSData *)data withNewLines:(int)newLinesCount
{
    // Build the hex string
    NSUInteger dataLength = [data length];
    NSMutableString *string = [NSMutableString stringWithCapacity:dataLength * 2];
    const unsigned char *dataBytes = [data bytes];
    for (int i = 0; i < dataLength; i ++)
    {
        [string appendFormat:@"0x%02x ", dataBytes[i]];
    }
    
    // Add the new lines
    for(int i = 0; i < newLinesCount; i ++)
    {
        [string appendString:@"\n"];
    }
    
    return (NSString *)string;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	//NSLog(@"didReadData:%@ withTag:%ld", [data description], tag);
    
    // Make a nice NSString with formatted hex data
    //NSString *string = [self hexStringFromData:data withNewLines:2];
    //NSLog(@"Response:%@", string);
    
    // Send the data up the chain
    [self produceData:(uint8_t *)[data bytes] length:[data length]];
    
    // Keep reading data
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"didReadPartialData:withTag:%ld", tag);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	NSLog(@"DidDisconnectWithError: %@", err);
    self.connected = NO;
    [self.mainVC.commsVC setCableConnectionStatus:self.connected];
}

@end
