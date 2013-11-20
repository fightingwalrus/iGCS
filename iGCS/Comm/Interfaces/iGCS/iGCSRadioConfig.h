//
//  iCGCRadioConfig.h
//  iGCS
//
//  Created by Andrew Brown on 9/5/13.
//
//

#import "CommInterface.h"

@interface iGCSRadioConfig : CommInterface
// subsclasses must assign this property to use produceData
@property (strong) CommConnectionPool *connectionPool;

// receiveBytes processes bytes forwarded from another interface
-(void)consumeData:(uint8_t*)bytes length:(int)length;
-(void)produceData:(uint8_t*)bytes length:(int)length;
-(void) close;
@end
