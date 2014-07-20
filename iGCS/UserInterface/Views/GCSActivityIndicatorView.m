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

- (id)init
{
    self = [super initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    if (self) {
        [self configureView];
    }
    return self;
}

-(id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
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

@end
