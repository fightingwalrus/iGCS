//
//  DoubleBufferedAsyncView.h
//  iGCS
//
//  Created by Claudio Natoli on 12/12/12.
//
//

#import <UIKit/UIKit.h>

@interface DoubleBufferedAsyncView : UIView {
    CGLayerRef doubleBuffer[2];
    unsigned int currentBuffer;
    bool initializedBuffers;
    
    int casLock;
}

- (void) drawToContext:(CGContextRef)ctx rect:(CGRect)rect;
- (void) requestRedraw;

@end
