//
//  GCSCraftModelGenerator.h
//  iGCS
//
//  Created by Claudio Natoli on 24/01/2015.
//
//

#import <Foundation/Foundation.h>
#import "GCSCraftModel.h"
#import "GCSHeartbeat.h"

@interface GCSCraftModelGenerator : NSObject
+ (id<GCSCraftModel>) createInitialModel;
+ (id<GCSCraftModel>) updateOrReplaceModel:(id<GCSCraftModel>)model withCurrent:(GCSHeartbeat *)heartbeat;
@end
