//
//  MavLinkLogger
//  iGCS
//
//  Created by Andrew Brown on 8/22/13.
//
//

#import "MavLinkLogger.h"
#import "FileUtils.h"

#undef MAVLINK_USE_CONVENIENCE_FUNCTIONS // Prevents definitions of _mavlink_send_uart
#import "mavlink_helpers.h"

@implementation MavLinkLogger

-(instancetype)initWithLogName:(NSString *)logName {
    self = [super init];
    if (self) {
        NSString *fullLogPath = [[FileUtils URLToFileInDocumentsDirWithFileName:logName] path];
        _fileHandle = [FileUtils fileHandleForWritingAtPath:fullLogPath create:YES];
        if (_fileHandle) {
            [_fileHandle seekToEndOfFile];
        }
        
        _dateTimeUtils = [[DateTimeUtils alloc] init];
        if (!_serialQueue) {
            _serialQueue = dispatch_queue_create("com.fightingwalrus.igcs.mavlinklogger", NULL);
        }
    }
    return self;
}

#pragma mark -
#pragma mark Handle Mavlink data

-(void) handlePacket:(mavlink_message_t *)msg {
    uint8_t buffer[MAVLINK_MAX_PACKET_LEN+sizeof(uint64_t)];
    uint64_t currentTime = CFSwapInt64HostToBig([_dateTimeUtils unixTimeInMicroseconds]);
    memcpy(buffer, (void *)&currentTime, sizeof(uint64_t));
    uint16_t bufferLen = mavlink_msg_to_send_buffer(buffer+sizeof(uint64_t), msg);
    
    NSData *data = [NSData dataWithBytes:buffer length:bufferLen+sizeof(u_int64_t)];
    
    dispatch_async(_serialQueue ,
                   ^ {
                    // log format will be in little endian on ios device
                       [_fileHandle writeData:data];
                   });
}

@end
