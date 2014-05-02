//
//  CommInterface.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>

@class CommConnectionPool;

@protocol CommInterfaceProtocol <NSObject>
// subsclasses must assign this property to use produceData
@property (strong) CommConnectionPool *connectionPool;

@required;
// receiveBytes processes bytes forwarded from another interface
-(void)consumeData:(uint8_t*)bytes length:(int)length;
-(void)produceData:(uint8_t*)bytes length:(int)length;
-(void)close;
@end

@interface CommInterface : NSObject <CommInterfaceProtocol>

// subsclasses must assign this property to use produceData
@property (strong) CommConnectionPool *connectionPool;
// receiveBytes processes bytes forwarded from another interface
-(void)consumeData:(uint8_t*)bytes length:(int)length;
-(void)produceData:(uint8_t*)bytes length:(int)length;
-(void)close;

@end
