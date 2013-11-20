//
//  BluetoothStream.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>
#import "CommInterface.h"

#import "BTLEMavLinkCentral.h"
#import "BTLEMavLinkPeripheral.h"
#import "GKLocalController.h"


@interface BluetoothStream : CommInterface

@property (strong) BTLEMavLinkCentral *streamCentral;
@property (strong) BTLEMavLinkPeripheral *streamPeripheral;

@property (strong) GKLocalController *gkLocalController;

+(BluetoothStream*)createForTx;
+(BluetoothStream*)createForRx;

@end
