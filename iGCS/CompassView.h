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
    float heading;
    float navBearing;
}

- (void) drawToContext:(CGContextRef)ctx rect:(CGRect)rect;

- (void) setHeading:(float)_heading;
- (void) setNavBearing:(float)_navBearing;

@end
