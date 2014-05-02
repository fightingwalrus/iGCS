//
//  iCGCRadioConfig.m
//  iGCS
//
//  Created by Andrew Brown on 9/5/13.
//
//

#import "iGCSRadioConfig.h"

@interface iGCSRadioConfig () {
    NSTimer *_timer;
    NSMutableString *_buffer;
    NSMutableArray *_possibleCommands;
    NSMutableDictionary *_currentSettings;
}
 -(void)sendATCommand:(NSString *)atCommand;
@end

@implementation iGCSRadioConfig

-(id) init {
    self = [super init];
    if (self) {
        // public
        _sikAt = [[GCSSikAT alloc] init];
        _buffer = [[NSMutableString alloc] init];
        _possibleCommands = [[NSMutableArray alloc] init];
        _currentSettings = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// receiveBytes processes bytes forwarded from another interface

-(void)consumeData:(uint8_t*)bytes length:(int)length {
    NSLog(@"iGCSRadioConfig consumeData");
    NSData *data = [NSData dataWithBytes:bytes length:length];
    NSString *aString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

    @synchronized(_buffer) {
        [_buffer appendString:[aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        [_buffer appendString:@"|"];
    }

    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(parseBuffer) userInfo:nil repeats:YES];
    }
}

-(void)parseBuffer {
    NSArray *arOfBuffer = [_buffer componentsSeparatedByString:@"|"];
    for (NSUInteger i = 0; i < arOfBuffer.count; i++) {
        NSString *item = [arOfBuffer objectAtIndex:i];
        if ([_possibleCommands containsObject:item]) {
            if (i+1 <= arOfBuffer.count) {
                NSLog(@"%@:%@", item, [arOfBuffer objectAtIndex:i+1]);
                _currentSettings[item] = [arOfBuffer objectAtIndex:i+1];
            }
        }
    }
}

-(void)produceData:(uint8_t*)bytes length:(int)length {
    NSLog(@"iGCSRadioConfig produceData");
    NSLog(@"%@",_buffer);
    [super produceData:bytes length:length];
}

-(void) close {
    NSLog(@"iGCSRadioClose: close is a noop");
}


#pragma public mark - send commands

// read only
-(void)radioVersion {
    [self sendATCommand:_sikAt.showRadioVersionCommand];
}

-(void)boadType {
    [self sendATCommand:_sikAt.showBoardTypeCommand];
}

-(void)RSSIReport {
    [self sendATCommand:_sikAt.showRSSISignalReport];
}

// read/Write
-(void)netId {
    [self sendATCommand:_sikAt.showNetIDCommand];
}

-(void)setNetId:(NSInteger) netId {
    [self sendATCommand:[_sikAt setNetIdCommandWithNetId:netId]];
}

-(void)enableRSSIDebug {
    [self sendATCommand:[_sikAt enableRSSIDebugCommand]];
}

-(void)disableDebug {
    [self sendATCommand:[_sikAt disableDebugCommand]];
}

-(void)save {
    [self sendATCommand:[_sikAt writeCurrentParamsToEEPROMCommand]];
}

#pragma mark - private
-(void)sendATCommand:(NSString *)atCommand {
    [_possibleCommands addObject:atCommand];
    NSString *command = [NSString stringWithFormat:@"\r\n%@\r\n", atCommand];
    const char* buf;
    buf = [command cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t len = (uint32_t)strlen(buf);
    [self produceData:buf length:len];
}

@end
