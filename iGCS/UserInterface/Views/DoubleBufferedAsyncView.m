//
//  DoubleBufferedAsyncView.m
//  iGCS
//
//  Created by Claudio Natoli on 12/12/12.
//
//

#import "DoubleBufferedAsyncView.h"
#include <libkern/OSAtomic.h>

@implementation DoubleBufferedAsyncView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!_initializedBuffers) {
        _doubleBuffer[0] = CGLayerCreateWithContext(context, self.frame.size, NULL);
        _doubleBuffer[1] = CGLayerCreateWithContext(context, self.frame.size, NULL);
        _currentBuffer = 0;
        _initializedBuffers = true;
        [self requestRedraw];
    } else {
        @synchronized(self) {
            CGContextDrawLayerAtPoint(context, CGPointMake(0,0), _doubleBuffer[(_currentBuffer + 1) % 2]);
        }
    }
}

- (void) drawToContext:(CGContextRef)ctx rect:(CGRect)rect {
}

- (void) requestRedraw {
#if 0
    [self performSelectorInBackground:@selector(updateLayer) withObject:nil];
#else
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        [self updateLayer];
    });
#endif
}

- (void)updateLayer {
    if (!OSAtomicCompareAndSwapInt(0, 1, &_casLock)) {
        return; // update already in progress
    }

    @autoreleasepool {
        if (_initializedBuffers) {
            CGContextRef ctx = CGLayerGetContext(_doubleBuffer[_currentBuffer]);
            [self drawToContext:ctx rect:self.bounds];
            @synchronized(self) {
                _currentBuffer = (_currentBuffer + 1) % 2;
            }
        }
        [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:true];
    }
    
    _casLock = 0;
}

@end
