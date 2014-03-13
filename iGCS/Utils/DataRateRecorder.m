//
//  DataRateRecorder.m
//  iGCS
//
//  Created by Claudio Natoli on 4/03/2014.
//
//

#import "DataRateRecorder.h"

#define NUM_KPBS_TICKS_PER_SECOND     8
#define NUM_KBPS_DATA_POINTS        (61 * NUM_KPBS_TICKS_PER_SECOND)

NSString * const GCSDataRecorderTick = @"com.fightingwalrus.igcs.datarecorder.tick";

@implementation DataRateRecorder {
    NSTimer *tickTimer;
    
    double avgKBps[NUM_KBPS_DATA_POINTS];
    NSUInteger circularIndex;
    NSUInteger numBytesSinceTick;
}

- (id) init
{
    self = [super init];
    if (self) {
        // Initialize the data rate tracking timer and counters
        circularIndex = 0;
        numBytesSinceTick = 0;
        tickTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0f/NUM_KPBS_TICKS_PER_SECOND)
                                                     target:self
                                                   selector:@selector(numBytesTimerTick:)
                                                   userInfo:nil
                                                    repeats:YES];
    }
    return self;
}

- (void) numBytesTimerTick:(NSTimer *)timer {
    // Place the next kB/tick value in the circular buffer, and add to previous NUM_KPBS_TICKS_PER_SECOND-1 points
    double kB = (numBytesSinceTick/1024.0f);
    for (unsigned int i = 0; i < NUM_KPBS_TICKS_PER_SECOND; i++) {
        if (circularIndex >= i) {
            unsigned int idx = (circularIndex - i) % NUM_KBPS_DATA_POINTS;
            if (i == 0) {
                avgKBps[idx] = kB;
            } else {
                avgKBps[idx] += kB;
            }
        }
    }
    
    // Find the maximum value
    _maxValue = 0;
    for (unsigned int i = 0; i < [self count]; i++) {
        _maxValue = MAX(_maxValue,avgKBps[i]);
    }
    
    // Prepare for next tick
    numBytesSinceTick = 0;
    circularIndex++;
    
    // Notify listeners
    [[NSNotificationCenter defaultCenter] postNotificationName:GCSDataRecorderTick object:self];
}


- (void) bytesReceived:(unsigned int)numBytes {
    numBytesSinceTick += numBytes;
}


- (NSUInteger) maxDurationInSeconds {
    return (NUM_KBPS_DATA_POINTS-NUM_KPBS_TICKS_PER_SECOND)/NUM_KPBS_TICKS_PER_SECOND;
}

- (NSUInteger) count {
    return MIN(circularIndex, NUM_KBPS_DATA_POINTS-NUM_KPBS_TICKS_PER_SECOND);
}

- (double) secondsSince:(NSUInteger)index {
    return (double)index/NUM_KPBS_TICKS_PER_SECOND;
}

- (double) valueAt:(NSUInteger)index {
    NSAssert(0 <= index && index < [self count], @"DataRateRecorder:valueAt with out-of-bounds index");

    // Hunt backwards through the buffer, from the most recent (index 0) fully populated point
    return avgKBps[(circularIndex - NUM_KPBS_TICKS_PER_SECOND - index + NUM_KBPS_DATA_POINTS) % NUM_KBPS_DATA_POINTS];
}

- (double) latestValue {
    return [self valueAt:0];
}

@end
