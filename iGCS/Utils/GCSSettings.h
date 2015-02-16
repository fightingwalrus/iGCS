//
//  GCSSettings.h
//  iGCS
//
//  Created by David Leskowicz on 2/14/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, Units) {
    standard,
    metric
};


@interface GCSSettings : NSObject <NSCoding>

@property (assign, nonatomic) NSUInteger altitude;
@property (assign, nonatomic) NSUInteger radius;
@property (assign, nonatomic) NSUInteger ceiling;
@property (assign, nonatomic) NSUInteger unitType;


@end
