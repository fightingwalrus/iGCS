//
//  GotoPointAnnotation.h
//  iGCS
//
//  Created by Claudio Natoli on 6/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GotoPointAnnotation :  NSObject <MKAnnotation> {
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D  coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
