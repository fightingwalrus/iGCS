//
//  MavLinkLogger
//  iGCS
//
//  Created by Andrew Brown on 8/22/13.
//
//

#import "MavLinkLogger.h"
#import "FileUtils.h"
#import <mach/mach_time.h>
#import "mavlink_helpers.h"

@implementation MavLinkLogger

-(id)initWithLogName:(NSString *)logName {
    self = [super init];
    if (self) {
        _writeBuffer = [[NSMutableData alloc] init];
        NSString *fullLogPath = [[FileUtils URLToFileInDocumentsDirWithFileName:logName] absoluteString];
        _fileHandle = [FileUtils fileHandleForWritingAtPath:fullLogPath create:YES];
        if (_fileHandle) {
            [_fileHandle seekToEndOfFile];
        }
    }
    return self;
}

#pragma mark -
#pragma mark Handle Mavlink data

-(void) handlePacket:(mavlink_message_t *)msg {
    const int len = MAVLINK_MAX_PACKET_LEN+sizeof(uint64_t);
    uint8_t buffer[len];
    uint64_t currentTime = [self systemTimeInUSecs];
    memcpy(buffer, (void *)&currentTime, sizeof(uint64_t));
    mavlink_msg_to_send_buffer(buffer+sizeof(uint64_t), msg);
    
    NSData *data = [NSData dataWithBytes:buffer length:len];
    [_fileHandle writeData:data];
}

-(uint64_t)systemTimeInUSecs {
    // see https://developer.apple.com/library/mac/qa/qa1398/
    static mach_timebase_info_data_t info;
    if (info.denom == 0) {
        (void) mach_timebase_info(&info);
    }

    uint64_t mach_time = mach_absolute_time();
    uint64_t nanoseconds = mach_time * info.numer / info.denom;
    return (uint64_t)nanoseconds/1000; // nanoseconds to microseconds
}

#pragma mark -
#pragma mark helpers


@end
