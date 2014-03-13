//
//  DataRateRecorder.h
//  iGCS
//
//  Created by Claudio Natoli on 4/03/2014.
//
//

#import <Foundation/Foundation.h>

@interface DataRateRecorder : NSObject

- (void) bytesReceived:(unsigned int)numBytes;

- (NSUInteger) maxDurationInSeconds;

- (NSUInteger) count;
- (double) secondsSince:(NSUInteger)index;
- (double) valueAt:(NSUInteger)index;
- (double) latestValue;
@property (nonatomic, assign) double maxValue;

@end

extern NSString * const GCSDataRecorderTick;
