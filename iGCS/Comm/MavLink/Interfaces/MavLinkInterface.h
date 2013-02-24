//
//  MavLinkInterface.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>

@class MavLinkConnectionPool;







@interface MavLinkInterface : NSObject


@property (strong) MavLinkConnectionPool *connectionPool;


// receiveBytes processes bytes forwarded from another interface
-(void)receiveForwardedBytes:(uint8_t*)bytes length:(int)length;



-(void)receivedBytes:(uint8_t*)bytes length:(int)length;


@end
