//
//  ArtificialHorizonView.h
//  iGCS
//
//  Created by Claudio Natoli on 11/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoubleBufferedAsyncView.h"

@interface ArtificialHorizonView : DoubleBufferedAsyncView {
    float roll, pitch;
}

- (void) setRoll: (float)_roll pitch:(float)_pitch;

- (void) drawToContext:(CGContextRef)ctx rect:(CGRect)rect;
- (void) drawAHGaugeInnerCircle: (CGContextRef)ctx centre:(CGPoint)c radius:(float)r;
- (void) drawAHGaugeOuterFixed:  (CGContextRef)ctx centre:(CGPoint)c radius:(float)r;
- (void) drawAHGaugeFrontFace:   (CGContextRef)ctx centre:(CGPoint)c radius:(float)r;

@end
