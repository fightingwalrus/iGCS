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
    LFGlassView *_overlayView;
    UIView* _parentView;
}

- (instancetype) initWithParentView:(UIView*)parentView {
    self = [super init];
    if (self) {
        _parentView = parentView;
    }
    return self;
}

- (void) show {
    if (_overlayView) {
        return;
    }
    
    CGRect frame = _parentView.frame;
    _overlayView = [[LFGlassView alloc] initWithFrame:frame];
    _overlayView.clipsToBounds = YES;
    _overlayView.layer.cornerRadius = 0.0;
    _overlayView.blurRadius = 1.0;
    _overlayView.scaleFactor = 1.0;
    _overlayView.liveBlurring = YES;
    [_parentView addSubview:_overlayView];
    
    UILabel *l = [[UILabel alloc] initWithFrame:frame];
    l.center = _overlayView.center;
    l.text = @"Telemetry lost";
    l.textAlignment = NSTextAlignmentCenter;
    l.textColor = [UIColor whiteColor];
    l.font = [UIFont fontWithName:@"Helvetica" size: 64];
    l.backgroundColor = [UIColor clearColor];
    [_overlayView addSubview:l];
}

- (void) hide {
    if (_overlayView) {
        [_overlayView removeFromSuperview];
        _overlayView = nil;
    }
}

@end
