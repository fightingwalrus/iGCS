//
//  GCSTelemetryLossOverlayView.m
//  iGCS
//
//  Created by Claudio Natoli on 16/07/2014.
//
//

#import "GCSTelemetryLossOverlayView.h"
#import "LFGlassView.h"

@implementation GCSTelemetryLossOverlayView {
    LFGlassView *overlayView;
    UIView* parentView;
}

- (id) initWithParentView:(UIView*)_parentView {
    self = [super init];
    if (self) {
        parentView = _parentView;
    }
    return self;
}

- (void) show {
    if (overlayView) {
        return;
    }
    
    CGRect frame = parentView.frame;
    overlayView = [[LFGlassView alloc] initWithFrame:frame];
    overlayView.clipsToBounds = YES;
    overlayView.layer.cornerRadius = 0.0;
    overlayView.blurRadius = 1.0;
    overlayView.scaleFactor = 1.0;
    overlayView.liveBlurring = YES;
    [parentView addSubview:overlayView];
    
    UILabel *l = [[UILabel alloc] initWithFrame:frame];
    l.center = overlayView.center;
    l.text = @"Telemetry lost";
    l.textAlignment = NSTextAlignmentCenter;
    l.textColor = [UIColor whiteColor];
    l.font = [UIFont fontWithName:@"Helvetica" size: 64];
    l.backgroundColor = [UIColor clearColor];
    [overlayView addSubview:l];
}

- (void) hide {
    if (overlayView) {
        [overlayView removeFromSuperview];
        overlayView = nil;
    }
}

@end
