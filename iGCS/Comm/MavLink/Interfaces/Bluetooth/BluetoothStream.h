//
//  BluetoothStream.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkInterface.h"

#import "BTLEMavLinkCentral.h"
#import "BTLEMavLinkPeripheral.h"
#import "GKSessionController.h"


@interface BluetoothStream : MavLinkInterface




@property (strong) BTLEMavLinkCentral *streamCentral;
@property (strong) BTLEMavLinkPeripheral *streamPeripheral;

@property (strong) GKSessionController *gkSessionController;

+(BluetoothStream*)createForTx;
+(BluetoothStream*)createForRx;

@end
