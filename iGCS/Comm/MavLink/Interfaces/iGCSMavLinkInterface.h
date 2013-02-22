//
//  iGCSMavLinkInterface.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>
#import "CommController.h"

@interface iGCSMavLinkInterface : MavLinkInterface

+(iGCSMavLinkInterface*)createWithReceiveBlock:(MavLinkReceivedBlock)block;


@end
