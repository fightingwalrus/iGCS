//
//  DoubleBufferedAsyncView.h
//  iGCS
//
//  Created by Claudio Natoli on 12/12/12.
//
//

#import <UIKit/UIKit.h>

@interface DoubleBufferedAsyncView : UIView {
    CGLayerRef _doubleBuffer[2];
    unsigned int _currentBuffer;
    bool _initializedBuffers;
    
    volatile int _casLock;
}

- (void) drawToContext:(CGContextRef)ctx rect:(CGRect)rect;
- (void) requestRedraw;

@end
