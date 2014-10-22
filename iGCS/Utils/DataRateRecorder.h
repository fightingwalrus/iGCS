//
//  DataRateRecorder.h
//  iGCS
//
//  Created by Claudio Natoli on 4/03/2014.
//
//

#import <Foundation/Foundation.h>

@interface DataRateRecorder : NSObject

@property (nonatomic, assign) double maxValue;

- (void) bytesReceived:(unsigned int)numBytes;

- (NSUInteger) maxDurationInSeconds;

- (NSUInteger) count;
- (double) secondsSince:(NSUInteger)index;
- (double) valueAt:(NSUInteger)index;
- (double) latestValue;

@end

extern NSString * const GCSDataRecorderTick;
