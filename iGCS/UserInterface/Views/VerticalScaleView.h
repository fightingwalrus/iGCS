//
//  VerticalScaleView.h
//  iGCS
//
//  Created by Claudio Natoli on 12/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoubleBufferedAsyncView.h"

@interface VerticalScaleView : DoubleBufferedAsyncView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger scale;
@property (nonatomic, assign) float value;
@property (nonatomic, assign) float targetDelta;

@property (nonatomic, assign) BOOL ceilingThresholdEnabled;
@property (nonatomic, assign) float ceilingThreshold;
@property (nonatomic, strong) UIColor* ceilingThresholdBackground;

- (void) drawToContext:(CGContextRef)ctx rect:(CGRect)rect;

@end
