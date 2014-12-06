//
//  UILabel+gcs.h
//  iGCS
//
//  Created by Andrew Brown on 12/6/14.
//
//

#import <UIKit/UIKit.h>

@interface UILabel (gcs)
-(void)gcs_setTextOnMain:(NSString*)string;
@end

@interface UITextView (gcs)
-(void)gcs_setTextOnMain:(NSString*)string;
@end