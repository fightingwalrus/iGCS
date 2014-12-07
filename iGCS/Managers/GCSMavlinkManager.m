//
//  GCSMavlinkManager.m
//  iGCS
//
//  Created by Andrew Brown on 12/6/14.
//
//

#import "GCSMavLinkManager.h"

@implementation GCSMavLinkManager

+(GCSMavLinkManager *)sharedInstance {
    static GCSMavLinkManager *sharedObject = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });

    return sharedObject;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _concurrentQueue = dispatch_queue_create("com.fightingwalrus.mavlinkqueue.concurrent ", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

@end
