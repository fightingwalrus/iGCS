//
//  DataRateRecorder.h
//  iGCS
//
//  Created by Claudio Natoli on 4/03/2014.
//
//

#import <Foundation/Foundation.h>

@interface DataRateRecorder : NSObject

@property (nonatomic, readonly) double maxValue;
@property (nonatomic, readonly) NSUInteger maxDurationInSeconds;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) double latestValue;

- (void) bytesReceived:(NSUInteger)numBytes;

- (double) secondsSince:(NSUInteger)index;
- (double) valueAt:(NSUInteger)index;

@end

extern NSString * const GCSDataRecorderTick;
