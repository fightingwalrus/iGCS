//
//  RxMissionItems.h
//  iGCS
//
//  Created by Claudio Natoli on 13/10/13.
//
//

#import <Foundation/Foundation.h>
#import "MavLinkRetryingRequestHandler.h"
#import "iGCSMavLinkInterface.h"

@interface RxMissionItems : NSObject <MavLinkRetryableRequest>

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *subtitle;
@property (nonatomic, readonly) double timeout;

@property (nonatomic, readonly) iGCSMavLinkInterface* interface;
@property (nonatomic, readonly) WaypointsHolder* mission;

- (id)initWithInterface:(iGCSMavLinkInterface*)interface andMission:(WaypointsHolder*)mission;

@end
