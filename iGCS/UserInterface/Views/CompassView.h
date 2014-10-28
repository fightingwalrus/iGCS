//
//  CompassView.h
//  iGCS
//
//  Created by Claudio Natoli on 12/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoubleBufferedAsyncView.h"

@interface CompassView : DoubleBufferedAsyncView {
    float _heading;
    float _navBearing;
}

- (void) drawToContext:(CGContextRef)ctx rect:(CGRect)rect;

- (void) setHeading:(float)heading;
- (void) setNavBearing:(float)navBearing;

@end
