//
//  DebugLogger.m
//  iGCS
//
//  Created by Andrew Aarestad on 4/1/13.
//
//

#import "DebugLogger.h"

#define CONSOLE_BUFFER_SIZE 30


@implementation DebugLogger

static NSMutableArray *consoleBuffer;
static UILabel *consoleLabelRef;

+(void)start:(UILabel*)consoleLabel
{
    consoleBuffer = [NSMutableArray arrayWithCapacity:CONSOLE_BUFFER_SIZE];
    
    consoleLabelRef = consoleLabel;
    
    
}



+(void)console:(NSString*)format, ...
{
#ifndef DEBUG
    // put varargs into variable args
    va_list args;
    // put everything after message into varargs list
    va_start(args, format);
    
    NSString *message = [[NSString alloc]initWithFormat:format arguments:args];
    NSLog(@"DebugLogger: %@",message);
    [self addToConsole:[NSString stringWithFormat:@"%@: %@",[[NSDate date] description],message]];
    
    consoleLabelRef.text = [self getConsoleText];
#endif
}



+(void)addToConsole:(NSString*)message
{
    if (consoleBuffer)
    {
        if ([consoleBuffer count] >= CONSOLE_BUFFER_SIZE)
        {
            [consoleBuffer removeObjectAtIndex:0];
        }
        [consoleBuffer addObject:message];
    }
}


+(NSString*)getConsoleText
{
    NSString *newConsoleText = @"";
    for (NSString* line in consoleBuffer)
    {
        newConsoleText = [newConsoleText stringByAppendingString:[line stringByAppendingString:@"\n"]];
    }
    return newConsoleText;
}


+(void)dumpException:(NSException*)exception
{
    [self console:exception.name];
    [self console:exception.description];
    for (NSString *stackItem in exception.callStackSymbols)
    {
        [self console:stackItem];
    }
}


@end