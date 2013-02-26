//
//  VerticalScaleView.h
//  iGCS
//
//  Created by Claudio Natoli on 12/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoubleBufferedAsyncView.h"

@interface VerticalScaleView : DoubleBufferedAsyncView {
    int scale;
    float val;
    float targetDelta;
}

- (void) drawToContext:(CGContextRef)ctx rect:(CGRect)rect;

- (void) setScale:(int)_scale;
- (void) setValue:(float)_val;
- (void) setTargetDelta:(float)_targetDelta;

@end
