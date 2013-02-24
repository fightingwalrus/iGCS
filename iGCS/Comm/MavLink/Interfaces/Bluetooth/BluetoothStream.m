//
//  BluetoothStream.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "BluetoothStream.h"

@implementation BluetoothStream


+(BluetoothStream*)createForPeripheral
{
    NSLog(@"Creating BluetoothStream for Peripheral mode (Tx).");
    
    BluetoothStream *bts = [[BluetoothStream alloc] init];
    
    return bts;
}


+(BluetoothStream*)createForCentral
{
    NSLog(@"Creating BluetoothStream for Central mode (Rx).");
    
    BluetoothStream *bts = [[BluetoothStream alloc] init];
    
    return bts;
}







@end
