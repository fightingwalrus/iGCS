//
//  Logger.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/25/13.
//
//

#import "Logger.h"

#import "DebugViewController.h"


@implementation Logger

static NSMutableArray *pendingConsoleMessages;
static NSMutableArray *pendingErrorMessages;

static DebugViewController *debugVC;

#ifdef DEBUG
static BOOL loggerEnabled = YES;
#else
static BOOL loggerEnabled = NO;
#endif


+(void)setDebugVC:(DebugViewController*)dVC {
    if (loggerEnabled) {
        debugVC = dVC;
    }
}

+(void)console:(NSString*)message {
    if (loggerEnabled) {
        NSString *messageString = [self createLogString:message];

        if (debugVC) {
            NSLog(@"Console: %@",message);
            [debugVC consoleMessage:messageString];
        } else {
            NSLog(@"Pending Console: %@",message);
            [self addPendingConsoleMessage:messageString];
        }
    }
 }

+(void)error:(NSString*)message {
    if (loggerEnabled) {
        NSString *messageString = [self createLogString:message];

        if (debugVC) {
            NSLog(@"Error: %@",message);
            [debugVC errorMessage:messageString];
        } else {
            NSLog(@"Pending Error: %@",message);
            [self addPendingErrorMessage:messageString];
        }
    }
}

+(void)dumpException:(NSException*)exception {
    if (loggerEnabled) {
        [self error:exception.name];
        [self error:exception.description];

        for (NSString *stackItem in exception.callStackSymbols) {
            [self error:stackItem];
        }
    }
}


// helpers for debug view console and errors
+(void)addPendingConsoleMessage:(NSString*)message {
    if (loggerEnabled) {
        if (!pendingConsoleMessages){
            pendingConsoleMessages = [NSMutableArray array];
        }

        [pendingConsoleMessages addObject:message];
    }
}

+(void)addPendingErrorMessage:(NSString*)message {
    if (loggerEnabled) {
        if (!pendingErrorMessages) {
            pendingErrorMessages = [NSMutableArray array];
        }
        [pendingErrorMessages addObject:message];
    }
}

+(NSArray*)getPendingConsoleMessages {
    if (!loggerEnabled) {
        return nil;
    }

    if (pendingConsoleMessages) {
        return [NSArray arrayWithArray:pendingConsoleMessages];
    } else {
        return [NSArray array];
    }
}

+(NSArray*)getPendingErrorMessages {
    if (!loggerEnabled) {
        return nil;
    }

    if (pendingErrorMessages) {
        return [NSArray arrayWithArray:pendingErrorMessages];
    } else {
        return [NSArray array];
    }
}

+(void)clearPendingConsoleMessages {
    if (loggerEnabled) {
        [pendingConsoleMessages removeAllObjects];
    }
}

+(void)clearPendingErrorMessages {
    if (loggerEnabled) {
        [pendingErrorMessages removeAllObjects];
    }
}

+(NSString*)createLogString:(NSString*)message {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *logString = [NSString stringWithFormat:@"%@: %@",dateString,message];
    
    return logString;
}

@end
