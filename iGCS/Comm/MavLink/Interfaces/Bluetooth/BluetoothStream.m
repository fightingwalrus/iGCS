//
//  BluetoothStream.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "BluetoothStream.h"

@implementation BluetoothStream



+(BluetoothStream*) createForTx
{
    NSLog(@"Creating BluetoothStream for Peripheral mode (Tx).");
    
    BluetoothStream *bts = [[BluetoothStream alloc] init];
    
    // BTLE usage
    //bts.streamPeripheral = [[BTLEMavLinkPeripheral alloc] init];
    
    // GKSession usage
    GKSessionController *gkSessionController = [[GKSessionController alloc] init:bts];
    bts.gkSessionController = gkSessionController;  
    
    return bts;
}


+(BluetoothStream*) createForRx
{
    NSLog(@"Creating BluetoothStream for Central mode (Rx).");
    
    BluetoothStream *bts = [[BluetoothStream alloc] init];
    
    // BTLE usage
    //bts.streamCentral = [[BTLEMavLinkCentral alloc] init];
    
    
    // GKSession usage
    GKSessionController *gkSessionController = [[GKSessionController alloc] init:bts];
    bts.gkSessionController = gkSessionController;
    
    
    return bts;
}






#pragma mark -
#pragma mark MavLinkInterface methods


// MavLinkInterface destination override (used for Tx)
-(void)consumeData:(uint8_t*)bytes length:(int)length
{
    if (self.gkSessionController)
    {
        [self.gkSessionController sendMavlinkData:bytes length:length];
    }
}







-(void) close
{
    if (self.streamCentral)
    {
        [self.streamCentral stopScan];
    }
    
    if (self.streamPeripheral)
    {
        [self.streamPeripheral stopStream];
    }
}




@end
