//
//  ExceptionHandler.m
//  iGCS
//
//  Created by Andrew Aarestad on 2/25/13.
//
//

#import "ExceptionHandler.h"

#import "DebugViewController.h"

@implementation ExceptionHandler

static DebugViewController *debugVC;

+(void) start:(DebugViewController*)dVC
{
#ifdef DEBUG
    debugVC = dVC;
    NSSetUncaughtExceptionHandler(&catchUnhandledException);
#endif
}

void catchUnhandledException(NSException* e)
{
    DDLogCError(@"Exception raised: ");
    DDLogCError(@"%@",[e description]);
}

@end
