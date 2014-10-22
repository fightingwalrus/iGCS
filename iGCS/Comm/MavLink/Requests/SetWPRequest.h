//
//  SetWPRequest.h
//  iGCS
//
//  Created by Claudio Natoli on 13/10/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkRetryingRequestHandler.h"
#import "iGCSMavLinkInterface.h"

@interface SetWPRequest : NSObject <MavLinkRetryableRequest>

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *subtitle;
@property (nonatomic, readonly) double timeout;

@property (nonatomic, readonly) iGCSMavLinkInterface* interface;
@property (nonatomic, readonly) uint16_t sequence;

- (instancetype)initWithInterface:(iGCSMavLinkInterface*)interface andSequence:(uint16_t)sequence NS_DESIGNATED_INITIALIZER;

@end
