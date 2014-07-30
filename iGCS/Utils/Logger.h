//
//  Logger.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/25/13.
//
//

#import <Foundation/Foundation.h>


@class DebugViewController;

@interface Logger : NSObject


+(void)setDebugVC:(DebugViewController*)dVC;


+(void)console:(NSString*)message;
+(void)error:(NSString*)message;

+(NSArray*)getPendingConsoleMessages;
+(NSArray*)getPendingErrorMessages;
+(void)clearPendingConsoleMessages;
+(void)clearPendingErrorMessages;

+(void)dumpException:(NSException*)exception;

@end
