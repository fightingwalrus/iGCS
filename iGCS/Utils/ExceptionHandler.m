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
#ifdef DEBUG
    NSLog(@"Exception raised: ");
    NSLog(@"%@",[e description]);
#endif
}



@end
