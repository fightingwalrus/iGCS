//
//  BluetoothStream.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkInterface.h"

@interface BluetoothStream : MavLinkInterface



+(BluetoothStream*)createForPeripheral;
+(BluetoothStream*)createForCentral;

@end
