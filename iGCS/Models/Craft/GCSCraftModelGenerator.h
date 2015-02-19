//
//  GCSCraftModelGenerator.h
//  iGCS
//
//  Created by Claudio Natoli on 24/01/2015.
//
//

#import <Foundation/Foundation.h>
#import "GCSCraftModel.h"

@interface GCSCraftModelGenerator : NSObject
+ (id<GCSCraftModel>) createInitialModel;
+ (id<GCSCraftModel>) updateOrReplaceModel:(id<GCSCraftModel>)model withCurrent:(mavlink_heartbeat_t)heartbeat;
@end
