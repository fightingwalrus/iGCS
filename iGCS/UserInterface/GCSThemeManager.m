//
//  GCSThemeManager.m
//  iGCS
//
//  Created by Claudio Natoli on 22/01/2014.
//
//

#import "GCSThemeManager.h"

@implementation GCSThemeManager

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
        _appSheetBackgroundColor = UIColorFromRGB(0xE5E5E5); // grey90

        _appTintColor = [UIColor colorWithRed:0.80 green:0.52 blue:0.25 alpha:1.0];  // Peru Brown
        
        _waypointLineStrokeColor = [UIColor blackColor];
        _waypointLineFillColor   = UIColorFromRGB(0x08ff08); // fluoro green
        
        _trackLineColor          = UIColorFromRGB(0xff5b00); // fluoro orange
        
        _waypointNavColor         = UIColorFromRGB(0x08ff08); // fluoro green
        _waypointNavNextColor     = [UIColor redColor];
        _waypointLoiterColor      = UIColorFromRGB(0x08ff08); // fluoro green
        _waypointTakeoffLandColor = UIColorFromRGB(0xff8c00); // dark orange
        _waypointHomeColor        = [UIColor whiteColor];
        _waypointOtherColor       = UIColorFromRGB(0xd02090);  // violet red
        
        _altimeterCeilingBreachColor = [UIColor redColor];
    }
    return self;
}

@end
