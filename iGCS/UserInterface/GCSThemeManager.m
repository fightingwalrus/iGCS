//
//  GCSThemeManager.m
//  iGCS
//
//  Created by Claudio Natoli on 22/01/2014.
//
//

#import "GCSThemeManager.h"

@implementation GCSThemeManager

+ (instancetype) instance {
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
        _appTintColor = [UIColor colorWithRed:0.80 green:0.52 blue:0.25 alpha:1.0];  // Peru Brown
    }
    return self;
}

@end
