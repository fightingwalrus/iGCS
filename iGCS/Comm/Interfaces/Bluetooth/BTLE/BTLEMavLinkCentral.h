//
//  BTLEMavLinkCentral.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/24/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BTLEMavLinkCentral : NSObject

-(void)startScan;
-(void)stopScan;

@end
