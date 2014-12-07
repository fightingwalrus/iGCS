//
//  UILabel+gcs.m
//  iGCS
//
//  Created by Andrew Brown on 12/6/14.
//
//

#import "UIViews+gcs.h"

@implementation UILabel (gcs)

-(void)gcs_setTextOnMain:(NSString*)string {
    dispatch_async(dispatch_get_main_queue() , ^{
        [self setText:string];
    });
}

-(void)gcs_setTextColorOnMain:(UIColor *)color {
    dispatch_async(dispatch_get_main_queue() , ^{
        [self setTextColor:color];
    });
}

@end

@implementation UITextView (gcs)

-(void)gcs_setTextOnMain:(NSString*)string {
    dispatch_async(dispatch_get_main_queue() , ^{
        [self setText:string];
    });
}

@end