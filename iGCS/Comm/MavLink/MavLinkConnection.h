//
//  MavLinkConnection.h
//  iGCS
//
//  Created by Andrew Aarestad on 2/22/13.
//
//

#import <Foundation/Foundation.h>

@class MavLinkInterface;

@interface MavLinkConnection : NSObject



@property (strong) MavLinkInterface *source;
@property (strong) MavLinkInterface *destination;


+(MavLinkConnection*)createForSource:(MavLinkInterface*)source destination:(MavLinkInterface*)destination;

@end
