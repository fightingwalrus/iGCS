//
//  GCSCraftMixins.h
//  iGCS
//
//  Created by Andrew Brown on 1/28/15.
//
//

#import <Foundation/Foundation.h>
#import "GCSCraft.h"
#import "GCSHeartbeat.h"

@interface GCSCraftMixins : NSObject
-(void)updateWithHeartbeat:(GCSHeartbeat *) heartbeat;
- (NSString *) currentModeName;
@end
