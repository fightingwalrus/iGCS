//
//  MavLinkLogger
//  iGCS
//
//  Created by Andrew Brown on 8/22/13.
//
//

#import "MavLinkLogger.h"
#import "FileUtils.h"
#import "mavlink_helpers.h"

@implementation MavLinkLogger

-(id)initWithLogName:(NSString *)logName {
    self = [super init];
    if (self) {
        NSString *fullLogPath = [[FileUtils URLToFileInDocumentsDirWithFileName:logName] path];
        _fileHandle = [FileUtils fileHandleForWritingAtPath:fullLogPath create:YES];
        if (_fileHandle) {
            [_fileHandle seekToEndOfFile];
        }
        
        _dateTimeUtils = [[DateTimeUtils alloc] init];
        if (!serialQueue) {
            serialQueue = dispatch_queue_create("com.fightingwalrus.igcs.mavlinklogger", NULL);
        }
    }
    return self;
}

#pragma mark -
#pragma mark Handle Mavlink data

-(void) handlePacket:(mavlink_message_t *)msg {
    const int len = MAVLINK_MAX_PACKET_LEN+sizeof(uint64_t);
    uint8_t buffer[len];
    uint64_t currentTime = [_dateTimeUtils unixTimeInMicroseconds];
    memcpy(buffer, (void *)&currentTime, sizeof(uint64_t));
    mavlink_msg_to_send_buffer(buffer+sizeof(uint64_t), msg);
    
    NSData *data = [NSData dataWithBytes:buffer length:len];
    
    dispatch_async(serialQueue ,
                   ^ {
                    // log format will be in little endian on ios device
                       [_fileHandle writeData:data];
                   });
}

@end
