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
    
    if (!initializedBuffers) {
        doubleBuffer[0] = CGLayerCreateWithContext(context, self.frame.size, NULL);
        doubleBuffer[1] = CGLayerCreateWithContext(context, self.frame.size, NULL);
        currentBuffer = 0;
        initializedBuffers = true;
        [self requestRedraw];
    } else {
        @synchronized(self) {
            CGContextDrawLayerAtPoint(context, CGPointMake(0,0), doubleBuffer[(currentBuffer + 1) % 2]);
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
    if (!OSAtomicCompareAndSwapInt(0, 1, &casLock)) {
        return; // update already in progress
    }

    @autoreleasepool {
        if (initializedBuffers) {
            CGContextRef ctx = CGLayerGetContext(doubleBuffer[currentBuffer]);
            [self drawToContext:ctx rect:self.bounds];
            @synchronized(self) {
                currentBuffer = (currentBuffer + 1) % 2;
            }
        }
        [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:true];
    }
    
    casLock = 0;
}

@end
