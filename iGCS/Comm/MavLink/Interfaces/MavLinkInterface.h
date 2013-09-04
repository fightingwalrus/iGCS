//
//  MavLinkInterface.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>

@class MavLinkConnectionPool;

@protocol MavLinkInterfaceProtocol <NSObject>
// subsclasses must assign this property to use produceData
@property (strong) MavLinkConnectionPool *connectionPool;

// receiveBytes processes bytes forwarded from another interface
-(void)consumeData:(uint8_t*)bytes length:(int)length;
-(void)produceData:(uint8_t*)bytes length:(int)length;
-(void) close;
@end

@interface MavLinkInterface : NSObject <MavLinkInterfaceProtocol>

// subsclasses must assign this property to use produceData
@property (strong) MavLinkConnectionPool *connectionPool;

// receiveBytes processes bytes forwarded from another interface
-(void)consumeData:(uint8_t*)bytes length:(int)length;
-(void)produceData:(uint8_t*)bytes length:(int)length;
-(void) close;

@end
