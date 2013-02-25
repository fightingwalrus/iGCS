//
//  BluetoothStream.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "BluetoothStream.h"

@implementation BluetoothStream


+(BluetoothStream*) createForPeripheral
{
    NSLog(@"Creating BluetoothStream for Peripheral mode (Tx).");
    
    BluetoothStream *bts = [[BluetoothStream alloc] init];
    
    bts.streamPeripheral = [[BTLEMavLinkPeripheral alloc] init];
    
    return bts;
}


+(BluetoothStream*) createForCentral
{
    NSLog(@"Creating BluetoothStream for Central mode (Rx).");
    
    BluetoothStream *bts = [[BluetoothStream alloc] init];
    
    bts.streamCentral = [[BTLEMavLinkCentral alloc] init];
    
    return bts;
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
