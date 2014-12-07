//
//  GCSMavlinkManager.h
//  iGCS
//
//  Created by Andrew Brown on 12/6/14.
//
//

#import <Foundation/Foundation.h>

@interface GCSMavLinkManager : NSObject
+(GCSMavLinkManager *)sharedInstance;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;
@end
