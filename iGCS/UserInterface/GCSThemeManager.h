//
//  GCSThemeManager.h
//  iGCS
//
//  Created by Claudio Natoli on 22/01/2014.
//
//

#import <Foundation/Foundation.h>

@interface GCSThemeManager : NSObject

+ (instancetype) instance;

@property (readonly) UIColor *appTintColor;

@end
