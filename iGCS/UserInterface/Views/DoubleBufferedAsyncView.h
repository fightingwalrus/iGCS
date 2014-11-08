//
//  DoubleBufferedAsyncView.h
//  iGCS
//
//  Created by Claudio Natoli on 12/12/12.
//
//

#import <UIKit/UIKit.h>

@interface DoubleBufferedAsyncView : UIView

- (void) drawToContext:(CGContextRef)ctx rect:(CGRect)rect;
- (void) requestRedraw;

@end
