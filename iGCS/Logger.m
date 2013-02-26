//
//  Logger.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/25/13.
//
//

#import "Logger.h"

@implementation Logger

static NSMutableArray *pendingConsoleMessages;
static NSMutableArray *pendingErrorMessages;

// helpers for debug view console and errors
+(void)addPendingConsoleMessage:(NSString*)message
{
    if (!pendingConsoleMessages)
    {
        pendingConsoleMessages = [NSMutableArray array];
    }
    [pendingConsoleMessages addObject:message];
}

+(void)addPendingErrorMessage:(NSString*)message
{
    if (!pendingErrorMessages)
    {
        pendingErrorMessages = [NSMutableArray array];
    }
    [pendingErrorMessages addObject:message];
}

+(NSArray*)getPendingConsoleMessages
{
    if (pendingConsoleMessages)
    {
        return [NSArray arrayWithArray:pendingConsoleMessages];
    }
    else
    {
        return [NSArray array];
    }
}
+(NSArray*)getPendingErrorMessages
{
    if (pendingErrorMessages)
    {
        return [NSArray arrayWithArray:pendingErrorMessages];
    }
    else
    {
        return [NSArray array];
    }
}

+(void)clearPendingConsoleMessages
{
    [pendingConsoleMessages removeAllObjects];
}

+(void)clearPendingErrorMessages
{
    [pendingErrorMessages removeAllObjects];
}

@end
