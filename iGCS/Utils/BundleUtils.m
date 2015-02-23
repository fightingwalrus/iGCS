//
//  BundleUtils.m
//  iGCS
//
//  Created by David Leskowicz on 2/22/15.
//
//

#import "BundleUtils.h"

@implementation BundleUtils

+ (NSString *) appVersionInfo {
    return[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

@end
