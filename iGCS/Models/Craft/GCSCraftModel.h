//
//  GCSCraftModel.h
//  iGCS
//
//  Created by Andrew Brown on 1/22/15.
//
//

#import <Foundation/Foundation.h>
#import "mavlink.h"
#import "GCSCraftModes.h"

@protocol GCSCraftModel <NSObject>
@required;
- (id<GCSCraftModel>) init:(mavlink_heartbeat_t)heartbeat;
- (void) update:(mavlink_heartbeat_t)heartbeat;

@property (nonatomic, readonly) GCSCraftType craftType;

// Mode change
@property (nonatomic, readonly) uint32_t autoMode;
@property (nonatomic, readonly) uint32_t guidedMode;
@property (nonatomic, readonly) BOOL setModeBeforeGuidedItems;

// Mode status
@property (nonatomic, readonly) BOOL isInAutoMode;
@property (nonatomic, readonly) BOOL isInGuidedMode;

// Representation
@property (nonatomic, readonly) UIImage* icon;
@end
