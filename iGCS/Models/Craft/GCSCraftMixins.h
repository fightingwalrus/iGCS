//
//  GCSCraftMixins.h
//  iGCS
//
//  Created by Andrew Brown on 1/28/15.
//
//

#import <Foundation/Foundation.h>
#import "GCSCraft.h"

void updateWithHeartbeatIMP (id self, SEL _cmd, mavlink_heartbeat_t heartbeat);

@interface GCSCraftMixins : NSObject
+ (void) addMixinsToModel:(id<GCSCraftModel>)craftModel;
@end
