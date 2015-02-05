//
//  GCSCraftMixins.h
//  iGCS
//
//  Created by Andrew Brown on 1/28/15.
//
//

#import <Foundation/Foundation.h>
#import "GCSCraft.h"

@interface GCSCraftMixins : NSObject
-(void)updateWithHeartbeat:(mavlink_heartbeat_t) heartbeat;
- (NSString *) currentModeName;
@end
