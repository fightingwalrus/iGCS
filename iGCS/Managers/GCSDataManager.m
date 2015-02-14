//
//  GCSDataManager.m
//  iGCS
//
//  Created by Andrew Brown on 1/22/15.
//
//

#import "GCSDataManager.h"

@implementation GCSDataManager

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _craft = [GCSCraftModelGenerator createInitialModel];
        _lastViewedMapCamera = nil;
    }
    return self;
}

@end
