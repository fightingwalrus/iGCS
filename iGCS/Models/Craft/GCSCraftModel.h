//
//  GCSCraftModel.h
//  iGCS
//
//  Created by Andrew Brown on 1/22/15.
//
//

#import <Foundation/Foundation.h>
#import "GCSCraftModes.h"
#import "GCSHeartbeat.h"

@protocol GCSCraftModel <NSObject>
@required;
- (id<GCSCraftModel>) init:(GCSHeartbeat *)heartbeat;

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

@property (nonatomic, strong) NSNotificationCenter *notificationCenter;
@property (nonatomic, strong) NSOperationQueue *craftQueue;
// These methods are optional so they can be mixed in
// at runtime
@optional;
@property (nonatomic, readonly) NSString *currentModeName;
- (void) updateWithHeartbeat:(GCSHeartbeat *)heartbeat;
- (BOOL) isArmed;


@end
