//
//  FollowMePointAnnotation.m
//  iGCS
//
//  Created by Claudio Natoli on 7/07/13.
//
//

#import "RequestedPointAnnotation.h"

@implementation RequestedPointAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [super initWithCoordinate:coordinate
                               title:@"Next \"Follow Me\" request"
                              viewID:@"REQUESTED"
                               color:[UIColor orangeColor]
                        andAnimation:NO];
}

@end
