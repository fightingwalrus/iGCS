//
//  FollowMePointAnnotation.h
//  iGCS
//
//  Created by Claudio Natoli on 7/07/13.
//
//

#import "CustomPointAnnotation.h"

@interface RequestedPointAnnotation : CustomPointAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate NS_DESIGNATED_INITIALIZER;

@end
