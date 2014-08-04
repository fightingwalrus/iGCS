//
//  ExceptionHandler.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/25/13.
//
//

#import <Foundation/Foundation.h>

@class DebugViewController;

@interface ExceptionHandler : NSObject

void catchUnhandledException(NSException* e);

+(void) start:(DebugViewController*)dVC;


@end
