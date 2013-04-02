//
//  DebugLogger.h
//  iGCS
//
//  Created by Andrew Aarestad on 4/1/13.
//
//

#import <Foundation/Foundation.h>

@interface DebugLogger : NSObject

+(void)start:(UILabel*)consoleLabel;

+(void)console:(NSString*)message, ...;


+(void)addToConsole:(NSString*)message;
+(NSString*)getConsoleText;

+(void)dumpException:(NSException*)exception;

@end
