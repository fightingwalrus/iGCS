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


@interface BluetoothStream : MavLinkInterface



@property (strong) BTLEMavLinkCentral *streamCentral;
@property (strong) BTLEMavLinkPeripheral *streamPeripheral;



+(BluetoothStream*)createForPeripheral;
+(BluetoothStream*)createForCentral;

@end
