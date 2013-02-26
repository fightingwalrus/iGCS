//
//  Logger.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/25/13.
//
//

#import <Foundation/Foundation.h>

@interface Logger : NSObject


+(void)addPendingConsoleMessage:(NSString*)message;
+(void)addPendingErrorMessage:(NSString*)message;
+(NSArray*)getPendingConsoleMessages;
+(NSArray*)getPendingErrorMessages;
+(void)clearPendingConsoleMessages;
+(void)clearPendingErrorMessages;

@end
