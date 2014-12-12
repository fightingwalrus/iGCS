//
//  GCSActivityIndicatorView.m
//  iGCS
//
//  Created by Andrew Brown on 7/19/14.
//
//

#import "GCSActivityIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GCSActivityIndicatorView

- (instancetype)init {
    return [self initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

-(instancetype)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style {
    self = [super initWithActivityIndicatorStyle:style];
    if (self) {
        [self configureView];
    }
    return self;
}

-(void)configureView {
    self.bounds = CGRectMake(0, 0, 110, 110);
    self.hidesWhenStopped = YES;
    self.alpha = 0.65f;
    self.backgroundColor = [UIColor blackColor];
    self.layer.cornerRadius = 15.0f;
}

-(void)centerOnView:(UIView *)view {
    CGSize thisViewSize = view.bounds.size;

    // Handle centering on both iOS 7 and iOS 8 where the frame is
    // now orientation aware. Current implementation expects device to be in
    // landscape view.
    self.center = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) ?
    CGPointMake(thisViewSize.width / 2.0, thisViewSize.height / 2.0):
    CGPointMake(thisViewSize.height / 2.0, thisViewSize.width / 2.0);

    [view addSubview:self];
    [view bringSubviewToFront:self];

}

@end
