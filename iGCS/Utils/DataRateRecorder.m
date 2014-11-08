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

@interface DataRateRecorder ()
@property (nonatomic, strong) NSTimer *tickTimer;

@property (nonatomic, assign) double maxValue;

@property (nonatomic, assign) NSUInteger circularIndex;
@property (nonatomic, assign) NSUInteger numBytesSinceTick;
@end

@implementation DataRateRecorder {
    double _avgKBps[NUM_KBPS_DATA_POINTS];
}

- (instancetype) init {
    self = [super init];
    if (self) {
        // Initialize the data rate tracking timer and counters
        self.circularIndex = 0;
        self.numBytesSinceTick = 0;
        self.tickTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0f/NUM_KPBS_TICKS_PER_SECOND)
                                                          target:self
                                                        selector:@selector(numBytesTimerTick:)
                                                        userInfo:nil
                                                         repeats:YES];
    }
    return self;
}

- (void) numBytesTimerTick:(NSTimer *)timer {
    // Place the next kB/tick value in the circular buffer, and add to previous NUM_KPBS_TICKS_PER_SECOND-1 points
    double kB = (self.numBytesSinceTick/1024.0f);
    for (NSUInteger i = 0; i < NUM_KPBS_TICKS_PER_SECOND; i++) {
        if (self.circularIndex >= i) {
            NSUInteger idx = (self.circularIndex - i) % NUM_KBPS_DATA_POINTS;
            if (i == 0) {
                _avgKBps[idx] = kB;
            } else {
                _avgKBps[idx] += kB;
            }
        }
    }
    
    // Find the maximum value
    self.maxValue = 0;
    for (NSUInteger i = 0; i < [self count]; i++) {
        self.maxValue = MAX(self.maxValue, _avgKBps[i]);
    }
    
    // Prepare for next tick
    self.numBytesSinceTick = 0;
    self.circularIndex++;
    
    // Notify listeners
    [[NSNotificationCenter defaultCenter] postNotificationName:GCSDataRecorderTick object:self];
}


- (void) bytesReceived:(NSUInteger)numBytes {
    self.numBytesSinceTick += numBytes;
}


- (NSUInteger) maxDurationInSeconds {
    return (NUM_KBPS_DATA_POINTS-NUM_KPBS_TICKS_PER_SECOND)/NUM_KPBS_TICKS_PER_SECOND;
}

- (NSUInteger) count {
    return MIN(self.circularIndex, NUM_KBPS_DATA_POINTS-NUM_KPBS_TICKS_PER_SECOND);
}

- (double) secondsSince:(NSUInteger)index {
    return (double)index/NUM_KPBS_TICKS_PER_SECOND;
}

- (double) valueAt:(NSUInteger)index {
    NSAssert(0 <= index && index < [self count], @"DataRateRecorder:valueAt with out-of-bounds index");

    // Hunt backwards through the buffer, from the most recent (index 0) fully populated point
    return _avgKBps[(self.circularIndex - NUM_KPBS_TICKS_PER_SECOND - index + NUM_KBPS_DATA_POINTS) % NUM_KBPS_DATA_POINTS];
}

- (double) latestValue {
    return [self valueAt:0];
}

@end
