//
//  MavLinkConnectionPool.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkInterface.h"

@interface MavLinkConnectionPool : NSObject


-(void)addOutput:(MavLinkInterface*)connection;
-(void)addInput:(MavLinkInterface*)connection;

@end
