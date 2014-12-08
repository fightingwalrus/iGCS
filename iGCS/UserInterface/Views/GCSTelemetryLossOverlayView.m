//
//  GCSTelemetryLossOverlayView.m
//  iGCS
//
//  Created by Claudio Natoli on 16/07/2014.
//
//

#import "GCSTelemetryLossOverlayView.h"

@interface GCSTelemetryLossOverlayView ()
@property (nonatomic, strong) UILabel *telemetryLost;
@property (nonatomic, strong) UIView* parentView;
@end

@implementation GCSTelemetryLossOverlayView


- (instancetype) initWithParentView:(UIView*)parentView {
    self = [super init];
    if (self) {
        _parentView = parentView;
    }
    return self;
}

- (void) show {
    CGRect frame = self.parentView.frame;
    self.telemetryLost = [[UILabel alloc] initWithFrame:frame];
    [self.parentView addSubview:self.telemetryLost];
    self.telemetryLost.center = self.parentView.center;
    self.telemetryLost.text = @"Telemetry lost";
    self.telemetryLost.textAlignment = NSTextAlignmentCenter;
    self.telemetryLost.textColor = [UIColor whiteColor];
    self.telemetryLost.font = [UIFont fontWithName:@"Helvetica" size: 64];
    self.telemetryLost.backgroundColor = [UIColor clearColor];
}

- (void) hide {
    if (self.telemetryLost) {
        [self.telemetryLost removeFromSuperview];
        self.telemetryLost = nil;
    }
}

@end
