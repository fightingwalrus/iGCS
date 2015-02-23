//
//  GCSSettings.h
//  iGCS
//
//  Created by David Leskowicz on 2/14/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, Units) {
    standard,
    metric
};

@interface GCSSettings : NSObject <NSCoding>

@property (assign, nonatomic) double altitude;
@property (assign, nonatomic) double radius;
@property (assign, nonatomic) double ceiling;
@property (assign, nonatomic) NSUInteger unitType;
@property (assign, nonatomic) BOOL audioAlertStatus;

@end
