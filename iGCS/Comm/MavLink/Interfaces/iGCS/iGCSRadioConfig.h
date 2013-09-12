//
//  iCGCRadioConfig.h
//  iGCS
//
//  Created by Andrew Brown on 9/5/13.
//
//

#import "MavLinkInterface.h"

@interface iGCSRadioConfig : MavLinkInterface
// subsclasses must assign this property to use produceData
@property (strong) MavLinkConnectionPool *connectionPool;

// receiveBytes processes bytes forwarded from another interface
-(void)consumeData:(uint8_t*)bytes length:(int)length;
-(void)produceData:(uint8_t*)bytes length:(int)length;
-(void) close;
@end
