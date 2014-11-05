//
//  GCSTelemetryLossOverlayView.m
//  iGCS
//
//  Created by Claudio Natoli on 16/07/2014.
//
//

#import "GCSTelemetryLossOverlayView.h"
#import "LFGlassView.h"

@interface GCSTelemetryLossOverlayView ()
@property (nonatomic, strong) LFGlassView *overlayView;
@property (nonatomic, strong) UIView* parentView;
@end

@implementation GCSTelemetryLossOverlayView


- (instancetype) initWithParentView:(UIView*)parentView {
    self = [super init];
    if (self) {
        _parentView = parentView;
        _overlayView = nil;
    }
    return self;
}

- (void) show {
    if (self.overlayView) {
        return;
    }
    
    CGRect frame = self.parentView.frame;
    self.overlayView = [[LFGlassView alloc] initWithFrame:frame];
    self.overlayView.clipsToBounds = YES;
    self.overlayView.layer.cornerRadius = 0.0;
    self.overlayView.blurRadius = 1.0;
    self.overlayView.scaleFactor = 1.0;
    self.overlayView.liveBlurring = YES;
    [self.parentView addSubview:self.overlayView];
    
    UILabel *l = [[UILabel alloc] initWithFrame:frame];
    l.center = self.overlayView.center;
    l.text = @"Telemetry lost";
    l.textAlignment = NSTextAlignmentCenter;
    l.textColor = [UIColor whiteColor];
    l.font = [UIFont fontWithName:@"Helvetica" size: 64];
    l.backgroundColor = [UIColor clearColor];
    [self.overlayView addSubview:l];
}

- (void) hide {
    if (self.overlayView) {
        [self.overlayView removeFromSuperview];
        self.overlayView = nil;
    }
}

@end
