//
//  GotoPointAnnotation.m
//  iGCS
//
//  Created by Claudio Natoli on 6/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GotoPointAnnotation.h"

@implementation GotoPointAnnotation

@synthesize coordinate  = _coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        _coordinate = coordinate;
    }
    return self;
}

- (NSString*) title {
    return @"GOTO point";
}

- (NSString*) subtitle {
    return [NSString stringWithFormat:@"%f,%f", _coordinate.longitude, _coordinate.latitude];
}

@end
