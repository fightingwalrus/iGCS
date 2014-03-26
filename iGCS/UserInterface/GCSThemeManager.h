//
//  GCSThemeManager.h
//  iGCS
//
//  Created by Claudio Natoli on 22/01/2014.
//
//

#import <Foundation/Foundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface GCSThemeManager : NSObject

+ (instancetype) sharedInstance;

@property (readonly) UIColor *appTintColor;

@property (readonly) UIColor *waypointLineStrokeColor;
@property (readonly) UIColor *waypointLineFillColor;

@property (readonly) UIColor *trackLineColor;

@property (readonly) UIColor *waypointNavColor;
@property (readonly) UIColor *waypointNavNextColor;
@property (readonly) UIColor *waypointLoiterColor;
@property (readonly) UIColor *waypointTakeoffLandColor;
@property (readonly) UIColor *waypointHomeColor;
@property (readonly) UIColor *waypointOtherColor;

@property (readonly) UIColor *altimeterCeilingBreachColor;

@end
