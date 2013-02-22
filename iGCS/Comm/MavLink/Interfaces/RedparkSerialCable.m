//
//  RedparkSerialCable.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import "RedparkSerialCable.h"

@implementation RedparkSerialCable


+(RedparkSerialCable*)createConnection
{
    RedparkSerialCable *rsc = [[RedparkSerialCable alloc] init];
    
    return rsc;
}

@end
