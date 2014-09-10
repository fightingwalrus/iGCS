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

+(void)error:(NSString*)message;

+(NSArray*)getPendingErrorMessages;
+(void)clearPendingErrorMessages;

+(void)dumpException:(NSException*)exception;

@end
